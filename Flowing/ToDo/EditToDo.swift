//
//  EditToDo.swift
//  Flowing
//
//  Created by Saúl González on 24/01/24.
//

import SwiftUI
import SymbolPicker
import SwiftData

struct EditToDo: View {
    @Environment(\.colorScheme) var colorScheme
    
    var item: toDoItem
    var context: ModelContext
    
    @State var color: Color = Color.blue
    @State var name: String = ""
    @State var description: String = ""
    @State var symbol: String = "house"
    
    @State var deleted = false

    @State private var symbolPicking = false
    @FocusState private var descripting: Bool
    @FocusState private var naming: Bool
    
    @State var buttonOpacity = 1.0
    @State var buttonProgress = 0.0
    @State var hasPressed = false
    
    var body: some View {
        VStack{
            
            HStack{
                
                ColorPicker(selection: $color, supportsOpacity: false, label: {Text("")})
                    .labelsHidden()
                    .padding(.horizontal)
                    .frame(width: 60)
                
                TextField("Name", text: $name)
                    .font(.title)
                    .fontDesign(.rounded)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(5)
                    .background(Color.gray.opacity(0.3))
                    .focused($naming)
                    .onTapGesture {
                        withAnimation{
                            naming = true
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                
                Button(action: {symbolPicking = true}, label: {
                    Image(systemName: symbol)
                        .font(.title)
                        .fontWeight(.heavy)
                        .padding(.horizontal)
                        .frame(width: 60)
                        .foregroundStyle(color)
                })
                .sheet(isPresented: $symbolPicking, content: { SymbolPicker(symbol: $symbol) .presentationDetents([.fraction(0.7), .large])})
            }
            .padding(.vertical, 7)
            
            
            TextField("Description...", text: $description, axis: .vertical)
                .font(.title2)
                .fontDesign(.rounded)
                .padding(10)
                .frame(height: 150, alignment: .top)
                .background(Color.gray.opacity(0.3))
                .focused($descripting)
                .onTapGesture {
                    withAnimation{
                        descripting = true
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                .padding(.horizontal)
                .padding(.vertical, 7)
            
            HStack{
                if !naming && !descripting {
                    
                    
                    ZStack {
                        
                        ZStack(alignment: .leading){
                            
                            Rectangle().foregroundStyle(Color.red)
                                .frame(width: buttonProgress, height: 60)

                            Rectangle().foregroundStyle(Color.red)
                                .frame(width: 250, height: 60)
                                .opacity(buttonOpacity)
                            
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                        
                        
                        
                        Text("DELETE")
                            .fontDesign(.rounded)
                            .font(.title2)
                            .fontWeight(.heavy)
                            .frame(width: 250, height: 60)
                            .background(RoundedRectangle(cornerRadius: 12.5).foregroundStyle(Color.red.opacity(0.01)))
                            .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                            .sensoryFeedback(.impact, trigger: deleted)
                            .onLongPressGesture(minimumDuration: 2, maximumDistance: 20, pressing: {
                                pressing in
                                self.hasPressed = pressing
                                if pressing {
                                    
                                    withAnimation{
                                        buttonOpacity = 0.5
                                    }
                                    withAnimation(.easeOut(duration: 2)){
                                        buttonProgress = 250
                                    }
                                }
                                if !pressing {
                                    withAnimation(.easeInOut){
                                        buttonOpacity = 1
                                        buttonProgress = 0
                                        
                                    }
                                   
                                    
                                    
                                }
                            }, perform: {deleted = true; context.delete(item)})
                            
                    }

                    Spacer()
                    
                    Button(action: {item.daily.toggle() }, label: {
                        
                        Image(systemName: "arrow.circlepath")
                            .font(.title)
                            .fontWeight(.heavy)
                            .foregroundStyle(
                                (colorScheme == .dark ? (item.daily ? Color.black.opacity(0.5) : Color(hex: item.color)) : (item.daily ? Color.white.opacity(0.5) : Color(hex: item.color))) ?? Color.clear
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 12.5)
                                    .frame(width: 60, height: 60)
                            )
                            .foregroundStyle(
                                (item.daily ? Color(hex: item.color) : Color(hex: item.color)?.opacity(0.5)) ?? Color.clear
                            )
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                        
                    })
                }
            }
            
            .padding(.horizontal)
            .padding(.vertical, 7)
        }
        .scrollDisabled(true)
        .onAppear{
            color = Color(hex: item.color)!
            name = item.name
            description = item.desc
            symbol = item.symbol
            
        }
        
        .onDisappear{
            withAnimation{
                item.color = color.toHex()!
                item.name = name
                item.desc = description
                item.symbol = symbol
            }
            
            try? context.save()
        }
    }
}


