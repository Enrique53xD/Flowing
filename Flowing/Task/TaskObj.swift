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
    
    // Other variables
    @State var item: taskItem
    var context: ModelContext
    @State private var sheetContentHeight = CGFloat(0)
    
    // MARK: - View Body
    
    var body: some View {
        ZStack {
            if active {
                RoundedRectangle(cornerRadius: 45, style: .circular)
                    .padding(.horizontal)
                    .opacity(0.2)
            }
            
            HStack {
                // Symbol and Button

                    
                    
                CircleSymbol(symbol: $item.symbol, color: $item.color, done: $item.done, editing: $editing)
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
                                }
                        })
                
                
                // Task Name
                Text(item.name)
                    .foregroundStyle(textColor)
                    .fontDesign(.rounded)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .opacity(item.done ? 0.7 : 1)
                    .strikethrough(item.done, color: Color(hex: item.color))
                
                Spacer()
                
                // Task Time
                Text(formatTaskTime(start: item.start, end: item.end))
                    .foregroundStyle(active ? textColor.opacity(0.8) : textColor.opacity(0.5))
                    .fontDesign(.rounded)
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(width: 150, alignment: .trailing)
                    .padding(.trailing, active ? 20 : 0 )
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
}
