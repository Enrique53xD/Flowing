//
//  ToDo.swift
//  Flowing
//
//  Created by Saúl González on 24/01/24.
//

import SwiftUI
import SwiftData

struct ToDoObj: View {
    @Environment(\.colorScheme) var colorScheme

    var item: toDoItem
    var context: ModelContext

    @State private var editing = false
    
    @State private var sheetContentHeight = CGFloat(0)
    
    var body: some View {
        HStack{
            Button(action: { withAnimation{ if !editing {item.done.toggle()}} }, label: {
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
            })
            .onAppear{ if checkDate(item.date, dateStr(Date.now)) && item.daily { item.done = false; item.date = dateStr(Date.now) }}
            .simultaneousGesture(LongPressGesture(minimumDuration: 0.2).onEnded({_ in withAnimation{editing.toggle()}}))
            .sheet(isPresented: $editing, content: {
                
                EditToDo(item: item, context: context)
                    .padding()
                    .background {
                                //This is done in the background otherwise GeometryReader tends to expand to all the space given to it like color or shape.
                                GeometryReader { proxy in
                                    Color.clear
                                        .task {
                                            print("size = \(proxy.size.height)")
                                            sheetContentHeight = proxy.size.height
                                        }
                                }
                            }
                            .presentationDetents([.height(sheetContentHeight)])
            
            })
            
            Text(item.name)
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


