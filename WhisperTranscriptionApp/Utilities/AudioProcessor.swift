import Accelerate
import AVFoundation

class AudioProcessor {
    static let shared = AudioProcessor()
    
    private let targetSampleRate: Double = 16000
    private let targetChannels: AVAudioChannelCount = 1
    
    func processAudioBuffer(_ buffer: AVAudioPCMBuffer) throws -> [Float] {
        guard let channelData = buffer.floatChannelData else {
            throw AudioProcessingError.invalidBuffer
        }
        
        let frameCount = Int(buffer.frameLength)
        let channelCount = Int(buffer.format.channelCount)
        
        // Convert to mono if needed
        var monoBuffer: [Float]
        if channelCount > 1 {
            monoBuffer = [Float](repeating: 0, count: frameCount)
            for channel in 0..<channelCount {
                vDSP_vadd(channelData[channel], 1, monoBuffer, 1, monoBuffer, 1, vDSP_Length(frameCount))
            }
            var scale = Float(1.0 / Float(channelCount))
            vDSP_vsmul(monoBuffer, 1, &scale, monoBuffer, 1, vDSP_Length(frameCount))
        } else {
            monoBuffer = Array(UnsafeBufferPointer(start: channelData[0], count: frameCount))
        }
        
        // Resample if needed
        if buffer.format.sampleRate != targetSampleRate {
            return try resample(monoBuffer, from: buffer.format.sampleRate, to: targetSampleRate)
        }
        
        return monoBuffer
    }
    
    private func resample(_ buffer: [Float], from sourceRate: Double, to targetRate: Double) throws -> [Float] {
        let ratio = targetRate / sourceRate
        let outputLength = Int(Double(buffer.count) * ratio)
        var output = [Float](repeating: 0, count: outputLength)
        
        var resamplingInfo = vDSP_create_resample_filter(
            vDSP_Length(sourceRate),
            vDSP_Length(targetRate),
            vDSP_Length(20)  // Filter length
        )
        
        defer { vDSP_destroy_resample_filter(resamplingInfo) }
        
        var outputCount = vDSP_Length(outputLength)
        vDSP_resample(
            resamplingInfo!,
            buffer,
            nil,
            &output,
            vDSP_Length(buffer.count),
            &outputCount
        )
        
        return output
    }
    
    enum AudioProcessingError: LocalizedError {
        case invalidBuffer
        case resamplingFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidBuffer:
                return "Invalid audio buffer provided"
            case .resamplingFailed:
                return "Failed to resample audio"
            }
        }
    }
} 