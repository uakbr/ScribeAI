class AudioSessionManager {
    static let shared = AudioSessionManager()
    private let session = AVAudioSession.sharedInstance()
    
    func configureAudioSession() throws {
        try session.setCategory(
            .playAndRecord,
            mode: .spokenAudio,
            options: [
                .defaultToSpeaker,
                .allowBluetooth,
                .allowBluetoothA2DP,
                .mixWithOthers
            ]
        )
        try session.setActive(true)
    }
    
    func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        NotificationCenter.default.post(
            name: .audioSessionInterrupted,
            object: nil,
            userInfo: ["type": type]
        )
    }

    func setupNotificationObservers() {
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
            try? AudioTranscriber.shared.resumeTranscribing()
        @unknown default:
            break
        }
    }
}

extension Notification.Name {
    static let audioSessionInterrupted = Notification.Name("audioSessionInterrupted")
} 