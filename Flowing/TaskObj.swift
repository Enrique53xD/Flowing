//
//  TaskObj.swift
//  Flowing
//
//  Created by Saúl González on 9/01/24.
//

import SwiftUI

struct TaskObj: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var color = Color.blue
    @State var name = "name"
    @State var symbol = "house"
    @State var start = 430
    @State var end = 449
    
    @State private var editing = false
    
    var body: some View {
        HStack{
            Button(action: { editing.toggle() }, label: {
                Image(systemName: symbol)
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundStyle(Color.blue)
                    .background(RoundedRectangle(cornerRadius: 45) .frame(width: 60, height: 60)
                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black))
                    .frame(width: 60, height: 60)
            })
            .sheet(isPresented: $editing, content: {
                
                EditTask(color: color, name: name, symbol: symbol, start: start, end: end)
                    .padding()
                    .presentationDetents([.medium])
                    
            
            })
            
            Text(name)
                .font(.title2)
                .fontWeight(.bold)
                
            
                Spacer()
            
            Text(formatTaskTime(start: start, end: end))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.opacity(0.5))
        }
        .padding()
        .onAppear(perform: {if start>end {(start, end)=(end, start)}})
    }
}

struct TaskPreview: View {
    var body: some View {
        ScrollView{
            LazyVStack{
                TaskObj()
            }
        }
    }
}


#Preview {
    TaskPreview()
}
