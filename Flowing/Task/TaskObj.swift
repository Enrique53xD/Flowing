//
//  TaskObj.swift
//  Flowing
//
//  Created by Saúl González on 9/01/24.
//

import SwiftUI

struct TaskObj: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var color = Color.red
    @State var name = "task"
    @State var description = ""
    @State var symbol = "house"
    @State var start = 430
    @State var end = 449
    @State var done = false
    
    @State var days: [Day] = [
        Day(name: "Monday", isSelected: false),
        Day(name: "Tuesday", isSelected: false),
        Day(name: "Wednesday", isSelected: false),
        Day(name: "Thursday", isSelected: false),
        Day(name: "Friday", isSelected: false),
        Day(name: "Saturday", isSelected: false),
        Day(name: "Sunday", isSelected: false)
    ]
    
    @State private var editing = false
    
    var body: some View {
        HStack{
            Button(action: { withAnimation{ if !editing {done.toggle()}} }, label: {
                Image(systemName: symbol)
                    
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundStyle(colorScheme == .dark ? done ? Color.black.opacity(0.5) : color : done ? Color.white.opacity(0.5) : color)
                    .background(RoundedRectangle(cornerRadius: 45) .frame(width: 60, height: 60)
                        .foregroundStyle(done ? color : color.opacity(0.5)))
                    .frame(width: 60, height: 60)
            })
            .simultaneousGesture(LongPressGesture(minimumDuration: 0.2).onEnded({_ in editing.toggle()}))
            .sheet(isPresented: $editing, content: {
                
                EditTask(color: $color, name: $name, description: $description, symbol: $symbol, start: $start, end: $end, days: $days)
                    .padding()
                    .presentationDetents([.medium])
                    
            
            })
            
            Text(name)
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(1)
                .opacity(done ? 0.7 : 1)
                .strikethrough(done, color: color)
                
            
                Spacer()
            
            Text(formatTaskTime(start: start, end: end))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.opacity(0.5))
        }
        .padding(.horizontal)
        .onAppear(perform: {if start>end {(start, end)=(end, start)}})
        
    }
}




