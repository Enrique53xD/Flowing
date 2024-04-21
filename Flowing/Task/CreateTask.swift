//
//  CreateTask.swift
//  Flowing
//
//  Created by Saúl González on 10/03/24.
//


import SwiftUI
import SymbolPicker
import SwiftData
import WidgetKit

struct CreateTask: View {
    @Environment(\.colorScheme) var colorScheme
    
    var context: ModelContext

    @State var color: Color = .red
    @State var name: String = ""
    @State var description: String = ""
    @State var symbol: String = "house"
    @State var start: Int = 0
    @State var end: Int = 0
    @State var days: String = "0000000"

    @State private var dateS = Date(timeIntervalSinceReferenceDate: -64800)
    @State private var dateE = Date(timeIntervalSinceReferenceDate: -64800)
    @State private var dateSPicking = false
    @State private var dateEPicking = false
    private let formatter = DateFormatter()
    
    @State private var symbolPicking = false
    @FocusState private var descripting: Bool
    @FocusState private var naming: Bool
    
    @EnvironmentObject var timeVariables: freeTimesVariables
    
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
            
            
            
            HStack{
                
                Button(action: {dateSPicking=true}, label: {
                    Text("\(transformDate(date:dateS))")
                        .fontWeight(.heavy)
                        .font(.title2)
                        .frame(width: 90)
                        .foregroundStyle(color)
                        
                })
                .frame(width: 115, height: 45)
                .background(Color.gray.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                .buttonStyle(.borderless)
                .sheet(isPresented: $dateSPicking, onDismiss: {start = convertToMinutes(from: transformDate(date: dateS))}, content: {
                    DatePicker(selection: $dateS, displayedComponents: .hourAndMinute, label: {Text("")})
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .presentationDetents([.fraction(0.3)])
                        
                        
                    
                })
                
                
                Text("-")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                
                
                Button(action: {dateEPicking=true}, label: {
                    Text("\(transformDate(date:dateE))")
                        .fontWeight(.heavy)
                        .font(.title2)
                        .frame(width: 90)
                        .foregroundStyle(color)
                })
                .frame(width: 115, height: 45)
                .background(Color.gray.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                .buttonStyle(.borderless)
                .sheet(isPresented: $dateEPicking, onDismiss: {end = convertToMinutes(from: transformDate(date: dateE))}, content: {
                    DatePicker(selection: $dateE, displayedComponents: .hourAndMinute, label: {Text("")})
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .presentationDetents([.fraction(0.3)])
                        
                    
                })
                
                
            }
            .padding(.vertical, 7)
            
            DaySelector(days: $days, color: $color)
                .padding(.horizontal)
                .padding(.vertical, 7)
                
            TextField("Description...", text: $description, axis: .vertical)
                    .font(.title2)
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
               
           
            
          
            
    
        }
        
        .scrollDisabled(true)
        
        
        .onDisappear{
            
            if name != "" || description != "" || color != .red || symbol != "house" || start != 0 || end != 0 || days != "0000000" {
                

              
                    if start>end {(start, end)=(end, start)}; if dateS>dateE {(dateS, dateE)=(dateE, dateS)}
                    newTask(context, name: name == "" ? "Name" : name, color: color.toHex()!, desc: description, symbol: symbol, start: start, end: end, days: days)
                
                timeVariables.update = true
                
                WidgetCenter.shared.reloadAllTimelines()
            }
      
        }
        
    }
}


