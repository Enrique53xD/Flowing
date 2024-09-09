//
//  ToDo.swift
//  Flowing
//
//  Created by Saúl González on 24/01/24.
//

import SwiftUI
import SwiftData

struct ToDoObj: View {
    // MARK: - Properties
    
    // Environment variable to access the color scheme
    @Environment(\.colorScheme) var colorScheme
    
    // ToDo item and model context
    @State var item: toDoItem
    var context: ModelContext
    
    // State variables
    @State private var editing = false
    @State var textColor: Color
    @State private var sheetContentHeight = CGFloat(0)
    
    // MARK: - View Body
    
    var body: some View {
        HStack {
            // Symbol image
            CircleSymbol(symbol: $item.symbol, color: $item.color, done: $item.done, editing: $editing, tapAction: {item.done.toggle(); print(item.id)})
                .onAppear {
                    // Reset item's done status and date if it's a daily task and the date has changed
                    if checkDate(item.date, dateStr(Date.now)) && item.daily {
                        item.done = false
                        item.date = dateStr(Date.now)
                    }
                }
                .sheet(isPresented: $editing) {
                    // EditToDo sheet
                    EditToDo(item: item, context: context)
                        .presentationDragIndicator(.visible)
                        .padding()
                        .background {
                            // This is done in the background to prevent GeometryReader from expanding to all available space
                            GeometryReader { proxy in
                                Color.clear
                                    .task {
                                        sheetContentHeight = proxy.size.height
                                    }
                            }
                        }
                        .presentationDetents([.height(sheetContentHeight)])
                }
            
            // ToDo item name
            Text(item.name)
                .foregroundStyle(textColor)
                .fontDesign(.rounded)
                .font(.title2)
                .strikethrough(item.done, color: Color(hex: item.color))
                .opacity(item.done ? 0.7 : 1)
                .fontWeight(.bold)
                .lineLimit(1)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}
