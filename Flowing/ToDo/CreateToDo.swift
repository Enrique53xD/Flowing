//
//  CreateToDo.swift
//  Flowing
//
//  Created by Saúl González on 11/03/24.
//

import SwiftUI
import SymbolPicker
import SwiftData

struct CreateToDo: View {
    @Environment(\.colorScheme) var colorScheme

    var context: ModelContext
    
    @State var color: Color = Color.green
    @State var name: String = "Name"
    @State var description: String = ""
    @State var symbol: String = "checkmark.circle"

    @State private var symbolPicking = false
    @FocusState private var descripting: Bool
    @FocusState private var naming: Bool
    
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
            
            
        }
        .scrollDisabled(true)
        
        
        .onDisappear{
            
            if name != "Name" || description != "" || color != .green || symbol != "checkmark.circle"{
                
                withAnimation{
                    newToDo(context, name: name, color: color.toHex()!, desc: description, symbol: symbol)
                }
                
            }
        }
    }
}



