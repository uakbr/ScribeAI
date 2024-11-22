import Foundation
import AVFoundation
import UserNotifications
import UIKit

class AudioSessionManager {
    static let shared = AudioSessionManager()
    private var audioSession: AVAudioSession
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {
        self.audioSession = AVAudioSession.sharedInstance()
        setupNotifications()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try configureAudioSession()
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: audioSession
        )
    }
    
    func configureAudioSession() throws {
        try audioSession.setCategory(
            .playAndRecord,
            mode: .spokenAudio,
            options: [
                .defaultToSpeaker,
                .allowBluetooth,
                .allowBluetoothA2DP,
                .mixWithOthers
            ]
        )
        try audioSession.setActive(true)
    }
    
    @objc private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSession.InterruptionTypeKey] as? UInt else {
            return
        }
        
        let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        switch type {
        case .began:
            // Handle interruption began
            NotificationCenter.default.post(name: .audioSessionInterrupted, object: nil)
        case .ended:
            guard let optionsValue = userInfo[AVAudioSession.InterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            
            if options.contains(.shouldResume) {
                try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            }
        @unknown default:
            break
        }
    }
    
    func requestPermissions() async throws -> Bool {
        // Request microphone permissions
        return try await audioSession.requestRecordPermission()
    }
    
    func activateAudioSession() throws {
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    func deactivateAudioSession() throws {
        try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let audioSessionInterrupted = Notification.Name("audioSessionInterrupted")
}

// MARK: - AudioSessionError
enum AudioSessionError: Error {
    case configurationFailed
    case activationFailed
    case permissionDenied
} 