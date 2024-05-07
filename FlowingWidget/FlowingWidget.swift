//
//  FlowingWidget.swift
//  FlowingWidget
//
//  Created by Saúl González on 3/04/24.
//

import WidgetKit
import SwiftUI
import SwiftData

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct FlowingWidgetView: View {
    
    let entry: SimpleEntry
    
    
    var body: some View {
        
        HomeScreenWidgetView(entry: entry)
            .containerBackground(.fill.quinary, for: .widget)
        
    }
}


struct HomeScreenWidgetView : View {
    
    @Environment(\.modelContext) private var context
    @Query(animation: .bouncy) private var taskItems: [taskItem]
    
    var entry: Provider.Entry
    
    var body: some View {
        
        VStack {
            if let firstMatchingItem = taskItems.first(where: { (isToday($0.days) && checkCurrentTime(start: $0.start, end: $0.end)) || ($0.days == "0000000" && checkCurrentTime(start: $0.start, end: $0.end))}) {
                
                let color: Color = Color(hex: firstMatchingItem.color)!
                
                if entry.configuration.topText?.use == "Name" {
                    Text(firstMatchingItem.name)
                        .font(.callout)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .foregroundStyle(color.opacity(0.75))
                    
                } else if entry.configuration.topText?.use == "Time Range" {
                    Text(formatTaskTime(start: firstMatchingItem.start, end: firstMatchingItem.end))
                        .font(.callout)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .foregroundStyle(color.opacity(0.75))
                    
                }
                Spacer()
                Image(systemName: firstMatchingItem.symbol)
                    .font(.system(size: 65))
                    .fontWeight(.heavy)
                    .foregroundStyle(Color(hex: firstMatchingItem.color)!)
                    .frame(width: 60, height: 60)
                
                Spacer()
                if entry.configuration.bottomText?.use == "Name" {
                    Text(firstMatchingItem.name)
                        .font(.callout)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .foregroundStyle(color.opacity(0.75))

                    
                } else if entry.configuration.bottomText?.use == "Time Range" {
                    Text(formatTaskTime(start: firstMatchingItem.start, end: firstMatchingItem.end))
                        .font(.callout)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .foregroundStyle(color.opacity(0.75))
                    
                }
                
            } else {
                Image(systemName: "clock")
                    .font(.system(size: 65))
                    .fontWeight(.heavy)
                    .frame(width: 60, height: 60)
            }
        }
    }
}


struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(5)))

        return timeline
    }
}



struct FlowingWidget: Widget {
    let kind: String = "FlowingWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            FlowingWidgetView(entry: entry)
                .modelContainer(for: [taskItem.self, toDoItem.self, progressiveItem.self, settingsItem.self] )
        }
        .configurationDisplayName("Flowing Widget")
        .description("Shows the current task.")
        .supportedFamilies([
            .systemSmall
        ])
    }
}



