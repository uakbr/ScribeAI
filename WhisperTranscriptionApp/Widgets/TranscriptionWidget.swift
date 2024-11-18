import WidgetKit
import SwiftUI

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
        .description("Shows your most recent transcriptions")
        .supportedFamilies([.systemSmall, .systemMedium])
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
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
} 