import WidgetKit
import SwiftUI

@main
struct TranscriptionWidget: Widget {
    private let kind = "TranscriptionWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: TranscriptionTimelineProvider()
        ) { entry in
            TranscriptionWidgetView(entry: entry)
        }
        .configurationDisplayName("Recent Transcriptions")
        .description("Shows your most recent transcriptions.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TranscriptionEntry: TimelineEntry {
    let date: Date
    let transcriptions: [TranscriptionRecord]
}

struct TranscriptionWidgetView: View {
    var entry: TranscriptionEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(entry.transcriptions.prefix(3), id: \.id) { transcription in
                Text(transcription.text ?? "No Transcription")
                    .font(.body)
                    .lineLimit(1)
            }
        }
        .padding()
    }
}

struct TranscriptionTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> TranscriptionEntry {
        TranscriptionEntry(date: Date(), transcriptions: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TranscriptionEntry) -> Void) {
        let entry = TranscriptionEntry(
            date: Date(),
            transcriptions: CoreDataStack.shared.fetchRecentTranscriptions(limit: 3)
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TranscriptionEntry>) -> Void) {
        let entries = [
            TranscriptionEntry(
                date: Date(),
                transcriptions: CoreDataStack.shared.fetchRecentTranscriptions(limit: 3)
            )
        ]
        
        let timeline = Timeline(entries: entries, policy: .after(Date().addingTimeInterval(3600)))
        completion(timeline)
    }
} 