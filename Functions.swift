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

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
}


extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

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

func transforMinutes(minute: Int) -> String {
    var minutes = minute
    var hours = 0
    while minutes >= 60 {
        minutes -= 60
        hours += 1
    }
    return "\(String(format: "%02d", hours)):\(String(format: "%02d", minutes))"
}


func convertToMinutes(from timeString: String) -> Int {
    let components = timeString.components(separatedBy: ":")
    
    if components.count == 2,
       let hours = Int(components[0]),
       let minutes = Int(components[1]) {
        return hours * 60 + minutes
    }
    
    return 0 // Default value if the conversion fails
}



func formatTaskTime(start: Int, end: Int) -> String {
    if start==end {
        return "\(transforMinutes(minute: start))"
    } else {
        return "\(transforMinutes(minute: start)) - \(transforMinutes(minute: end))"
    }
}

func transformDate(date: Date) -> String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    let dateString = dateFormatter.string(from: date)
    
    return dateString
}

func formatProgressive(preffix: String = "", suffix: String = "", progress: Any, goal: Any) -> String {
    if let progressInt = progress as? Int, let goalInt = goal as? Int {
        return "\(preffix)\(progressInt)\(suffix) / \(preffix)\(goalInt)\(suffix)"
    } else {
        let progressValue = (progress as? Double) ?? (Double("\(progress)") ?? progress)
        let goalValue = (goal as? Double) ?? (Double("\(goal)") ?? goal)
        return "\(preffix)\(progressValue)\(suffix) / \(preffix)\(goalValue)\(suffix)"
    }
}


func newTask(_ context: ModelContext, name: String, color: String, desc: String, symbol: String, start: Int, end: Int, days: String) {
    
    let item = taskItem(name: name, color: color, desc: desc, symbol: symbol, start: start, end: end, done: checkCurrentTime(start: start, end: end), days: days)
    
    context.insert(item)
}

func newToDo(_ context: ModelContext, name: String, color: String, desc: String, symbol: String) {
    
    let item = toDoItem(name: name, color: color, desc: desc, symbol: symbol, done: false)
    context.insert(item)
}

func newProgressive(_ context: ModelContext, name: String, color: String, desc: String, symbol: String, goal: CGFloat, preffix: String, suffix: String) {
    
    let item = progressiveItem(name: name, color: color, desc: desc, symbol: symbol, progress: 0, goal: goal, preffix: preffix, suffix: suffix)
    context.insert(item)
}

func newSettings(_ context: ModelContext) {
    
    let item = settingsItm(customMainColor: false, mainColor: Color.red.toHex()!, widgetRange: false, widgetName: false)
    context.insert(item)
}


func isToday(_ currentDayOfWeek: String) -> Bool {
    let currentDate = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "e"
    let dayOfWeekString = dateFormatter.string(from: currentDate)
    
    if let currentDay = Int(dayOfWeekString) {
        // Adjust the index to start from 0 (Monday) to 6 (Sunday)
        let adjustedIndex = (currentDay + 5) % 7
        return currentDayOfWeek[currentDayOfWeek.index(currentDayOfWeek.startIndex, offsetBy: adjustedIndex)] == "1"
    }
    
    return false
}

func isIncluded(_ string1: String, _ string2: String) -> Bool {
    
    for (char1, char2) in zip(string1, string2) {
        if char1 == "1" && char2 == "1" {
            return true
        }
    }
    
    // No matching "1"s found at the same position
    return false
}

func dateStr(_ date: Date) -> String {
    let formatter1 = DateFormatter()
    formatter1.dateStyle = .short
    
    return formatter1.string(from: date)
}

func checkDate(_ first: String, _ second: String) -> Bool {
    return first != second
}






