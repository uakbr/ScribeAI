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