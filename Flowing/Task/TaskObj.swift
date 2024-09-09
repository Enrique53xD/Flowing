//
//  TaskObj.swift
//  Flowing
//
//  Created by Saúl González on 9/01/24.
//

import SwiftUI
import SwiftData
import WidgetKit

struct TaskObj: View {
    // MARK: - Properties
    
    // Environment variables
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var timeVariables: freeTimesVariables
    
    // State variables
    @State private var editing = false
    @State private var active = false
    @State private var timer: Timer?
    @State var textColor: Color
    
    @State var testDone = false
    
    // Other variables
    @State var item: taskItem
    var context: ModelContext
    @State private var sheetContentHeight = CGFloat(0)
    
    // MARK: - View Body
    
    var body: some View {
        ZStack {
            if checkCurrentTime(start: item.start, end: item.end) {
                RoundedRectangle(cornerRadius: 45, style: .circular)
                    .padding(.horizontal)
                    .opacity(0.2)
            }
            
            HStack {
                // Symbol and Button
                CircleSymbol(symbol: $item.symbol, color: $item.color, done: .constant(item.end < minutesPassedToday()), editing: $editing)
                    .onAppear(){
                        testDone = (item.end < minutesPassedToday())
                    }
                    .onChange(of: item.end) {
                        testDone = (item.end < minutesPassedToday())
                    }
                        .onChange(of: active) {
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                        .sheet(isPresented: $editing, content: {
                            EditTask(item: item, context: context)
                                .presentationDragIndicator(.visible)
                                .padding()
                                .background {
                                    // This is done in the background otherwise GeometryReader tends to expand to all the space given to it like color or shape.
                                    GeometryReader { proxy in
                                        Color.clear
                                            .task {
                                                sheetContentHeight = proxy.size.height
                                            }
                                    }
                                }
                                .presentationDetents([.height(sheetContentHeight)])
                                .onDisappear {
                                    WidgetCenter.shared.reloadAllTimelines()
                                    withAnimation(.bouncy) {
                                        active = checkCurrentTime(start: item.start, end: item.end)
                                        
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "HH:mm"
                                        let currentTime = dateFormatter.string(from: Date())
                                        let actual = convertToMinutes(from: currentTime)
                                        
                                        if item.end < actual {
                                            item.done = true
                                        } else {
                                            item.done = false
                                        }
                                    }
                                    
                                    timeVariables.update.toggle()
                                }
                        })
                
                
                // Task Name
                Text(item.name)
                    .foregroundStyle(textColor)
                    .fontDesign(.rounded)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .opacity((item.end < minutesPassedToday()) ? 0.7 : 1)
                    .strikethrough((item.end < minutesPassedToday()), color: Color(hex: item.color))
                
                Spacer()
                
                // Task Time
                Text(formatTaskTime(start: item.start, end: item.end))
                    .foregroundStyle(checkCurrentTime(start: item.start, end: item.end) ? textColor.opacity(0.8) : textColor.opacity(0.5))
                    .fontDesign(.rounded)
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(width: 150, alignment: .trailing)
                    .padding(.trailing, checkCurrentTime(start: item.start, end: item.end) ? 20 : 0 )
            }
            .padding(.horizontal)
        }
        .onAppear(perform: {
            if item.start > item.end {
                (item.start, item.end) = (item.end, item.start)
            }
            
            withAnimation(.bouncy) {
                active = checkCurrentTime(start: item.start, end: item.end)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                let currentTime = dateFormatter.string(from: Date())
                let actual = convertToMinutes(from: currentTime)
                
                if item.end < actual {
                    item.done = true
                } else {
                    item.done = false
                }
            }
            
            timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                withAnimation() {
                    active = checkCurrentTime(start: item.start, end: item.end)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    let currentTime = dateFormatter.string(from: Date())
                    let actual = convertToMinutes(from: currentTime)
                    
                    if item.end < actual {
                        item.done = true
                    } else {
                        item.done = false
                    }
                    
                    timeVariables.update.toggle()
                }
            }
        })
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func minutesPassedToday() -> Int {
        // Get the current date and time
        let now = Date()

        // Get the start of today (midnight)
        let today = Calendar.current.startOfDay(for: now)

        // Calculate the time interval between the start of today and now
        let interval = now.timeIntervalSince(today)

        // Convert the interval to minutes
        let minutes = Int(interval / 60)

        return minutes
    }
}
