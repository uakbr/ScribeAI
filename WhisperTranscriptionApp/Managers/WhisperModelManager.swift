import Foundation
import CoreML

class WhisperModelManager {
    static let shared = WhisperModelManager()
    private var model: WhisperModel?
    private let modelQueue = DispatchQueue(label: "com.app.whisper.model", qos: .userInitiated)
    private let modelDownloadTag = "WhisperModel"
    private var modelURL: URL? {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let modelURL = documentDirectory.appendingPathComponent("WhisperModel.mlmodelc")
        return fileManager.fileExists(atPath: modelURL.path) ? modelURL : nil
    }

    private init() {
        loadModel()
    }

    private func loadModel() {
        if let localModelURL = modelURL {
            loadModel(from: localModelURL)
        } else {
            downloadModel()
        }
    }

    private func downloadModel() {
        let resourceRequest = NSBundleResourceRequest(tags: [modelDownloadTag])
        resourceRequest.beginAccessingResources { [weak self] error in
            if let error = error {
                print("Error downloading model: \(error.localizedDescription)")
                // Handle download error
                return
            }
            guard let modelURL = Bundle.main.url(forResource: "WhisperModel", withExtension: "mlmodelc") else {
                print("Model not found in bundle after download")
                return
            }
            self?.saveModelToDocuments(modelURL)
        }
    }

    private func saveModelToDocuments(_ modelURL: URL) {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentDirectory.appendingPathComponent("WhisperModel.mlmodelc")
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: modelURL, to: destinationURL)
            loadModel()
        } catch {
            print("Error saving model to documents directory: \(error.localizedDescription)")
        }
    }

    private func loadModel(from url: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let config = MLModelConfiguration()
                config.computeUnits = .all
                let loadedModel = try WhisperModel(contentsOf: url, configuration: config)
                self?.model = loadedModel
                print("Whisper model loaded successfully.")
            } catch {
                print("Error loading model: \(error.localizedDescription)")
                // Handle model loading error
            }
        }
    }

    func transcribe(audioBuffer: [Float], completion: @escaping (Result<String, Error>) -> Void) {
        modelQueue.async { [weak self] in
            guard let model = self?.model else {
                completion(.failure(WhisperError.modelNotLoaded))
                return
            }

            guard audioBuffer.count >= 480000 else { // Minimum 30 seconds at 16kHz
                completion(.failure(WhisperError.insufficientAudioData))
                return
            }

            do {
                let input = WhisperModelInput(audioInput: audioBuffer)
                let output = try model.prediction(input: input)
                completion(.success(output.transcription))
            } catch {
                completion(.failure(WhisperError.predictionFailed(error)))
            }
        }
    }

    enum WhisperError: LocalizedError {
        case modelNotLoaded
        case insufficientAudioData
        case predictionFailed(Error)

        var errorDescription: String? {
            switch self {
            case .modelNotLoaded:
                return "Whisper model failed to load."
            case .insufficientAudioData:
                return "Audio buffer too short for transcription."
            case .predictionFailed(let error):
                return "Model prediction failed: \(error.localizedDescription)"
            }
        }
    }
} 