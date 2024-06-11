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
    @State private var buttonOpacity = 1.0
    @State var textColor: Color
    
    // Other variables
    var item: taskItem
    var context: ModelContext
    @State private var sheetContentHeight = CGFloat(0)
    
    // MARK: - View Body
    
    var body: some View {
        ZStack {
            if active {
                RoundedRectangle(cornerRadius: 45)
                    .padding(.horizontal)
                    .opacity(0.2)
            }
            
            HStack {
                // Symbol and Button
                ZStack {
                    RoundedRectangle(cornerRadius: 45)
                        .frame(width: 60, height: 60)
                        .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                    
                    Image(systemName: item.symbol)
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundStyle(
                            (colorScheme == .dark ? (item.done ? Color.black.opacity(0.5) : Color(hex: item.color)) : (item.done ? Color.white.opacity(0.5) : Color(hex: item.color))) ?? Color.clear
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 45)
                                .frame(width: 60, height: 60)
                        )
                        .foregroundStyle(
                            (item.done ? Color(hex: item.color) : Color(hex: item.color)?.opacity(0.5)) ?? Color.clear
                        )
                        .frame(width: 60, height: 60)
                        .delaysTouches(for: 0.05) {}
                        .gesture(LongPressGesture(minimumDuration: 0.2)
                            .onChanged({ _ in
                                withAnimation(.linear(duration: 0.1)) {
                                    buttonOpacity = 0.1
                                }
                                withAnimation(.linear(duration: 0.4)) {
                                    buttonOpacity = 1
                                }
                            })
                            .onEnded({ _ in
                                withAnimation {
                                    editing.toggle()
                                }
                            })
                        )
                        .opacity(buttonOpacity)
                        .onChange(of: active) {
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                        .sensoryFeedback(trigger: editing) { _, _  in
                            if editing {
                                return .impact
                            } else {
                                return .none
                            }
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
                }
                
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
