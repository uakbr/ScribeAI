import Foundation
import CoreML
import AVFoundation
import Accelerate

class WhisperModelManager {
    // MARK: - Properties
    static let shared = WhisperModelManager()
    
    private var model: WhisperModel?
    private let modelQueue = DispatchQueue(label: "com.whispertranscription.modelqueue")
    
    // Audio processing constants
    private let sampleRate: Double = 16000
    private let hopLength: Int = 160
    private let numMelBins: Int = 80
    private let windowLength: Int = 400
    private let maxAudioLength: Double = 30.0
    private let melFilterbank: MelFilterbank
    
    // FFT setup
    private let fftSetup: vDSP_DFT_Setup?
    private let hannWindow: [Float]
    
    // MARK: - Initialization
    private init() {
        // Initialize FFT setup
        fftSetup = vDSP_DFT_zop_CreateSetup(
            nil,
            UInt(windowLength),
            vDSP_DFT_Direction.FORWARD
        )
        
        // Create Hanning window
        hannWindow = vDSP.window(ofType: Float.self,
                               usingSequence: .hanningDenormalized,
                               count: windowLength,
                               isHalfWindow: false)
        
        // Initialize mel filterbank
        melFilterbank = MelFilterbank(
            sampleRate: Int(sampleRate),
            nFft: windowLength,
            nMels: numMelBins,
            fMin: 0.0,
            fMax: sampleRate/2
        )
        
        loadModel()
    }
    
    deinit {
        if let fftSetup = fftSetup {
            vDSP_DFT_DestroySetup(fftSetup)
        }
    }
    
    // MARK: - Model Loading
    private func loadModel() {
        do {
            let config = MLModelConfiguration()
            model = try WhisperModel(configuration: config)
        } catch {
            // Handle model loading error
            ErrorAlertManager.shared.handleModelLoadingError(error)
        }
    }
    
    // MARK: - Audio Processing
    private func convertAudioToMelSpectrogram(_ audioBuffer: AVAudioPCMBuffer) throws -> MLMultiArray {
        guard let channelData = audioBuffer.floatChannelData?[0] else {
            throw WhisperError.invalidAudioData
        }
        
        let frameCount = Int(ceil(Double(audioBuffer.frameLength) / Double(hopLength)))
        let melSpectrogram = try MLMultiArray(shape: [1, numMelBins as NSNumber, frameCount as NSNumber], 
                                            dataType: .float32)
        
        // Prepare FFT buffers
        var realIn = [Float](repeating: 0, count: windowLength)
        var imagIn = [Float](repeating: 0, count: windowLength)
        var realOut = [Float](repeating: 0, count: windowLength)
        var imagOut = [Float](repeating: 0, count: windowLength)
        
        for frame in 0..<frameCount {
            let startIdx = frame * hopLength
            let endIdx = min(startIdx + windowLength, Int(audioBuffer.frameLength))
            
            // Copy audio data for this frame
            if endIdx - startIdx == windowLength {
                memcpy(&realIn, channelData.advanced(by: startIdx), windowLength * MemoryLayout<Float>.size)
            } else {
                realIn = Array(UnsafeBufferPointer(start: channelData.advanced(by: startIdx),
                                                 count: endIdx - startIdx))
                realIn.append(contentsOf: Array(repeating: 0, count: windowLength - (endIdx - startIdx)))
            }
            
            // Apply Hanning window
            vDSP.multiply(realIn, hannWindow, result: &realIn)
            
            // Perform FFT
            guard let fftSetup = fftSetup else {
                throw WhisperError.processingError
            }
            
            vDSP_DFT_Execute(fftSetup,
                            realIn.withUnsafeBufferPointer { UnsafePointer($0.baseAddress!) },
                            imagIn.withUnsafeBufferPointer { UnsafePointer($0.baseAddress!) },
                            realOut.withUnsafeMutableBufferPointer { UnsafeMutablePointer($0.baseAddress!) },
                            imagOut.withUnsafeMutableBufferPointer { UnsafeMutablePointer($0.baseAddress!) })
            
            // Compute magnitude spectrum
            var magnitudes = [Float](repeating: 0, count: windowLength/2 + 1)
            vDSP.absolute(realOut, imagOut, result: &magnitudes)
            
            // Convert to mel scale
            let melEnergies = melFilterbank.transform(magnitudes)
            
            // Convert to log scale and normalize
            vDSP.convert(amplitude: melEnergies, toDecibels: &melEnergies,
                        zeroReference: Float(1.0), multiplier: Float(10.0))
            
            // Store in MLMultiArray
            for (binIdx, energy) in melEnergies.enumerated() {
                melSpectrogram[[0, binIdx as NSNumber, frame as NSNumber]] = energy as NSNumber
            }
        }
        
        // Normalize
        let mean: Float = -4.2677393
        let std: Float = 4.5689974
        vDSP.subtract(mean, melSpectrogram.dataPointer.assumingMemoryBound(to: Float.self),
                     result: melSpectrogram.dataPointer.assumingMemoryBound(to: Float.self),
                     count: melSpectrogram.count)
        vDSP.divide(melSpectrogram.dataPointer.assumingMemoryBound(to: Float.self),
                   std,
                   result: melSpectrogram.dataPointer.assumingMemoryBound(to: Float.self),
                   count: melSpectrogram.count)
        
        return melSpectrogram
    }
    
