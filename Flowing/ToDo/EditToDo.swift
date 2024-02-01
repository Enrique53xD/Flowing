//
//  EditToDo.swift
//  Flowing
//
//  Created by Saúl González on 24/01/24.
//

import SwiftUI
import SymbolPicker

struct EditToDo: View {
    @Binding var color: Color
    @Binding var name: String
    @Binding var description: String
    @Binding var symbol: String

    
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


