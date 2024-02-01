//
//  ProgressiveObj.swift
//  Flowing
//
//  Created by Saúl González on 25/01/24.
//

import SwiftUI

struct ProgressiveObj: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var color = Color.blue
    @State var name = "progr"
    @State var description = ""
    @State var symbol = "drop"
    @State var progress: CGFloat = 2
    @State var goal: CGFloat = 15
    @State var preffix = ""
    @State var suffix = "ml"
    
    @State var changing = false
    @State var done = false
    
    @State private var editing = false
    
    var body: some View {
        
        if changing {
            
            
            RoundedSlider(normalHeight: 40, maxHeight: 60, maxWidth: 200, color: color, progress: $progress, goal: $goal, changing: $changing, done: $done)
            
            
            
        } else {
            HStack{
                Button(action: { withAnimation{ if !editing {changing.toggle()}} }, label: {
                    Image(systemName: symbol)
                        
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundStyle(colorScheme == .dark ? done ? Color.black.opacity(0.5) : color : done ? Color.white.opacity(0.5) : color)
                        .background(RoundedRectangle(cornerRadius: 45) .frame(width: 60, height: 60)
                            .foregroundStyle(done ? color : color.opacity(0.5)))
                        .frame(width: 60, height: 60)
                    
                        .onAppear{if progress >= goal {done=true} else {done=false} }
                })
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.2).onEnded({_ in editing.toggle()}))
                .sheet(isPresented: $editing, content: {
                    
                    EditProgressive(color: $color, name: $name, description: $description, symbol: $symbol, progress: $progress, goal: $goal, preffix: $preffix, suffix: $suffix)
                        .padding()
                        .presentationDetents([.fraction(0.54)])
                    
                    
                })
                
                
                Text(name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .opacity(done ? 0.7 : 1)
                    .strikethrough(done, color: color)
                
                
                Spacer()
                
                Text(formatProgressive(preffix: preffix, suffix: suffix, progress: Int(progress), goal: Int(goal)))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.opacity(0.5))
                
            }
            
            .padding(.horizontal)
            
        }
        
    }
}
