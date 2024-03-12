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
            .simultaneousGesture(LongPressGesture(minimumDuration: 0.2).onEnded({_ in editing.toggle()}))
            .sheet(isPresented: $editing, content: {
                
                EditToDo(item: item, context: context)
                    .padding()
                    .presentationDetents([.fraction(0.45)])
            
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


