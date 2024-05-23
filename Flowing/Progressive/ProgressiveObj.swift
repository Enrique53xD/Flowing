//
//  ProgressiveObj.swift
//  Flowing
//
//  Created by Saúl González on 25/01/24.
//

import SwiftUI
import SwiftData

struct ProgressiveObj: View {
    // MARK: - Properties
    
    @Environment(\.colorScheme) var colorScheme
    
    var item: progressiveItem
    var context: ModelContext
    
    @State var changing = false
    @State var done = false
    
    @State private var editing = false
    @State private var buttonOpacity = 1.0
    
    @State var textColor: Color
    
    @State private var sheetContentHeight = CGFloat(0)
    
    // MARK: - Body
    
    var body: some View {
        if changing {
            // Display the RoundedSlider when changing is true
            RoundedSlider(item: item, context: context, normalHeight: 40, maxHeight: 60, maxWidth: 200, color: Color(hex: item.color)!, changing: $changing, done: $done)
                .padding(.bottom, 5)
        } else {
            // Display the main content when changing is false
            HStack {
                // Display the image symbol
                Image(systemName: item.symbol)
                    .onAppear {
                        // Check if the date matches and reset progress if necessary
                        if checkDate(item.date, dateStr(Date.now)) && item.daily {
                            item.progress = 0
                            item.date = dateStr(Date.now)
                        }
                        
                        // Update the done state based on progress and goal
                        if item.progress >= item.goal {
                            done = true
                        } else {
                            done = false
                        }
                    }
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundStyle(
                        (colorScheme == .dark ? (done ? Color.black.opacity(0.5) : Color(hex: item.color)) : (done ? Color.white.opacity(0.5) : Color(hex: item.color))) ?? Color.clear
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 45)
                            .frame(width: 60, height: 60)
                    )
                    .foregroundStyle(
                        (done ? Color(hex: item.color) : Color(hex: item.color)?.opacity(0.5)) ?? Color.clear
                    )
                    .opacity(buttonOpacity)
                    .frame(width: 60, height: 60)
                    .delaysTouches(for: 0.05) {
                        withAnimation {
                            if !editing {
                                changing.toggle()
                            }
                        }
                    }
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
                    .sensoryFeedback(trigger: editing) { _, _ in
                        if editing {
                            return .impact
                        } else {
                            return .none
                        }
                    }
                    .sheet(isPresented: $editing, content: {
                        // Display the EditProgressive sheet
                        EditProgressive(item: item, context: context)
                            .presentationDragIndicator(.visible)
                            .padding()
                            .background {
                                // This is done in the background to prevent GeometryReader from expanding to all the available space
                                GeometryReader { proxy in
                                    Color.clear
                                        .task {
                                            sheetContentHeight = proxy.size.height
                                        }
                                }
                            }
                            .presentationDetents([.height(sheetContentHeight)])
                            .onDisappear {
                                withAnimation {
                                    // Update the done state and limit progress to the goal
                                    if item.progress >= item.goal {
                                        done = true
                                    } else {
                                        done = false
                                    }
                                    if item.progress > item.goal {
                                        item.progress = item.goal
                                    }
                                }
                            }
                    })
                
                // Display the item name
                Text(item.name)
                    .fontDesign(.rounded)
                    .foregroundStyle(textColor)
                    .font(.title2)
                    .strikethrough(done, color: Color(hex: item.color))
                    .opacity(done ? 0.7 : 1)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                Spacer()
                
                // Display the progress
                Text(formatProgressive(preffix: item.preffix, suffix: item.suffix, progress: Int(item.progress), goal: Int(item.goal)))
                    .fontDesign(.rounded)
                    .foregroundStyle(textColor.opacity(0.5))
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .onAppear {
                // Limit progress to the goal
                if item.progress > item.goal {
                    item.progress = item.goal
                }
            }
            .padding(.horizontal)
        }
    }
}
