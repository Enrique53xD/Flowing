//
//  ToDo.swift
//  Flowing
//
//  Created by Saúl González on 24/01/24.
//

import SwiftUI

struct ToDoObj: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var color = Color.purple
    @State var name = "todo"
    @State var symbol = "checkmark.circle"
    @State var done = false
    
    @State private var editing = false
    
    var body: some View {
        HStack{
            Button(action: { withAnimation{ if !editing {done.toggle()}} }, label: {
                Image(systemName: symbol)
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundStyle(done ? Color.primary.opacity(0.5) : color)
                    .background(RoundedRectangle(cornerRadius: 45) .frame(width: 60, height: 60)
                        .foregroundStyle(done ? color : color.opacity(0.5)))
                    .frame(width: 60, height: 60)
            })
            .simultaneousGesture(LongPressGesture(minimumDuration: 0.2).onEnded({_ in editing.toggle()}))
            .sheet(isPresented: $editing, content: {
                
               Text("a")
                    
            
            })
            
            Text(name)
                .font(.title2)
                .strikethrough(done, color: color)
                .opacity(done ? 0.7 : 1)
                .fontWeight(.bold)
                .lineLimit(1)
                
                
            
                Spacer()
            
            
        }
        .padding(.horizontal)
 
    }
}


