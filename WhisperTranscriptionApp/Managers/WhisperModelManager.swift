class WhisperModelManager {
    static let shared = WhisperModelManager()
    private let queue = DispatchQueue(label: "com.app.whispermodel", qos: .userInitiated)
    private let modelLock = NSLock()
    
    func transcribe(audioBuffer: [Float], bufferSize: Int, completion: @escaping (Result<String, Error>) -> Void) {
        queue.async { [weak self] in
            self?.modelLock.lock()
            defer { self?.modelLock.unlock() }
            
            guard let model = self?.model else {
                completion(.failure(WhisperError.modelNotLoaded))
                return
            }
            
            do {
                let prediction = try model.prediction(audio: audioBuffer)
                completion(.success(prediction.transcription))
            } catch {
                completion(.failure(WhisperError.predictionFailed(error)))
            }
        }
    }
    
    enum WhisperError: LocalizedError {
        case modelNotLoaded
        case predictionFailed(Error)
        
        var errorDescription: String? {
            switch self {
            case .modelNotLoaded:
                return "Whisper model is not loaded"
            case .predictionFailed(let error):
                return "Prediction failed: \(error.localizedDescription)"
            }
        }
    }
} 