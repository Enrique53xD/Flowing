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
    @Environment(\.colorScheme) var colorScheme
    
    var item: taskItem
    var context: ModelContext

    @State var color: Color = .red
    @State var name: String = ""
    @State var description: String = ""
    @State var symbol: String = ""
    @State var start: Int = 0
    @State var end: Int = 0
    @State var days: String = ""

    @State private var dateS = Date()
    @State private var dateE = Date()
    @State private var dateSPicking = false
    @State private var dateEPicking = false
    private let formatter = DateFormatter()
    
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
            .padding(.top)
            
            
            
            HStack{
                
                Button(action: {dateSPicking=true}, label: {
                    Text("\(transformDate(date:dateS))")
                        .fontWeight(.heavy)
                        .font(.title2)
                        .frame(width: 90)
                        .foregroundStyle(color)
                })
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .buttonStyle(.bordered)
                .sheet(isPresented: $dateSPicking, onDismiss: {start = convertToMinutes(from: transformDate(date: dateS))}, content: {
                    DatePicker(selection: $dateS, displayedComponents: .hourAndMinute, label: {Text("")})
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .presentationDetents([.fraction(0.3)])
                        .onDisappear{withAnimation {if start>end {(start, end)=(end, start)}; if dateS>dateE {(dateS, dateE)=(dateE, dateS)}}}
                        
                    
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
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .buttonStyle(.bordered)
                .sheet(isPresented: $dateEPicking, onDismiss: {end = convertToMinutes(from: transformDate(date: dateE))}, content: {
                    DatePicker(selection: $dateE, displayedComponents: .hourAndMinute, label: {Text("")})
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .presentationDetents([.fraction(0.3)])
                        .onDisappear{withAnimation {if start>end {(start, end)=(end, start)}; if dateS>dateE {(dateS, dateE)=(dateE, dateS)}}}
                    
                })
                
            }
            .padding(.vertical)
            
            DaySelector(days: $days, color: $color)
                .padding(.horizontal)
            
           
                
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
               
           
            if !naming && !descripting {
                Button(action: {withAnimation{context.delete(item)} }, label: {
                    
                    Text("DELETE")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .frame(width: 330, height: 60)
                        .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                        .background(RoundedRectangle(cornerRadius: 10).foregroundStyle(Color.red))
                    
                    
                })
            }
    
        }
        
        .scrollDisabled(true)
        .onAppear{
            
            color = Color(hex: item.color)!
            name = item.name
            description = item.desc
            symbol = item.symbol
            start = item.start
            end = item.end
            days = item.days
            
            
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            dateS = formatter.date(from: "2016/10/08 \(transforMinutes(minute: start))") ?? formatter.date(from: "2016/10/08 22:31")!
            dateE = formatter.date(from: "2016/10/08 \(transforMinutes(minute: end))") ?? formatter.date(from: "2016/10/08 22:31")!
        }
        
        .onDisappear{
            
            withAnimation{
                item.color = color.toHex()!
                item.name = name
                item.desc = description
                item.symbol = symbol
                item.start = start
                item.end = end
                item.days = days
            }
            
            try? context.save()
        }
        
    }
}

