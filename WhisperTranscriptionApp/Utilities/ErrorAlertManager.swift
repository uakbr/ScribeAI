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