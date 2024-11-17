import Foundation
import ActivityKit

// MARK: - Live Activity Attributes
struct RecordingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var elapsedTime: TimeInterval
        var transcriptionProgress: String
    }
    
    var sessionName: String
}