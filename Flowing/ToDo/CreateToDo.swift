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
    @State var name: String = ""
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
                    .fontDesign(.rounded)
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
                .padding(10)
                .fontDesign(.rounded)
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
            
            
        }
        .scrollDisabled(true)
        
        
        .onDisappear{
            
            if name != "" || description != "" || color != .green || symbol != "checkmark.circle"{
                
    
                    newToDo(context, name: name.isEmpty ? "Name" : name, color: color.toHex()!, desc: description, symbol: symbol)
                
                
            }
        }
    }
}



