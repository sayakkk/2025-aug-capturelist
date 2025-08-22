import WidgetKit
import SwiftUI
import CoreData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), folders: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), folders: getFolders())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SimpleEntry(date: Date(), folders: getFolders())
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
    
    private func getFolders() -> [Folder] {
        // This would typically fetch from shared App Groups container
        // For now, return empty array - will be implemented in widget view
        return []
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let folders: [Folder]
}

struct CaptureListWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        CaptureListWidgetView(folders: entry.folders)
    }
}

struct CaptureListWidget: Widget {
    let kind: String = "CaptureListWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                CaptureListWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                CaptureListWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("CaptureList")
        .description("Manage your screenshots with quick access to folders.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

#Preview(as: .systemMedium) {
    CaptureListWidget()
} timeline: {
    SimpleEntry(date: .now, folders: [])
} 