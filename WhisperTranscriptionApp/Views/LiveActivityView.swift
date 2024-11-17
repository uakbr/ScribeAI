import SwiftUI
import ActivityKit

struct LiveActivityView: View {
    let context: ActivityViewContext<RecordingAttributes>
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "mic.fill")
                    .foregroundColor(.red)
                Text("Recording...")
                    .font(.headline)
            }
            Text(formattedElapsedTime)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(context.state.transcriptionProgress)
                .font(.caption)
                .lineLimit(1)
                .foregroundColor(.primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground).opacity(0.8))
                .shadow(radius: 2)
        )
        .activitySystemActionForegroundColor(.primary)
    }

    var formattedElapsedTime: String {
        let duration = context.state.elapsedTime
        return String(format: "Duration: %02d:%02d", Int(duration) / 60, Int(duration) % 60)
    }
}

@available(iOSApplicationExtension 16.1, *)
struct LiveActivityView_Previews: PreviewProvider {
    static var previews: some View {
        let attributes = RecordingAttributes(sessionName: "Preview Session")
        let contentState = RecordingAttributes.ContentState(
            elapsedTime: 65,
            transcriptionProgress: "Hello, world!"
        )
        LiveActivityView(context: .init(attributes: attributes, state: contentState))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}