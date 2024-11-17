import Foundation

extension Transcription {
    func dateFormattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self.date ?? Date())
    }
    
    var audioURL: URL? {
        guard let fileName = self.audioFileName else { return nil }
        return AudioFileStorage.shared.getAudioFileURL(fileName: fileName)
    }
} 