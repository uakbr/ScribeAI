import Foundation
import ActivityKit

class LiveActivityManager {
    static let shared = LiveActivityManager()
    private var currentActivity: Activity<RecordingAttributes>?
    
    func startRecordingActivity() async throws {
        let attributes = RecordingAttributes()
        let contentState = RecordingAttributes.ContentState(
            isRecording: true,
            duration: 0,
            transcription: ""
        )
        
        do {
            let activity = try await Activity.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
            currentActivity = activity
        } catch {
            throw LiveActivityError.activityRequestFailed(error)
        }
    }
    
    func updateRecordingProgress(duration: TimeInterval, transcription: String) async {
        guard let activity = currentActivity else {
            print("No active Live Activity to update")
            return
        }

        let updatedState = RecordingAttributes.ContentState(
            isRecording: true,
            duration: duration,
            transcription: transcription
        )

        do {
            try await activity.update(using: updatedState)
        } catch {
            print("Error updating Live Activity: \(error.localizedDescription)")
        }
    }
    
    func endRecording() async {
        guard let activity = currentActivity else { return }
        
        let finalState = RecordingAttributes.ContentState(
            isRecording: false,
            duration: 0,
            transcription: ""
        )
        
        await activity.end(
            ActivityContent(state: finalState, staleDate: nil),
            dismissalPolicy: .immediate
        )
        
        currentActivity = nil
    }
    
    enum LiveActivityError: LocalizedError {
        case activityRequestFailed(Error)
        case noActiveRecording
        
        var errorDescription: String? {
            switch self {
            case .activityRequestFailed(let error):
                return "Failed to start recording activity: \(error.localizedDescription)"
            case .noActiveRecording:
                return "No active recording found"
            }
        }
    }
} 