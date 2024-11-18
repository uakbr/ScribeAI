import UIKit
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var currentBackgroundTaskID: UIBackgroundTaskIdentifier?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playAndRecord,
                mode: .default,
                options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP, .mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)

            // Add background task handling
            application.beginReceivingRemoteControlEvents()
            setupNotifications()
        } catch {
            ErrorAlertManager.shared.handleAudioSessionError(error)
        }
        return true
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }

    @objc private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        switch type {
        case .began:
            // Pause or stop audio processing
            AudioTranscriber.shared.pauseTranscribing()
        case .ended:
            // Optionally resume audio processing
            do {
                try AudioTranscriber.shared.resumeTranscribing()
            } catch {
                print("Failed to resume transcribing: \(error.localizedDescription)")
            }
        @unknown default:
            break
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        currentBackgroundTaskID = application.beginBackgroundTask { [weak self] in
            self?.cleanupBackgroundTask()
        }
    }

    private func cleanupBackgroundTask() {
        if let taskID = currentBackgroundTaskID {
            UIApplication.shared.endBackgroundTask(taskID)
            currentBackgroundTaskID = nil
        }
    }
}