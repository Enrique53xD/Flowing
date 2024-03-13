//
//  EditProgressive.swift
//  Flowing
//
//  Created by Saúl González on 29/01/24.
//

import SwiftUI
import SymbolPicker
import SwiftData

struct EditProgressive: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var item: progressiveItem
    var context: ModelContext
    
    @State var color: Color = .blue
    @State var name: String = "Name"
    @State var description: String = ""
    @State var symbol: String = "circle.dotted"
    @State var progress: CGFloat = 0
    @State var goal: CGFloat = 10
    @State var preffix: String = ""
    @State var suffix: String = ""
    
    @State private var symbolPicking = false
    @FocusState private var descripting: Bool
    @FocusState private var naming: Bool
    @FocusState private var preffixing: Bool
    @FocusState private var suffixing: Bool
    @FocusState private var goaling: Bool
    
    
    var body: some View {
        VStack{
            
            HStack{
                
                ColorPicker(selection: $color, supportsOpacity: false, label: {Text("")})
                    .labelsHidden()
                    .padding(.horizontal)
                    .frame(width: 60)
                    
                
                TextField("Name", text: $name)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(5)
                    .background(
                        Color.gray.opacity(0.3)
                            .cornerRadius(10))
                    .focused($naming)
                    .onTapGesture {
                        withAnimation{
                            naming = true
                        }
                    }
                
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
            .padding(.vertical)
            
            HStack{
                TextField("Preffix", text: $preffix)
                    .font(.title2)
                    .fontWeight(.heavy)
                    .padding(10)
                    .foregroundStyle(color)
                    .multilineTextAlignment(.center)
                    .background(
                        Color.gray.opacity(0.3)
                            .cornerRadius(10))
                    .focused($preffixing)
                    .onTapGesture {
                        withAnimation{
                            preffixing = true
                        }
                    }
                
                
                Text("-")
                    .font(.title2)
                    .fontWeight(.heavy)
                    
                TextField("Suffix", text: $suffix)
                    .font(.title2)
                    .fontWeight(.heavy)
                    .padding(10)
                    .foregroundStyle(color)
                    .multilineTextAlignment(.center)
                    .background(
                        Color.gray.opacity(0.3)
                            .cornerRadius(10))
                    .focused($suffixing)
                    .onTapGesture {
                        withAnimation{
                            suffixing = true
                        }
                    }
                
            }.padding(.horizontal)
            
            TextField("Goal", value: Binding(
                get: { Int(goal) },
                set: { newValue in
                    goal = CGFloat(newValue)
                }
            ), formatter: NumberFormatter())
            .keyboardType(.numberPad)
            .font(.title2)
            .fontWeight(.heavy)
            .padding(10)
            .foregroundStyle(color)
            .multilineTextAlignment(.center)
            .background(
                Color.gray.opacity(0.3)
                    .cornerRadius(10))
            .focused($goaling)
            .onTapGesture {
                withAnimation{
                    goaling = true
                }
            }
            .padding([.horizontal, .top])
            
            TextField("Description...", text: $description, axis: .vertical)
                    .font(.title2)
                    .padding(10)
                    .frame(height: 150, alignment: .top)
                    .background(
                        Color.gray.opacity(0.3)
                            .cornerRadius(10))
                    .focused($descripting)
                    .onTapGesture {
                        withAnimation{
                            descripting = true
                        }
                    }
                    .padding()
            
            if !naming && !descripting && !suffixing && !preffixing && !goaling {
                
                Button(action: {withAnimation{context.delete(item)} }, label: {
                    
                    Text("DELETE")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .frame(width: 325, height: 60)
                        .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                        .background(RoundedRectangle(cornerRadius: 10).foregroundStyle(Color.red))
                    
                    
                })
            }
        }
        .scrollDisabled(true)
        .onAppear{
            color = Color(hex: item.color)!
            name = item.name
            description = item.desc
            symbol = item.symbol
            progress = item.progress
            goal = item.goal
            preffix = item.preffix
            suffix = item.suffix
            
        }
        
        .onDisappear{
            withAnimation{
                item.color = color.toHex()!
                item.name = name
                item.desc = description
                item.symbol = symbol
                item.progress = progress
                item.goal = goal
                item.preffix = preffix
                item.suffix = suffix
                
            }
            
            try? context.save()
        }
    }

}


