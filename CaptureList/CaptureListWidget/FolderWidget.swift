//
//  FolderWidget.swift
//  CaptureListWidget
//
//  Target: CaptureListWidget
//

import WidgetKit
import SwiftUI
import Intents

struct FolderWidgetEntry: TimelineEntry {
    let date: Date
}

struct FolderWidgetEntryView : View {
    var entry: FolderWidgetEntry

    var body: some View {
        VStack {
            Text("Folders Widget")
                .font(.headline)
            HStack {
                ForEach(0..<4) { _ in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                }
                RoundedRectangle(cornerRadius: 8)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .frame(width: 60, height: 60)
                    .overlay(Text("+"))
            }
        }
        .padding()
    }
}

struct FolderWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> FolderWidgetEntry {
        FolderWidgetEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (FolderWidgetEntry) -> ()) {
        completion(FolderWidgetEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FolderWidgetEntry>) -> ()) {
        let timeline = Timeline(entries: [FolderWidgetEntry(date: Date())], policy: .never)
        completion(timeline)
    }
}

struct FolderWidget: Widget {
    let kind: String = "FolderWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FolderWidgetProvider()) { entry in
            FolderWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("CaptureList Widget")
        .description("Organize your screenshots into folders.")
    }
}
