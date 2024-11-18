class PerformanceMonitor {
    static let shared = PerformanceMonitor()
    
    func startTranscriptionMetrics() -> OSSignpostID {
        let signpostID = OSSignpostID(log: .default)
        os_signpost(.begin, log: .default, name: "Transcription", signpostID: signpostID)
        return signpostID
    }
    
    func endTranscriptionMetrics(_ signpostID: OSSignpostID) {
        os_signpost(.end, log: .default, name: "Transcription", signpostID: signpostID)
    }
} 