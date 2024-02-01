//
//  EditProgressive.swift
//  Flowing
//
//  Created by Saúl González on 29/01/24.
//

import SwiftUI
import SymbolPicker

struct EditProgressive: View {
    
    @Binding var color: Color
    @Binding var name: String
    @Binding var description: String
    @Binding var symbol: String
    @Binding var progress: CGFloat
    @Binding var goal: CGFloat
    @Binding var preffix: String
    @Binding var suffix: String
    
    @State private var symbolPicking = false
    
    var body: some View {
        VStack{
            
            HStack{
                
                ColorPicker(selection: $color, supportsOpacity: false, label: {Text("")})
                    .labelsHidden()
                    .padding(.horizontal)
                    .frame(width: 60)
                    
                
                TextField("\(name)", text: $name)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
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
            .padding([.horizontal, .top])
            ZStack{
                
                TextEditor(text: $description)
                    .font(.title2)
                    .scrollContentBackground(.hidden)
                    .padding(10)
                
                    .background(
                        Color.gray.opacity(0.3)
                            .cornerRadius(10))
                
                if description==""{
                    Text("Task Description")
                        .font(.title2)
                        .foregroundStyle(.gray)
                    
                }
            }.padding()
        }
        .scrollDisabled(true)
    }

}


