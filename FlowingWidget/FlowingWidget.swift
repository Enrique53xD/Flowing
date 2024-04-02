//
//  FlowingWidget.swift
//  FlowingWidget
//
//  Created by Saúl González on 26/03/24.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider { // Update to TimelineProvider
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries: [SimpleEntry] = []

        let currentDate = Date()
        for secondOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .second, value: 30 * secondOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: ConfigurationAppIntent())
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct FlowingWidgetEntryView : View {
    @Environment(\.modelContext) private var context
    @Query(animation: .bouncy) private var taskItems: [taskItem]
    @Query(animation: .bouncy) private var settingsItems: [settingsItm]
    
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            if let firstMatchingItem = taskItems.first(where: { isToday($0.days) && checkCurrentTime(start: $0.start, end: $0.end) }) {
                
                if (settingsItems.first?.widgetName)! {
                    Text(firstMatchingItem.name)
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundStyle(.opacity(0.5))
                    
                }
                Spacer()
                Image(systemName: firstMatchingItem.symbol)
                    .font(.system(size: 65))
                    .fontWeight(.heavy)
                    .foregroundStyle(Color(hex: firstMatchingItem.color)!)
                    .frame(width: 60, height: 60)
                
                Spacer()
                if (settingsItems.first?.widgetRange)! {
                    Text(formatTaskTime(start: firstMatchingItem.start, end: firstMatchingItem.end))
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundStyle(.opacity(0.5))
                    
                }
            } else {
                Image(systemName: "clock")
                    .font(.system(size: 75))
                    .fontWeight(.heavy)
                    .frame(width: 60, height: 60)
            }
        }
        .onAppear{if settingsItems.isEmpty {
            newSettings(context)
        }
            
        }
    }
}
struct FlowingWidget: Widget {
    let kind: String = "FlowingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FlowingWidgetEntryView(entry: entry)
                .containerBackground(.fill.quaternary, for: .widget)
                .modelContainer(for: [taskItem.self, toDoItem.self, progressiveItem.self, settingsItm.self] )
        }
        .configurationDisplayName("Flowing Widget")
        .description("Display a flowing widget in a small size.")
        .supportedFamilies([.systemSmall]) // Limit the widget to a small size
    }
}


