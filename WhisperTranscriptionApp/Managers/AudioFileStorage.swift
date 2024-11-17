import Foundation
import AVFoundation

class AudioFileStorage {
    static let shared = AudioFileStorage()
    
    private let fileManager = FileManager.default
    private var audioPlayer: AVAudioPlayer?
    private var progressTimer: Timer?
    private var progressHandler: ((Double) -> Void)?
    private var completionHandler: (() -> Void)?
    
    private init() {}
    
    // MARK: - File Management
    func getDocumentsDirectory() -> URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func generateAudioFileURL() -> URL {
        let fileName = "recording-\(Date().timeIntervalSince1970).m4a"
        return getDocumentsDirectory().appendingPathComponent(fileName)
    }
    
    func deleteAudioFile(at url: URL) {
        do {
            try fileManager.removeItem(at: url)
        } catch {
            ErrorAlertManager.shared.showAlert(
                title: "Delete Error",
                message: "Failed to delete audio file: \(error.localizedDescription)"
            )
        }
    }
    
    // MARK: - Audio Playback
    func playAudioFile(at url: URL, progressHandler: ((Double) -> Void)? = nil, completionHandler: (() -> Void)? = nil) {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            self.progressHandler = progressHandler
            self.completionHandler = completionHandler
            
            // Start progress timer
            progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self, let player = self.audioPlayer else { return }
                self.progressHandler?(player.currentTime / player.duration)
            }
            
        } catch {
            ErrorAlertManager.shared.showAlert(
                title: "Playback Error",
                message: "Failed to play audio file: \(error.localizedDescription)"
            )
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        progressTimer?.invalidate()
        progressTimer = nil
        progressHandler = nil
        completionHandler = nil
    }
    
    // MARK: - File Information
    func getAudioDuration(at url: URL) -> TimeInterval? {
        do {
            let audio = try AVAudioFile(forReading: url)
            return Double(audio.length) / audio.processingFormat.sampleRate
        } catch {
            ErrorAlertManager.shared.showAlert(
                title: "File Error",
                message: "Failed to get audio duration: \(error.localizedDescription)"
            )
            return nil
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioFileStorage: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlayback()
        completionHandler?()
    }
}