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
}

extension Notification.Name {
    static let audioSessionInterrupted = Notification.Name("audioSessionInterrupted")
} 