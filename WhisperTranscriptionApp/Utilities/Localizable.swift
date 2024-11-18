enum L10n {
    enum Recording {
        static let start = NSLocalizedString(
            "recording.start",
            comment: "Button title to start recording"
        )
        static let stop = NSLocalizedString(
            "recording.stop",
            comment: "Button title to stop recording"
        )
        static let pause = NSLocalizedString(
            "recording.pause",
            comment: "Button title to pause recording"
        )
    }
    
    enum Errors {
        static let microphoneAccess = NSLocalizedString(
            "error.microphone.access",
            comment: "Error message when microphone access is denied"
        )
        static let transcriptionFailed = NSLocalizedString(
            "error.transcription.failed",
            comment: "Error message when transcription fails"
        )
    }
    
    enum Transcription {
        static let share = NSLocalizedString(
            "transcription.share",
            comment: "Button title to share transcription"
        )
        static let copy = NSLocalizedString(
            "transcription.copy",
            comment: "Button title to copy transcription"
        )
        static let delete = NSLocalizedString(
            "transcription.delete",
            comment: "Button title to delete transcription"
        )
    }
} 