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
    @State var symbol: String = ""

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
            
            
            TextField("Description", text: $description, axis: .vertical)
                    .font(.title2)
                    .padding(10)
                    .frame(height: 150)
                    .background(
                        Color.gray.opacity(0.3)
                            .cornerRadius(10))
                    .padding()
            
            Button(action: {withAnimation{context.delete(item)} }, label: {
                
                Text("DELETE")
                    .font(.title2)
                    .fontWeight(.heavy)
                    .frame(width: 150, height: 60)
                    .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                    .background(RoundedRectangle(cornerRadius: 45).foregroundStyle(Color.red))
                    
               
            })
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


