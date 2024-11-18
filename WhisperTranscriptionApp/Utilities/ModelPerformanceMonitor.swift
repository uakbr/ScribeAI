import os.log

class ModelPerformanceMonitor {
    static let shared = ModelPerformanceMonitor()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ModelPerformance")
    
    private var metrics: [String: [TimeInterval]] = [:]
    private let queue = DispatchQueue(label: "com.app.modelperformance")
    
    func startTranscription() -> OSSignpostID {
        let signpostID = OSSignpostID(log: .default)
        os_signpost(.begin, log: .default, name: "Transcription", signpostID: signpostID)
        return signpostID
    }
    
    func endTranscription(_ signpostID: OSSignpostID, duration: TimeInterval, audioLength: TimeInterval) {
        os_signpost(.end, log: .default, name: "Transcription", signpostID: signpostID)
        
        queue.async { [weak self] in
            self?.logMetrics(duration: duration, audioLength: audioLength)
        }
    }
    
    private func logMetrics(duration: TimeInterval, audioLength: TimeInterval) {
        let processingRatio = duration / audioLength
        logger.info("Transcription completed - Processing time: \(duration)s, Audio length: \(audioLength)s, Ratio: \(processingRatio)")
        
        if processingRatio > 1.0 {
            logger.warning("Transcription taking longer than real-time")
        }
    }
} 