import Foundation
import ActivityKit

class LiveActivityManager {
    static let shared = LiveActivityManager()
    private var currentActivity: Activity<RecordingAttributes>?
    
    func startRecordingActivity() {
        let attributes = RecordingAttributes()
        let initialContentState = RecordingAttributes.ContentState(
            isRecording: true,
            duration: 0,
            transcription: ""
        )
        do {
            let activity = try Activity.request(
                attributes: attributes,
                contentState: initialContentState
            )
            currentActivity = activity
        } catch {
            print("Failed to start Live Activity: \(error.localizedDescription)")
        }
    }
    
    func updateRecordingProgress(duration: TimeInterval, transcription: String) {
        guard let activity = currentActivity else {
            print("No active Live Activity to update")
            return
        }

        let updatedContentState = RecordingAttributes.ContentState(
            isRecording: true,
            duration: duration,
            transcription: transcription
        )

        Task {
            do {
                try await activity.update(using: updatedContentState)
            } catch {
                print("Error updating Live Activity: \(error.localizedDescription)")
            }
        }
    }
    
    func endRecordingActivity() {
        currentActivity?.end(dismissalPolicy: .immediate)
        currentActivity = nil
    }
} 