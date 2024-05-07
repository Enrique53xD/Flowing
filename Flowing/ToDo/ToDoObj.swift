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
    @State private var buttonOpacity = 1.0
    
    @State var textColor: Color
    
    @State private var sheetContentHeight = CGFloat(0)
    
    var body: some View {
        HStack{
            
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
                .onAppear{ if checkDate(item.date, dateStr(Date.now)) && item.daily { item.done = false; item.date = dateStr(Date.now) }}
                .delaysTouches(for: 0.05) {withAnimation{ if !editing {item.done.toggle()}}}
                .gesture(LongPressGesture(minimumDuration: 0.2)
                    .onChanged({_ in
                        withAnimation(.linear(duration: 0.1)){
                            buttonOpacity = 0.1
                        }
                        withAnimation(.linear(duration: 0.4)){
                            buttonOpacity = 1
                        }
                        
                    })
                        .onEnded(){_ in
                            withAnimation{
                                editing.toggle()
                                
                            }
                        })
                .opacity(buttonOpacity)
                .sensoryFeedback(trigger: editing) { _,_  in
                    if editing == true {
                        return .impact
                    } else {
                        return .none
                    }
                }
                .sheet( isPresented: $editing, content: {
                    
                    EditToDo(item: item, context: context)
                        .presentationDragIndicator(.visible)
                        .padding()
                        .background {
                            //This is done in the background otherwise GeometryReader tends to expand to all the space given to it like color or shape.
                            GeometryReader { proxy in
                                Color.clear
                                    .task {
                                        sheetContentHeight = proxy.size.height
                                    }
                            }
                        }
                        .presentationDetents([.height(sheetContentHeight)])
                    
                })
            
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


