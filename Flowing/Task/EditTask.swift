//
//  EditTask.swift
//  Flowing
//
//  Created by Saúl González on 11/01/24.
//

import SwiftUI
import SymbolPicker
import SwiftData

struct EditTask: View {
    // Environment variable
    @Environment(\.colorScheme) var colorScheme
    
    // Properties
    var item: taskItem
    var context: ModelContext
    
    // State variables
    @State var color: Color = .red
    @State var name: String = ""
    @State var description: String = ""
    @State var symbol: String = "house"
    @State var start: Int = 0
    @State var end: Int = 0
    @State var days: String = ""
    
    @State private var dateS = Date()
    @State private var dateE = Date()
    @State private var dateSPicking = false
    @State private var dateEPicking = false
    private let formatter = DateFormatter()
    
    @State var deleted = false
    
    @State private var symbolPicking = false
    @FocusState private var descripting: Bool
    @FocusState private var naming: Bool
    
    // Environment object
    @EnvironmentObject var timeVariables: freeTimesVariables
    
    // Animation properties
    @State var buttonOpacity = 1.0
    @State var buttonProgress = 0.0
    @State var hasPressed = false
    
    var body: some View {
        VStack {
            // Color picker and name text field
            HStack {
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
                        withAnimation {
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
            
            // Start and end time pickers
            HStack {
                Button(action: {dateSPicking=true}, label: {
                    Text("\(dateS.toHoursAndMinutes())")
                        .fontWeight(.heavy)
                        .font(.title2)
                        .fontDesign(.rounded)
                        .frame(width: 90)
                        .foregroundStyle(color)
                })
                .frame(width: 115, height: 45)
                .background(Color.gray.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                .buttonStyle(.borderless)
                .sheet(isPresented: $dateSPicking, onDismiss: {start = convertToMinutes(from: dateS.toHoursAndMinutes())}, content: {
                    DatePicker(selection: $dateS, displayedComponents: .hourAndMinute, label: {Text("")})
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .presentationDetents([.fraction(0.3)])
                })
                
                Text("-")
                    .font(.title)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .padding(.horizontal, 10)
                
                Button(action: {dateEPicking=true}, label: {
                    Text("\(dateE.toHoursAndMinutes())")
                        .fontWeight(.heavy)
                        .font(.title2)
                        .frame(width: 90)
                        .fontDesign(.rounded)
                        .foregroundStyle(color)
                })
                .frame(width: 115, height: 45)
                .background(Color.gray.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                .buttonStyle(.borderless)
                .sheet(isPresented: $dateEPicking, onDismiss: {end = convertToMinutes(from: dateE.toHoursAndMinutes())}, content: {
                    DatePicker(selection: $dateE, displayedComponents: .hourAndMinute, label: {Text("")})
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .presentationDetents([.fraction(0.3)])
                })
            }
            .padding(.vertical, 7)
            
            // Day selector
            DaySelector(days: $days, color: $color)
                .padding(.horizontal)
                .padding(.vertical, 7)
            
            // Description text field
            TextField("Description...", text: $description, axis: .vertical)
                .font(.title2)
                .fontDesign(.rounded)
                .padding(10)
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
            
            // Delete button
            if !naming && !descripting {
                ZStack {
                    ZStack(alignment: .leading) {
                        Rectangle().foregroundStyle(Color.red)
                            .frame(width: buttonProgress, height: 60)
                        
                        Rectangle().foregroundStyle(Color.red)
                            .frame(width: 330, height: 60)
                            .opacity(buttonOpacity)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                    
                    Text("DELETE")
                        .font(.title2)
                        .fontDesign(.rounded)
                        .fontWeight(.heavy)
                        .frame(width: 330, height: 60)
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
                                    buttonProgress = 330
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
                            timeVariables.update.toggle()
                        })
                        .padding(.horizontal)
                        .padding(.vertical, 7)
                }
            }
        }
        .scrollDisabled(true)
        .onAppear {
            // Initialize properties with item values
            color = Color(hex: item.color)!
            name = item.name
            description = item.desc
            symbol = item.symbol
            start = item.start
            end = item.end
            days = item.days
            
            // Initialize date variables
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            dateS = formatter.date(from: "2016/10/08 \(transformMinutes(minute: start))") ?? formatter.date(from: "2016/10/08 22:31")!
            dateE = formatter.date(from: "2016/10/08 \(transformMinutes(minute: end))") ?? formatter.date(from: "2016/10/08 22:31")!
        }
        .onDisappear {
            withAnimation(.bouncy) {
                // Swap start and end if necessary
                if start > end {
                    (start, end) = (end, start)
                }
                // Swap dateS and dateE if necessary
                if dateS > dateE {
                    (dateS, dateE) = (dateE, dateS)
                }
                
                // Update item properties
                item.color = color.toHex()!
                item.name = name
                item.desc = description
                item.symbol = symbol
                item.start = start
                item.end = end
                item.days = days
                
                timeVariables.update.toggle()
                
                try? context.save()
            }
            
            
        }
    }
}
