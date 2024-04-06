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
    let providerInfo: String
}

struct FlowingWidgetView: View {

    let entry: SimpleEntry

    // Obtain the widget family value
    @Environment(\.widgetFamily)
    var family

    var body: some View {

        switch family {
        case .accessoryRectangular:
            RectangularWidgetView(entry: entry)
                .containerBackground(for: .widget){}
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
                .containerBackground(for: .widget){}
        case .accessoryInline:
            InlineWidgetView(entry: entry)
        default:
            // UI for Home Screen widget
            HomeScreenWidgetView(entry: entry)
                .containerBackground(.fill.quinary, for: .widget)
        }
    }
}

struct InlineWidgetView: View {
    
    @Query(animation: .bouncy) private var taskItems: [taskItem]
    
    var entry: Provider.Entry
    
    var body: some View {
        if let firstMatchingItem = taskItems.first(where: { isToday($0.days) && checkCurrentTime(start: $0.start, end: $0.end) }) {
            
                Text(firstMatchingItem.name)
                
            }
        else {
            Text("Free Time")
        }
            
    }
}

struct RectangularWidgetView: View {
    
    @Query(animation: .bouncy) private var taskItems: [taskItem]
    
    var entry: Provider.Entry
    
    var body: some View {
        HStack {
            if let firstMatchingItem = taskItems.first(where: { isToday($0.days) && checkCurrentTime(start: $0.start, end: $0.end) }) {
                
                
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

struct CircularWidgetView: View {
    
    @Query(animation: .bouncy) private var taskItems: [taskItem]
    
    var entry: Provider.Entry
    
    var body: some View {
        
            ZStack {
                if let firstMatchingItem = taskItems.first(where: { isToday($0.days) && checkCurrentTime(start: $0.start, end: $0.end) }) {
                    
                    
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

struct HomeScreenWidgetView : View {
    
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
                    .font(.system(size: 65))
                    .fontWeight(.heavy)
                    .frame(width: 60, height: 60)
            }
        }
        .onAppear{
            if settingsItems.isEmpty {
                newSettings(context)
            }
            
        }
    }
}

struct Provider: TimelineProvider {
    
    typealias Entry = SimpleEntry
    
    
    
    
    func placeholder(in context: Context) -> Entry {
        SimpleEntry(date: Date(), providerInfo: "placeholder")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
        let entry = SimpleEntry(date: Date(), providerInfo: "snapshot")
        completion(entry)
    }
    
    
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        let entry = SimpleEntry(date: Date(), providerInfo: "timeline")
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(5)))
        completion(timeline)
    }
}



struct FlowingWidget: Widget {
    let kind: String = "FlowingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FlowingWidgetView(entry: entry)
                .modelContainer(for: [taskItem.self, toDoItem.self, progressiveItem.self, settingsItm.self] )
        }
        .configurationDisplayName("Flowing Widget")
        .description("Shows the current task.")
        .supportedFamilies([
            .systemSmall,
            //.systemMedium,
            //.systemLarge,
            
            .accessoryCircular,
            .accessoryInline,
            .accessoryRectangular
        ])
    }
}

