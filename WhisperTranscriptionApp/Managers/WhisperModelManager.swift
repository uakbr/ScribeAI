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
        // Check if the model is already compiled in the cache directory
        if let compiledModelURL = getCompiledModelURL() {
            print("Loading compiled model from \(compiledModelURL.path)")
            loadModel(from: compiledModelURL)
            return
        }
        
        // Use NSBundleResourceRequest to download the model
        let resourceRequest = NSBundleResourceRequest(tags: ["WhisperModel"])
        resourceRequest.beginAccessingResources { [weak self] error in
            if let error = error {
                print("Failed to download model with error: \(error.localizedDescription)")
                // Handle error
                return
            }
            
            // After downloading, get the model URL
            guard let modelURL = Bundle.main.url(forResource: "WhisperModel", withExtension: "mlmodel") else {
                print("Model not found in bundle after download")
                return
            }
            
            do {
                // Compile the model
                let compiledURL = try MLModel.compileModel(at: modelURL)
                print("Model compiled at \(compiledURL.path)")
                self?.saveCompiledModelURL(compiledURL)
                self?.loadModel(from: compiledURL)
            } catch {
                print("Error compiling model: \(error.localizedDescription)")
                // Handle error
            }
        }
    }

    // Helper to get the compiled model URL from cache
    private func getCompiledModelURL() -> URL? {
        let compiledModelPath = NSTemporaryDirectory().appending("WhisperModel.mlmodelc")
        let compiledModelURL = URL(fileURLWithPath: compiledModelPath)
        if FileManager.default.fileExists(atPath: compiledModelURL.path) {
            return compiledModelURL
        }
        return nil
    }

    // Helper to save the compiled model URL
    private func saveCompiledModelURL(_ url: URL) {
        // Move compiled model to a known location
        let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory().appending("WhisperModel.mlmodelc"))
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.moveItem(at: url, to: destinationURL)
        } catch {
            print("Error moving compiled model: \(error.localizedDescription)")
        }
    }

    private func downloadModel() {
        let config = MLModelConfiguration()
        config.computeUnits = .all
        
        // Assuming you have a URL to download the compiled model
        let modelDownloadURL = URL(string: "https://yourserver.com/path/to/WhisperModel.mlmodelc")!
        
        let downloadTask = URLSession.shared.downloadTask(with: modelDownloadURL) { localURL, response, error in
            if let error = error {
                print("Error downloading model: \(error.localizedDescription)")
                // Handle download error appropriately
                return
            }
            
            guard let localURL = localURL else {
                print("Downloaded file URL is nil")
                return
            }
            
            do {
                // Move the downloaded model to the local model URL
                let modelURL = self.getLocalModelURL()
                try FileManager.default.moveItem(at: localURL, to: modelURL)
                print("Model downloaded and saved to \(modelURL.path)")
                
                // Load the model from the local URL
                self.loadModel(from: modelURL)
            } catch {
                print("Error saving model: \(error.localizedDescription)")
                // Handle file handling error
            }
        }
        downloadTask.resume()
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