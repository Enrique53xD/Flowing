//
//  EditTask.swift
//  Flowing
//
//  Created by Saúl González on 11/01/24.
//

import SwiftUI
import SymbolPicker

struct EditTask: View {
    
    
    @Binding var color: Color
    @Binding var name: String
    @Binding var description: String
    @Binding var symbol: String
    @Binding var start: Int
    @Binding var end: Int
    @Binding var days: [Day]
    
    @State private var dateS = Date()
    @State private var dateE = Date()
    @State private var dateSPicking = false
    @State private var dateEPicking = false
    private let formatter = DateFormatter()
    
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
            .padding(.top)
            
            
            
            HStack{
                
                Button(action: {dateSPicking=true}, label: {
                    Text("\(transformDate(date:dateS))")
                        .fontWeight(.heavy)
                        .font(.title2)
                        .frame(width: 90)
                        .foregroundStyle(color)
                })
                
                .buttonStyle(.bordered)
                .sheet(isPresented: $dateSPicking, onDismiss: {start = convertToMinutes(from: transformDate(date: dateS))}, content: {
                    DatePicker(selection: $dateS, displayedComponents: .hourAndMinute, label: {Text("")})
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .presentationDetents([.fraction(0.3)])
                    
                })
                
                
                Text("-")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(10)
                
                
                Button(action: {dateEPicking=true}, label: {
                    Text("\(transformDate(date:dateE))")
                        .fontWeight(.heavy)
                        .font(.title2)
                        .frame(width: 90)
                        .foregroundStyle(color)
                })
                
                .buttonStyle(.bordered)
                .sheet(isPresented: $dateEPicking, onDismiss: {end = convertToMinutes(from: transformDate(date: dateE))}, content: {
                    DatePicker(selection: $dateE, displayedComponents: .hourAndMinute, label: {Text("")})
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .presentationDetents([.fraction(0.3)])
                    
                })
                
            }
            .padding(.vertical)
            
            DaySelector(days: $days, color: $color)
            
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
        .onAppear(perform: {
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            dateS = formatter.date(from: "2016/10/08 \(transforMinutes(minute: start))") ?? formatter.date(from: "2016/10/08 22:31")!
            dateE = formatter.date(from: "2016/10/08 \(transforMinutes(minute: end))") ?? formatter.date(from: "2016/10/08 22:31")!
        })
    }
}

