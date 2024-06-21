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
    
    @State var item: progressiveItem
    var context: ModelContext
    
    @State var changing = false
    @State var done = false
    
    @State private var editing = false
    
    @State var textColor: Color
    
    @State private var sheetContentHeight = CGFloat(0)
    
    let myAction = {
      print("This is the action being performed!")
    }
    
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
                CircleSymbol(symbol: $item.symbol, color: $item.color, done: $done, editing: $editing, tapAction: {changing.toggle()})
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
