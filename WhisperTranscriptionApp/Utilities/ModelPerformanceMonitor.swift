import Foundation
import os.log

class ModelPerformanceMonitor {
    static let shared = ModelPerformanceMonitor()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "WhisperTranscriptionApp", category: "ModelPerformance")
    
    private init() {}
    
    func logTranscriptionPerformance(duration: TimeInterval, audioLength: TimeInterval) {
        logger.log("Transcription completed - Processing time: \(duration)s for \(audioLength)s of audio")
        
        // Calculate real-time factor
        let rtf = duration / audioLength
        logger.log("Real-time factor: \(rtf)")
    }
    
    func logMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let usedMB = Double(info.resident_size) / 1024.0 / 1024.0
            logger.log("Memory used: \(usedMB) MB")
        }
    }
} 