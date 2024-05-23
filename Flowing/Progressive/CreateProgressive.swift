//
//  CreateProgressive.swift
//  Flowing
//
//  Created by Saúl González on 11/03/24.
//

import SwiftUI
import SymbolPicker
import SwiftData

struct CreateProgressive: View {
    
    // MARK: - Properties
    
    @Environment(\.colorScheme) var colorScheme
    
    var context: ModelContext
    
    // State properties
    @State var color: Color = .blue
    @State var name: String = ""
    @State var description: String = ""
    @State var symbol: String = "circle.dotted"
    @State var progress: CGFloat = 0
    @State var goal: String = "10"
    @State var preffix: String = ""
    @State var suffix: String = ""
    
    // Focus state properties
    @State private var symbolPicking = false
    @FocusState private var descripting: Bool
    @FocusState private var naming: Bool
    @FocusState private var preffixing: Bool
    @FocusState private var suffixing: Bool
    @FocusState private var goaling: Bool
    
    
    // MARK: - Body
    
    var body: some View {
        VStack{
            
            // Color picker and name text field
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
                .sheet(isPresented: $symbolPicking, content: {
                    SymbolPicker(symbol: $symbol)
                        .presentationDetents([.fraction(0.7), .large])
                })
            }
            .padding(.vertical, 7)
            
            // Preffix and suffix text fields
            HStack{
                TextField("Preffix", text: $preffix)
                    .font(.title2)
                    .fontWeight(.heavy)
                    .fontDesign(.rounded)
                    .padding(10)
                    .foregroundStyle(color)
                    .multilineTextAlignment(.center)
                    .background(Color.gray.opacity(0.3))
                    .focused($preffixing)
                    .onTapGesture {
                        withAnimation{
                            preffixing = true
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                
                Text("-")
                    .font(.title)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .padding(.horizontal, 10)
                
                TextField("Suffix", text: $suffix)
                    .font(.title2)
                    .fontWeight(.heavy)
                    .padding(10)
                    .foregroundStyle(color)
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .background(Color.gray.opacity(0.3))
                    .focused($suffixing)
                    .onTapGesture {
                        withAnimation{
                            suffixing = true
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                
            }
            .padding(.horizontal)
            .padding(.vertical, 7)
            
            // Goal text field
            TextField("Goal", text: $goal)
                .keyboardType(.numberPad)
                .limitInputLength(value: $goal, length: 5)
                .font(.title2)
                .fontDesign(.rounded)
                .fontWeight(.heavy)
                .padding(10)
                .foregroundStyle(color)
                .multilineTextAlignment(.center)
                .background(Color.gray.opacity(0.3))
                .focused($goaling)
                .onTapGesture {
                    withAnimation{
                        goaling = true
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                .padding(.horizontal)
                .padding(.vertical, 7)
            
            // Description text field
            TextField("Description...", text: $description, axis: .vertical)
                .font(.title2)
                .padding(10)
                .frame(height: 150, alignment: .top)
                .fontDesign(.rounded)
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
        
        // Save data on disappear
        .onDisappear{
            if name != "" || description != "" || color != .blue || symbol != "circle.dotted" || goal != "10" || preffix != "" || suffix != ""{
                newProgressive(context, name: name.isEmpty ? "Name" : name, color: color.toHex()!, desc: description, symbol: symbol, goal: CGFloat(Int(goal)!), preffix: preffix, suffix: suffix)
            }
        }
    }
}

