import Foundation
import AVFoundation
import UIKit

class AudioSessionManager {
    static let shared = AudioSessionManager()
    private let audioSession = AVAudioSession.sharedInstance()
    private let notificationCenter = NotificationCenter.default
    
    private init() {
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
        notificationCenter.addObserver(
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
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // Handle interruption began
            notificationCenter.post(
                name: .audioSessionInterrupted,
                object: nil,
                userInfo: ["type": type]
            )
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            
            if options.contains(.shouldResume) {
                try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            }
        @unknown default:
            break
        }
    }
    
    func requestPermissions() async {
        await audioSession.requestRecordPermission()
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