    // MARK: - Inference
    func transcribe(audioBuffer: AVAudioPCMBuffer, completion: @escaping (Result<String, Error>) -> Void) {
        modelQueue.async {
            do {
                // Preprocessing
                let melSpectrogram = try self.generateMelSpectrogram(from: audioBuffer)
                
                // Limit the spectrogram length to the model's maximum input length
                let maxFrames = 3000 // Adjust based on model capacity
                if melSpectrogram.count > maxFrames {
                    melSpectrogram = Array(melSpectrogram.prefix(maxFrames))
                }

                // Prepare input for the model
                let modelInput = try self.prepareModelInput(from: melSpectrogram)
                
                // Run inference
                guard let model = self.model else {
                    throw WhisperError.modelNotLoaded
                }
                let prediction = try model.prediction(melSpectrogram: modelInput)
                
                // Postprocessing
                let transcription = try self.decodePrediction(prediction)
                
                completion(.success(transcription))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func processModelOutput(_ output: MLMultiArray) throws -> String {
        // Process logits to text tokens
        var logits = [Float](repeating: 0, count: output.count)
        memcpy(&logits, output.dataPointer, output.count * MemoryLayout<Float>.size)
        
        // Apply softmax
        var maxLogit: Float = -Float.infinity
        vDSP_maxv(logits, 1, &maxLogit, vDSP_Length(logits.count))
        vDSP_vsub(logits, 1, [maxLogit], 1, &logits, 1, vDSP_Length(logits.count))
        var expLogits = [Float](repeating: 0, count: logits.count)
        vvexpf(&expLogits, logits, [Int32(logits.count)])
        var sum: Float = 0
        vDSP_sve(expLogits, 1, &sum, vDSP_Length(expLogits.count))
        vDSP_vsdiv(expLogits, 1, &sum, &expLogits, 1, vDSP_Length(expLogits.count))
        
        // Get top k indices
        let k = 5
        var indices = [Int](0..<expLogits.count)
        indices.sort { expLogits[$0] > expLogits[$1] }
        indices = Array(indices.prefix(k))
        
        // Convert indices to tokens and join
        let tokens = try indices.map { try WhisperTokenizer.shared.indexToToken($0) }
        return tokens.joined(separator: " ")
    }
    
    private func prepareModelInput(from melSpectrogram: [[Float]]) throws -> MLMultiArray {
        let melFrames = melSpectrogram.count
        let melBins = melSpectrogram[0].count

        // Create MLMultiArray in the correct shape [1, 80, n_frames]
        let melShape = [1, melBins as NSNumber, melFrames as NSNumber]
        let melArray = try MLMultiArray(shape: melShape, dataType: .float32)
        
        // Flatten the 2D array and copy data
        let flattenedMels = melSpectrogram.flatMap { $0 }
        let pointer = melArray.dataPointer.bindMemory(to: Float32.self, capacity: flattenedMels.count)
        pointer.assign(from: flattenedMels, count: flattenedMels.count)
        
        return melArray
    }
}

// MARK: - Mel Filterbank
private class MelFilterbank {
    private let filterbank: [[Float]]
    
    init(sampleRate: Int, nFft: Int, nMels: Int, fMin: Double, fMax: Double) {
        // Convert Hz to mel
        func hzToMel(_ hz: Double) -> Double {
            return 2595 * log10(1 + hz/700)
        }
        
        // Convert mel to Hz
        func melToHz(_ mel: Double) -> Double {
            return 700 * (pow(10, mel/2595) - 1)
        }
        
        let fMin = max(0, fMin)
        let fMax = min(Double(sampleRate)/2, fMax)
        
        let melMin = hzToMel(fMin)
        let melMax = hzToMel(fMax)
        
        // Create mel scale
        let melPoints = (0..<nMels+2).map { i in
            melMin + (Double(i) * (melMax - melMin)/Double(nMels + 1))
        }
        let hzPoints = melPoints.map { melToHz($0) }
        
        // Convert to FFT bins
        let fftFreqs = (0...nFft/2).map { Double($0) * Double(sampleRate)/Double(nFft) }
        
        // Create filterbank matrix
        var filters = [[Float]](repeating: [Float](repeating: 0, count: nFft/2 + 1), count: nMels)
        
        for i in 0..<nMels {
            let leftMel = hzPoints[i]
            let centerMel = hzPoints[i + 1]
            let rightMel = hzPoints[i + 2]
            
            for j in 0...nFft/2 {
                let freq = fftFreqs[j]
                
                if freq > leftMel && freq < rightMel {
                    if freq <= centerMel {
                        filters[i][j] = Float((freq - leftMel)/(centerMel - leftMel))
                    } else {
                        filters[i][j] = Float((rightMel - freq)/(rightMel - centerMel))
                    }
                }
            }
        }
        
        self.filterbank = filters
    }
    
    func transform(_ magnitudes: [Float]) -> [Float] {
        var melEnergies = [Float](repeating: 0, count: filterbank.count)
        
        for (i, filter) in filterbank.enumerated() {
            var sum: Float = 0
            vDSP_dotpr(filter, 1, magnitudes, 1, &sum, vDSP_Length(magnitudes.count))
            melEnergies[i] = sum
        }
        
        return melEnergies
    }
}

// MARK: - Errors
enum WhisperError: Error {
    case modelNotLoaded
    case invalidAudioData
    case processingError
    case transcriptionFailed
    case tokenizationError
}

// MARK: - Helper Extensions
extension WhisperModelManager {
    func isModelLoaded() -> Bool {
        return model != nil
    }
    
    func unloadModel() {
        model = nil
    }
    
    func reloadModel() {
        unloadModel()
        loadModel()
    }
}