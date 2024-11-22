import Foundation

extension Transcription {
    func dateFormattedString() -> String {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: self.created_at) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else {
            return self.created_at
        }
    }
    
    // If 'audioFileName' and 'getAudioFileURL' are not defined, you may need to remove or update the 'audioURL' property
    /*
    var audioURL: URL? {
        // Implement according to your app's logic or remove if not applicable
    }
    */
} 