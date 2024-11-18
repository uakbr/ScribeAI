import UIKit

class ErrorAlertManager {
    static let shared = ErrorAlertManager()
    
    func handleError(_ error: Error, domain: ErrorDomain, in viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))

        // Present the alert on the main thread
        DispatchQueue.main.async {
            viewController.present(alert, animated: true)
        }
    }
    
    func handleAudioSessionError(_ error: Error) {
        // Handle audio session errors
        print("Audio session error: \(error.localizedDescription)")
    }
    
    enum ErrorDomain {
        case transcription
        case audio
        case network
        // Add other domains as needed
    }
}