//
//  LockFlowingWidget.swift
//  FlowingWidgetExtension
//
//  Created by Saúl González on 9/04/24.
//

import WidgetKit
import SwiftUI
import SwiftData

// Define the structure for a single entry in the timeline
struct LockSimpleEntry: TimelineEntry {
    let date: Date
    let providerInfo: String
}

// View for the main widget
struct LockFlowingWidgetView: View {
    let entry: LockSimpleEntry
    
    // Obtain the widget family value
    @Environment(\.widgetFamily)
    var family
    
    var body: some View {
        // Choose the appropriate view based on the widget family
        switch family {
        case .accessoryRectangular:
            RectangularWidgetView(entry: entry)
                .containerBackground(for: .widget){}
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
                .containerBackground(for: .widget){}
        default:
            InlineWidgetView(entry: entry)
        }
    }
}

// View for the inline widget family
struct InlineWidgetView: View {
    @Query(animation: .bouncy) private var taskItems: [taskItem]
    var entry: LockProvider.Entry
    
    var body: some View {
        if let firstMatchingItem = taskItems.first(where: { (isToday($0.days) && checkCurrentTime(start: $0.start, end: $0.end)) || ($0.days == "0000000" && checkCurrentTime(start: $0.start, end: $0.end))}) {
            Text(firstMatchingItem.name)
        } else {
            Text("Free Time")
        }
    }
}

// View for the rectangular widget family
struct RectangularWidgetView: View {
    @Query(animation: .bouncy) private var taskItems: [taskItem]
    var entry: LockProvider.Entry
    
    var body: some View {
        HStack {
            if let firstMatchingItem = taskItems.first(where: { (isToday($0.days) && checkCurrentTime(start: $0.start, end: $0.end)) || ($0.days == "0000000" && checkCurrentTime(start: $0.start, end: $0.end))}) {
                Image(systemName: firstMatchingItem.symbol)
                    .font(.title2)
                    .fontWeight(.heavy)
                Text(firstMatchingItem.name)
                    .fontWeight(.bold)
            } else {
                Image(systemName: "clock")
                    .font(.title2)
                    .fontWeight(.heavy)
                Text("Free Time")
                    .fontWeight(.bold)
            }
        }
    }
}

// View for the circular widget family
struct CircularWidgetView: View {
    @Query(animation: .bouncy) private var taskItems: [taskItem]
    var entry: LockProvider.Entry
    
    var body: some View {
        ZStack {
            if let firstMatchingItem = taskItems.first(where: { (isToday($0.days) && checkCurrentTime(start: $0.start, end: $0.end)) || ($0.days == "0000000" && checkCurrentTime(start: $0.start, end: $0.end))}) {
                Image(systemName: firstMatchingItem.symbol)
                    .font(.system(size: 35))
                    .fontWeight(.heavy)
            } else {
                Image(systemName: "clock")
                    .font(.system(size: 35))
                    .fontWeight(.heavy)
            }
        }
    }
}

// Timeline provider for the widget
struct LockProvider: TimelineProvider {
    typealias Entry = LockSimpleEntry
    
    // Placeholder entry for the widget
    func placeholder(in context: Context) -> Entry {
        LockSimpleEntry(date: Date(), providerInfo: "placeholder")
    }
    
    // Get a snapshot of the widget
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
        let entry = LockSimpleEntry(date: Date(), providerInfo: "snapshot")
        completion(entry)
    }
    
    // Generate the timeline for the widget
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = LockSimpleEntry(date: Date(), providerInfo: "timeline")
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(5)))
        completion(timeline)
    }
}

// Widget configuration
struct LockFlowingWidget: Widget {
    let kind: String = "LockFlowingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LockProvider()) { entry in
            LockFlowingWidgetView(entry: entry)
                .modelContainer(for: [taskItem.self, toDoItem.self, progressiveItem.self, settingsItem.self] )
        }
        .configurationDisplayName("Flowing Widget")
        .description("Shows the current task.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryInline,
            .accessoryRectangular
        ])
    }
}

