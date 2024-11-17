import ActivityKit
import WidgetKit
import SwiftUI

struct RecordingWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RecordingAttributes.self) { context in
            // Lock screen/banner UI
            LiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "mic.fill")
                        .foregroundColor(.red)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(formattedElapsedTime(context.state.elapsedTime))
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text("Recording...")
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.transcriptionProgress)
                        .font(.caption)
                        .lineLimit(1)
                }
            } compactLeading: {
                Image(systemName: "mic.fill")
                    .foregroundColor(.red)
            } compactTrailing: {
                Text(formattedElapsedTime(context.state.elapsedTime))
            } minimal: {
                Image(systemName: "mic.fill")
                    .foregroundColor(.red)
            }
        }
    }
    
    private func formattedElapsedTime(_ elapsedTime: TimeInterval) -> String {
        let totalSeconds = Int(elapsedTime)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
} 