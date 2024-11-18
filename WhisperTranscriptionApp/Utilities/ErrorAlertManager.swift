import UIKit

class ErrorAlertManager {
    static let shared = ErrorAlertManager()
    
    private init() {}
    
    func showAlert(title: String, message: String, in viewController: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString),
                   UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            let okAction = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(okAction)
            if title == "Microphone Access Denied" {
                alert.addAction(settingsAction)
            }
            viewController.present(alert, animated: true)
        }
    }
    
    func handleMicrophonePermissionError(in viewController: UIViewController) {
        let message = "Microphone access is required to record audio. Please enable it in Settings."
        showAlert(title: "Microphone Access Denied", message: message, in: viewController)
    }
    
    func handleRecordingError(_ error: Error, in viewController: UIViewController) {
        showAlert(title: "Recording Error", message: error.localizedDescription, in: viewController)
    }
    
    func handleTranscriptionError(_ error: Error, in viewController: UIViewController) {
        showAlert(title: "Transcription Error", message: error.localizedDescription, in: viewController)
    }
    
    func handleStorageError(_ error: Error, in viewController: UIViewController) {
        showAlert(title: "Storage Error", message: error.localizedDescription, in: viewController)
    }
}

enum TranscriptionError: LocalizedError {
    case microphonePermissionDenied
    case modelLoadingFailed
    case transcriptionFailed(String)
    case audioRecordingFailed(String)
    case storageError(String)
    
    var errorDescription: String? {
        switch self {
        case .microphonePermissionDenied:
            return "Microphone access is required for recording. Please enable it in Settings."
        case .modelLoadingFailed:
            return "Failed to load the Whisper model. Please try reinstalling the app."
        case .transcriptionFailed(let message):
            return "Transcription failed: \(message)"
        case .audioRecordingFailed(let message):
            return "Recording failed: \(message)"
        case .storageError(let message):
            return "Storage error: \(message)"
        }
    }
}

enum AppError: LocalizedError {
    case audioSessionSetupFailed(Error)
    case recordingFailed(Error)
    case transcriptionFailed(Error)
    case storageError(Error)
    case modelLoadingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .audioSessionSetupFailed(let error):
            return "Failed to setup audio session: \(error.localizedDescription)"
        case .recordingFailed(let error):
            return "Recording failed: \(error.localizedDescription)"
        case .transcriptionFailed(let error):
            return "Transcription failed: \(error.localizedDescription)"
        case .storageError(let error):
            return "Storage operation failed: \(error.localizedDescription)"
        case .modelLoadingError(let error):
            return "Failed to load Whisper model: \(error.localizedDescription)"
        }
    }
}