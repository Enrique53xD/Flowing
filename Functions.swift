//
//  Functions.swift
//  Flowing
//
//  Created by Saúl González on 9/01/24.
//

import Foundation
import SwiftUI
import SwiftData
import UIKit

// MARK: Extensions

// Extension for to convert a Color variable to a hex
extension Color {
    
    func toHex() -> String? {
        
        let uic = UIColor(self)
        
        guard let components = uic.cgColor.components, components.count >= 3 else {
            
            return nil
            
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            
            a = Float(components[3])
            
        }

        if a != Float(1.0) {
            
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
            
        } else {
            
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
            
        }
        
    }
    
}

// Extension for to convert hex to a Color variable
extension Color {
    
    init?(hex: String) {
        
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else { return nil }

        self.init(red: r, green: g, blue: b, opacity: a)
        
    }
    
}

// Extension to get the screen size
extension UIScreen {
    
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
    
}

// Extension to transform a Date variable to HH:mm format
extension Date {
 
    func toHoursAndMinutes() -> String {
        
        let date = self
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let dateString = dateFormatter.string(from: date)
        
        return dateString
        
    }
    
}

// MARK: Functions

// Function to know if current time is between the start and end
func checkCurrentTime(start: Int, end: Int) -> Bool {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    
    let currentTime = dateFormatter.string(from: Date())
    let actual = convertToMinutes(from: currentTime)

    if actual >= start && actual <= end {
        
        return true
        
    } else {
        
        return false
        
    }
    
}

// Function to transform an integer to HH:mm
func transforMinutes(minute: Int) -> String {
    
    var minutes = minute
    var hours = 0
    
    while minutes >= 60 {
        
        minutes -= 60
        hours += 1
        
    }
    
    return "\(String(format: "%02d", hours)):\(String(format: "%02d", minutes))"
    
}

// Function to transform HH:mm to an integer
func convertToMinutes(from timeString: String) -> Int {
    
    let components = timeString.components(separatedBy: ":")
    
    if components.count == 2,
       
       let hours = Int(components[0]),
       
       let minutes = Int(components[1]) {
        
        return hours * 60 + minutes
        
    }
    
    return 0 // Default return
    
}

// Function to get the start and end Integers to be HH:mm or HH:mm - HH:mm
func formatTaskTime(start: Int, end: Int) -> String {
    
    if start==end {
        
        return "\(transforMinutes(minute: start))"
        
    } else {
        
        return "\(transforMinutes(minute: start)) - \(transforMinutes(minute: end))"
        
    }
    
}

// Function to get the progress of the goal and add the respective prefix or suffix
func formatProgressive(preffix: String = "", suffix: String = "", progress: Int, goal: Int) -> String {
    
    return "\(preffix)\(progress)\(suffix) / \(preffix)\(goal)\(suffix)"
    
}

// Function to create a new Task Object
func newTask(_ context: ModelContext, name: String, color: String, desc: String, symbol: String, start: Int, end: Int, days: String) {
    
    let item = taskItem(name: name, color: color, desc: desc, symbol: symbol, start: start, end: end, done: checkCurrentTime(start: start, end: end), days: days)
    
    context.insert(item)
    
}

// Function to create a new ToDo Object
func newToDo(_ context: ModelContext, name: String, color: String, desc: String, symbol: String) {
    
    let item = toDoItem(name: name, color: color, desc: desc, symbol: symbol, done: false)
    context.insert(item)
}

// Function to create a new Progressive Object
func newProgressive(_ context: ModelContext, name: String, color: String, desc: String, symbol: String, goal: CGFloat, preffix: String, suffix: String) {
    
    let item = progressiveItem(name: name, color: color, desc: desc, symbol: symbol, progress: 0, goal: goal, preffix: preffix, suffix: suffix)
    context.insert(item)
}

// Function to create a new Dettings Object
func newSettings(_ context: ModelContext) {
    
    let item = settingsItem(customMainColor: false, mainColor: Color.red.toHex()!, textColor: Color.cyan.toHex()!, customTextColor: false, showFreeTimes: false, customHome: false)
    context.insert(item)
    
}

