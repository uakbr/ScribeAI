import Foundation

class DynamicIslandController {
    static let shared = DynamicIslandController()
    
    private init() {}
    
    // Start the Dynamic Island updates
    func startDynamicIsland(sessionName: String) {
        LiveActivityManager.shared.startRecordingActivity()
    }
    
    // Update the Dynamic Island with real-time data
    func updateDynamicIsland(elapsedTime: TimeInterval, transcriptionProgress: String) {
        LiveActivityManager.shared.updateRecordingProgress(duration: elapsedTime, transcription: transcriptionProgress)
    }
    
    // End the Dynamic Island updates
    func endDynamicIsland() {
        LiveActivityManager.shared.endRecordingActivity()
    }
}