import Foundation

class DynamicIslandController {
    static let shared = DynamicIslandController()
    
    private init() {}
    
    // Start the Dynamic Island updates
    func startDynamicIsland(sessionName: String) {
        LiveActivityManager.shared.startLiveActivity(sessionName: sessionName)
    }
    
    // Update the Dynamic Island with real-time data
    func updateDynamicIsland(elapsedTime: TimeInterval, transcriptionProgress: String) {
        LiveActivityManager.shared.updateLiveActivity(
            elapsedTime: elapsedTime,
            transcriptionProgress: transcriptionProgress
        )
    }
    
    // End the Dynamic Island updates
    func endDynamicIsland() {
        LiveActivityManager.shared.endLiveActivity()
    }
}