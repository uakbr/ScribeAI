import Foundation
import ActivityKit

class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private var activity: Activity<RecordingAttributes>?
    
    private init() {}
    
    // Start the Live Activity
    func startLiveActivity(sessionName: String) {
        let initialContentState = RecordingAttributes.ContentState(
            elapsedTime: 0,
            transcriptionProgress: "Starting transcription..."
        )
        
        let attributes = RecordingAttributes(sessionName: sessionName)
        
        do {
            activity = try Activity<RecordingAttributes>.request(
                attributes: attributes,
                contentState: initialContentState,
                pushType: nil
            )
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    // Update the Live Activity
    func updateLiveActivity(elapsedTime: TimeInterval, transcriptionProgress: String) {
        let updatedContentState = RecordingAttributes.ContentState(
            elapsedTime: elapsedTime,
            transcriptionProgress: transcriptionProgress
        )
        
        Task {
            await activity?.update(using: updatedContentState)
        }
    }
    
    // End the Live Activity
    func endLiveActivity() {
        Task {
            await activity?.end(dismissalPolicy: .immediate)
            activity = nil
        }
    }
} 