// Function to get the free time spaces
func getFreeTimes(_ vars: [taskItem], days: String, allTasks: Bool) -> [(Int, Int)]{
    
    var spaces = [Int]()
    var tasks = [taskItem]()
    
    if vars.count == 0 {
        
        let pairs: [(Int, Int)] = []

        return pairs
        
    } else {
        
        for i in 0..<vars.count{
            
            if !allTasks{
                
                if isToday(vars[i].days) || vars[i].days == "0000000"{ tasks.append(vars[i]) }
                
            } else {
                
                if isIncluded(vars[i].days, days) || days == "0000000" { tasks.append(vars[i]) }
                
            }
            
        }
        
        if tasks.first?.start != nil && tasks.first!.start > 0 {
            
            spaces.append(0)
            spaces.append(tasks[0].start - 1)
            
        }
        
        if tasks.count > 1 {
            
            for i in 0..<tasks.count - 1 {
                
                if tasks[i+1].start > tasks[i].end + 1 {
                    
                    spaces.append(tasks[i].end + 1)
                    spaces.append(tasks[i+1].start - 1)
                    
                }
                
            }
            
        }
        
        if tasks.last?.end != nil && tasks.last!.end < 1439 {
            
            spaces.append(tasks.last!.end + 1)
            spaces.append(1439)
            
        }
        
        var pairs: [(Int, Int)] = []
        
        for i in stride(from: 0, to: spaces.count - 1, by: 2) {
            
            let pair = (spaces[i], spaces[i + 1])
            pairs.append(pair)
            
        }
        
        return pairs
        
    }
    
}

// Function that returns true if the current day of the week has a 1 value in a string of 7 characters that represent the days of the week
func isToday(_ currentDayOfWeek: String) -> Bool {
    
    let currentDate = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "e"
    let dayOfWeekString = dateFormatter.string(from: currentDate)
    
    if currentDayOfWeek == "0000000" { return true }
    
    if let currentDay = Int(dayOfWeekString) {
        
        // Adjust the index to start from 0 (Monday) to 6 (Sunday)
        let adjustedIndex = (currentDay + 5) % 7
        return currentDayOfWeek[currentDayOfWeek.index(currentDayOfWeek.startIndex, offsetBy: adjustedIndex)] == "1"
        
    }

    return false
    
}

// Function that compares tro strings of seven digits and return true if a 1 is in the extact same position in both
func isIncluded(_ string1: String, _ string2: String) -> Bool {
    
    for (char1, char2) in zip(string1, string2) {
        if (char1 == "1" && char2 == "1") || string1 == "0000000" || string2 == "0000000" {
            return true
        }
    }
    
    // No matching "1"s found at the same position
    return false
}

// Function that receive a date and returns a short date string
func dateStr(_ date: Date) -> String {
    let formatter1 = DateFormatter()
    formatter1.dateStyle = .short
    
    return formatter1.string(from: date)
}

// Checks if both dates conceide of don't
func checkDate(_ first: String, _ second: String) -> Bool {
    return first != second
}

// To delay the long press of the buttons
extension View {
    func delaysTouches(for duration: TimeInterval = 0.25, onTap action: @escaping () -> Void = {}) -> some View {
        modifier(DelaysTouches(duration: duration, action: action))
    }
}

// To delay the long press of the buttons
struct DelaysTouches: ViewModifier {
    @State private var disabled = false
    @State private var touchDownDate: Date? = nil

    var duration: TimeInterval
    var action: () -> Void

    func body(content: Content) -> some View {
        Button(action: action) {
            content
        }
        .buttonStyle(DelaysTouchesButtonStyle(disabled: $disabled, duration: duration, touchDownDate: $touchDownDate))
        .disabled(disabled)
    }
}

// To delay the long press of the buttons
fileprivate struct DelaysTouchesButtonStyle: ButtonStyle {
    @Binding var disabled: Bool
    var duration: TimeInterval
    @Binding var touchDownDate: Date?

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { handleIsPressed(isPressed: configuration.isPressed)}
            
    }

    private func handleIsPressed(isPressed: Bool) {
        if isPressed {
            let date = Date()
            touchDownDate = date

            DispatchQueue.main.asyncAfter(deadline: .now() + max(duration, 0)) {
                if date == touchDownDate {
                    disabled = true

                    DispatchQueue.main.async {
                        disabled = false
                    }
                }
            }
        } else {
            touchDownDate = nil
            disabled = false
        }
    }
}

struct TextFieldLimitModifer: ViewModifier {
    @Binding var value: String
    var length: Int

    func body(content: Content) -> some View {
        content
            .onReceive(value.publisher.collect()) {
                value = String($0.prefix(length))
            }
    }
}

extension View {
    func limitInputLength(value: Binding<String>, length: Int) -> some View {
        self.modifier(TextFieldLimitModifer(value: value, length: length))
    }
}
