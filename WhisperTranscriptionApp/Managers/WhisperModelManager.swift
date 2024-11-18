class WhisperModelManager {
    static let shared = WhisperModelManager()
    private var model: WhisperModel?
    private let modelQueue = DispatchQueue(label: "com.app.whisper.model", qos: .userInitiated)
    private let modelURL = Bundle.main.url(forResource: "WhisperModel", withExtension: "mlmodel")
    
    private init() {
        loadModel()
    }
    
    private func loadModel() {
        guard let modelURL = modelURL else {
            assertionFailure("WhisperModel.mlmodel not found in bundle")
            return
        }
        
        do {
            let compiledModelURL = try MLModel.compileModel(at: modelURL)
            let config = MLModelConfiguration()
            config.computeUnits = .all // Use all available compute units
            model = try WhisperModel(contentsOf: compiledModelURL, configuration: config)
        } catch {
            assertionFailure("Failed to load Whisper model: \(error)")
        }
    }
    
    func transcribe(audioBuffer: [Float], bufferSize: Int, completion: @escaping (Result<String, Error>) -> Void) {
        modelQueue.async { [weak self] in
            guard let model = self?.model else {
                completion(.failure(WhisperError.modelNotLoaded))
                return
            }
            
            // Ensure audio buffer meets model requirements
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
                return "Whisper model failed to load"
            case .insufficientAudioData:
                return "Audio buffer too short for transcription"
            case .predictionFailed(let error):
                return "Model prediction failed: \(error.localizedDescription)"
            }
        }
    }
} 