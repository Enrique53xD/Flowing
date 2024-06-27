//
//  FlowingWidget.swift
//  FlowingWidget
//
//  Created by Saúl González on 3/04/24.
//

import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Timeline Entry

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

// MARK: - Flowing Widget View

struct FlowingWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        HomeScreenWidgetView(entry: entry)
            .containerBackground(.fill.quinary, for: .widget)
    }
}

// MARK: - Home Screen Widget View

struct HomeScreenWidgetView : View {
    @Environment(\.modelContext) private var context
    @Query(animation: .bouncy) private var taskItems: [taskItem]
    @State private var scaleValue = 1.0
    
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            if let firstMatchingItem = taskItems.first(where: { (isToday($0.days) && checkCurrentTime(start: $0.start, end: $0.end)) || ($0.days == "0000000" && checkCurrentTime(start: $0.start, end: $0.end))}) {
                let color: Color = Color(hex: firstMatchingItem.color)!
                
                if entry.configuration.topText.rawValue == "Name" {
                    Text(firstMatchingItem.name)
                        .font(.callout)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .foregroundStyle(color.opacity(0.75))
                        .onAppear{scaleValue -= 0.175}
                    
                } else if entry.configuration.topText.rawValue == "Time Range" {
                    Text(formatTaskTime(start: firstMatchingItem.start, end: firstMatchingItem.end))
                        .font(.callout)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .foregroundStyle(color.opacity(0.75))
                        .onAppear{scaleValue -= 0.175}
                }
                
                Spacer()
                
                ZStack {
                    
                    if entry.configuration.pRing{
                        ProgressCircle(progress: (Double(minutesPassedToday() - firstMatchingItem.start)/Double(firstMatchingItem.end - firstMatchingItem.start)), color: Color(hex: firstMatchingItem.color), lineWidth: 12)
                            .frame(width: 105, height: 105)
                        
                        Image(systemName: firstMatchingItem.symbol)
                            .font(.system(size: 50))
                            .fontWeight(.heavy)
                            .foregroundStyle(Color(hex: firstMatchingItem.color)!)
                            .frame(width: 70, height: 70)
                    } else {
                        Image(systemName: firstMatchingItem.symbol)
                            .font(.system(size: 75))
                            .fontWeight(.heavy)
                            .foregroundStyle(Color(hex: firstMatchingItem.color)!)
                            .frame(width: 75, height: 75)
                    }
                    
                    
                }
                .scaleEffect(scaleValue)
                .frame(width: 110 * scaleValue, height: 110 * scaleValue)
                
               Spacer()
                
                if entry.configuration.bottomText.rawValue == "Name" {
                    Text(firstMatchingItem.name)
                        .font(.callout)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .foregroundStyle(color.opacity(0.75))
                        .onAppear{scaleValue -= 0.175}
                    
                } else if entry.configuration.bottomText.rawValue == "Time Range" {
                    Text(formatTaskTime(start: firstMatchingItem.start, end: firstMatchingItem.end))
                        .font(.callout)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .foregroundStyle(color.opacity(0.75))
                        .onAppear{scaleValue -= 0.175}
                    
                }
            } else {
                Image(systemName: "clock")
                    .font(.system(size: 65))
                    .fontWeight(.heavy)
                    .frame(width: 60, height: 60)
            }
            
        }.padding([.top, .bottom])
    }
}

// MARK: - Provider

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

// MARK: - Flowing Widget

struct FlowingWidget: Widget {
    let kind: String = "FlowingWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            FlowingWidgetView(entry: entry)
                .modelContainer(for: [taskItem.self, toDoItem.self, progressiveItem.self, settingsItem1.self] )
        }
        .configurationDisplayName("Flowing Widget")
        .description("Shows the current task.")
        .supportedFamilies([
            .systemSmall
        ])
    }
}
