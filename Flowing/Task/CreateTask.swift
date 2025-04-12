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
import UserNotifications

struct CreateTask: View {
    // MARK: - Properties
    
    // Environment property to access the color scheme
    @Environment(\.colorScheme) var colorScheme
    
    // Model context
    var context: ModelContext
    
    // State properties
    @State private var color: Color = .red
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var symbol: String = "house"
    @State private var start: Int = 0
    @State private var end: Int = 0
    @State private var days: String = "0000000"
    
    // Date properties
    @State private var dateS = Date(timeIntervalSinceReferenceDate: -64800)
    @State private var dateE = Date(timeIntervalSinceReferenceDate: -64800)
    @State private var dateSPicking = false
    @State private var dateEPicking = false
    private let formatter = DateFormatter()
    
    // Symbol picking and focus state properties
    @State private var symbolPicking = false
    @FocusState private var descripting: Bool
    @FocusState private var naming: Bool
    
    // Environment object
    @EnvironmentObject var timeVariables: freeTimesVariables
    
    // MARK: - View Body
    
    var body: some View {
        VStack {
            // Color picker and name text field
            HStack {
                ColorPicker(selection: $color, supportsOpacity: false, label: { Text("") })
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
            
            // Start and end time pickers
            HStack {
                Button(action: { dateSPicking = true }) {
                    Text("\(dateS.toHoursAndMinutes())")
                        .fontWeight(.heavy)
                        .font(.title2)
                        .frame(width: 90)
                        .foregroundStyle(color)
                }
                .frame(width: 115, height: 45)
                .background(Color.gray.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                .buttonStyle(.borderless)
                .sheet(isPresented: $dateSPicking, onDismiss: { start = convertToMinutes(from: dateS.toHoursAndMinutes()) }) {
                    DatePicker(selection: $dateS, displayedComponents: .hourAndMinute, label: { Text("") })
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .presentationDetents([.fraction(0.3)])
                }
                
                Text("-")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                
                Button(action: { dateEPicking = true }) {
                    Text("\(dateE.toHoursAndMinutes())")
                        .fontWeight(.heavy)
                        .font(.title2)
                        .frame(width: 90)
                        .foregroundStyle(color)
                }
                .frame(width: 115, height: 45)
                .background(Color.gray.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                .buttonStyle(.borderless)
                .sheet(isPresented: $dateEPicking, onDismiss: { end = convertToMinutes(from: dateE.toHoursAndMinutes()) }) {
                    DatePicker(selection: $dateE, displayedComponents: .hourAndMinute, label: { Text("") })
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .presentationDetents([.fraction(0.3)])
                }
            }
            .padding(.vertical, 7)
            
            // Day selector
            DaySelector(days: $days, color: $color)
                .padding(.horizontal)
                .padding(.vertical, 7)
            
            // Description text field
            TextField("Description...", text: $description, axis: .vertical)
                .font(.title2)
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
        }
        .scrollDisabled(true)
        .onDisappear {
            // Save task when the view disappears
            if name != "" || description != "" || color != .red || symbol != "house" || start != 0 || end != 0 || days != "0000000" {
                if start > end {
                    (start, end) = (end, start)
                }
                if dateS > dateE {
                    (dateS, dateE) = (dateE, dateS)
                }
                
                // Create the task item
                let item = taskItem(name: name == "" ? "Name" : name, color: color.toHex()!, desc: description, symbol: symbol, start: start, end: end, done: checkCurrentTime(start: start, end: end), days: days)
                context.insert(item)
                
                // Check if notifications are enabled before scheduling
                let fetchDescriptor = FetchDescriptor<settingsItem>()
                if let settings = try? context.fetch(fetchDescriptor).first, settings.notify {
                    // Schedule notifications for all tasks (including the new one)
                    setupNotificationsForUpcomingTasks(context)
                }
                
                timeVariables.update.toggle()
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}
