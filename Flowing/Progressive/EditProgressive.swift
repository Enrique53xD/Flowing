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
    
    // MARK: - Properties
    
    @Environment(\.colorScheme) var colorScheme
    
    var item: progressiveItem
    var context: ModelContext
    
    // State properties
    @State var color: Color = .blue
    @State var name: String = "Name"
    @State var description: String = ""
    @State var symbol: String = "circle.dotted"
    @State var progress: CGFloat = 0
    @State var goal: String = "10"
    @State var preffix: String = ""
    @State var suffix: String = ""
    
    @State var deleted = false
    
    @State private var symbolPicking = false
    @FocusState private var descripting: Bool
    @FocusState private var naming: Bool
    @FocusState private var preffixing: Bool
    @FocusState private var suffixing: Bool
    @FocusState private var goaling: Bool
    
    @State var buttonOpacity = 1.0
    @State var buttonProgress = 0.0
    @State var hasPressed = false
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            // Color and Name
            HStack {
                ColorPicker(selection: $color, supportsOpacity: false, label: { Text("") })
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
                        withAnimation {
                            naming = true
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                
                Button(action: { symbolPicking = true }) {
                    Image(systemName: symbol)
                        .font(.title)
                        .fontWeight(.heavy)
                        .padding(.horizontal)
                        .frame(width: 60)
                        .foregroundStyle(color)
                }
                .sheet(isPresented: $symbolPicking) {
                    SymbolPicker(symbol: $symbol)
                        .presentationDetents([.fraction(0.7), .large])
                }
            }
            .padding(.vertical, 7)
            
            // Preffix and Suffix
            HStack {
                TextField("Preffix", text: $preffix)
                    .font(.title2)
                    .fontWeight(.heavy)
                    .padding(10)
                    .foregroundStyle(color)
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .background(Color.gray.opacity(0.3))
                    .focused($preffixing)
                    .onTapGesture {
                        withAnimation {
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
                    .fontDesign(.rounded)
                    .foregroundStyle(color)
                    .multilineTextAlignment(.center)
                    .background(Color.gray.opacity(0.3))
                    .focused($suffixing)
                    .onTapGesture {
                        withAnimation {
                            suffixing = true
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
            }
            .padding(.horizontal)
            .padding(.vertical, 7)
            
            // Goal
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
                    withAnimation {
                        goaling = true
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                .padding(.horizontal)
                .padding(.vertical, 7)
                .onAppear{goal = String(Int(item.goal))} //had to do this because the value doesnt uodate in the window onappear
            
            // Description
            TextField("Description...", text: $description, axis: .vertical)
                .font(.title2)
                .padding(10)
                .fontDesign(.rounded)
                .frame(height: 150, alignment: .top)
                .background(Color.gray.opacity(0.3))
                .focused($descripting)
                .onTapGesture {
                    withAnimation {
                        descripting = true
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                .padding(.horizontal)
                .padding(.vertical, 7)
            
            HStack {
                if !naming && !descripting && !preffixing && !goaling && !suffixing {
                    // Delete Button
                    ZStack {
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundStyle(Color.red)
                                .frame(width: buttonProgress, height: 60)
                            
                            Rectangle()
                                .foregroundStyle(Color.red)
                                .frame(width: 250, height: 60)
                                .opacity(buttonOpacity)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                        
                        Text("DELETE")
                            .font(.title2)
                            .fontWeight(.heavy)
                            .fontDesign(.rounded)
                            .frame(width: 250, height: 60)
                            .background(RoundedRectangle(cornerRadius: 12.5).foregroundStyle(Color.red.opacity(0.01)))
                            .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                            .sensoryFeedback(.impact, trigger: deleted)
                            .onLongPressGesture(minimumDuration: 2, maximumDistance: 20, pressing: { pressing in
                                self.hasPressed = pressing
                                if pressing {
                                    withAnimation {
                                        buttonOpacity = 0.5
                                    }
                                    withAnimation(.easeOut(duration: 2)) {
                                        buttonProgress = 250
                                    }
                                }
                                if !pressing {
                                    withAnimation(.easeInOut) {
                                        buttonOpacity = 1
                                        buttonProgress = 0
                                    }
                                }
                            }, perform: {
                                deleted = true
                                context.delete(item)
                            })
                    }
                    
                    Spacer()
                    
                    // Daily Button
                    Button(action: { item.daily.toggle() }) {
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
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 7)
        }
        .scrollDisabled(true)
        .onAppear {
            // Set initial values
            color = Color(hex: item.color)!
            name = item.name
            description = item.desc
            symbol = item.symbol
            progress = item.progress
            goal = String(Int(item.goal))
            preffix = item.preffix
            suffix = item.suffix
        }
        .onDisappear {
            withAnimation {
                // Update item properties
                item.color = color.toHex()!
                item.name = name
                item.desc = description
                item.symbol = symbol
                item.progress = progress
                item.goal = CGFloat(Int(goal)!)
                item.preffix = preffix
                item.suffix = suffix
            }
            
            try? context.save()
        }
    }
}








