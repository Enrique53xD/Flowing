//
//  ProgressiveObj.swift
//  Flowing
//
//  Created by Saúl González on 25/01/24.
//

import SwiftUI
import SwiftData

struct ProgressiveObj: View {
    @Environment(\.colorScheme) var colorScheme
    
    var item: progressiveItem
    var context: ModelContext
    
    @State var changing = false
    @State var done = false
    
    @State private var editing = false
    
    @State private var sheetContentHeight = CGFloat(0)
    
    var body: some View {
        
        if changing {
            
            
            RoundedSlider(item: item, context: context, normalHeight: 40, maxHeight: 60, maxWidth: 200, color: Color(hex: item.color)!, changing: $changing, done: $done)
                .padding(.bottom, 5)
                
            
            
        } else {
            HStack{
                Button(action: { withAnimation{ if !editing {changing.toggle()}} }, label: {
                    Image(systemName: item.symbol)
                        
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
                        .frame(width: 60, height: 60)
                    
                        .onAppear{if item.progress >= item.goal {done=true} else {done=false} }
                })
                .onAppear{ if checkDate(item.date, dateStr(Date.now)) && item.daily { item.progress = 0; done = false; item.date = dateStr(Date.now) }}
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.2).onEnded({_ in withAnimation{editing.toggle()}}))
                .sheet( isPresented: $editing, content: {
                    
                    EditProgressive(item: item, context: context)
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
                        .onDisappear{
                            withAnimation{
                                if item.progress >= item.goal {done=true} else {done=false}
                                if item.progress > item.goal {
                                    item.progress = item.goal
                                }
                            }
                        }
                    
                    
                })
                
                
                Text(item.name)
                    .font(.title2)
                    .strikethrough(done, color: Color(hex: item.color))
                    .opacity(done ? 0.7 : 1)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                
                Spacer()
                
                Text(formatProgressive(preffix: item.preffix, suffix: item.suffix, progress: Int(item.progress), goal: Int(item.goal)))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.opacity(0.5))
                
            }
            .onAppear{
                if item.progress > item.goal {
                    item.progress = item.goal
                }
            }
            .padding(.horizontal)
            
        }
        
    }
}
