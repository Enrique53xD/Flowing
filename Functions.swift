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
import OctoKit

// MARK: Extensions

// Extension to convert a Color variable to a hex
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

// Extension to convert hex to a Color variable
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

// Extension to get the screen size
extension UIScreen {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}

// Extension to transform a Date variable to HH:mm format
extension Date {
    func toHoursAndMinutes() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let dateString = dateFormatter.string(from: self)
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
    
    return actual >= start && actual <= end
}

// Function to transform an integer to HH:mm
func transformMinutes(minute: Int) -> String {
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
    if start == end {
        return "\(transformMinutes(minute: start))"
    } else {
        return "\(transformMinutes(minute: start)) - \(transformMinutes(minute: end))"
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

// Function to create a new Settings Object
func newSettings(_ context: ModelContext) {
    let item = settingsItem1(customMainColor: false, mainColor: Color.red.toHex()!, textColor: Color.cyan.toHex()!, customTextColor: false, showFreeTimes: false, customHome: false, githubEnabled: false, githubApiKey: "")
    context.insert(item)
}

// Function to get the free time spaces
func getFreeTimes(_ vars: [taskItem], days: String, allTasks: Bool) -> [(Int, Int)] {
    var spaces = [Int]()
    var tasks = [taskItem]()
    
    if vars.count == 0 {
        return []
    } else {
        for i in 0..<vars.count {
            if !allTasks {
                if isToday(vars[i].days) || vars[i].days == "0000000" {
                    tasks.append(vars[i])
                }
            } else {
                if isIncluded(vars[i].days, days) || days == "0000000" {
                    tasks.append(vars[i])
                }
            }
        }
        
        if let firstTask = tasks.first, let lastTask = tasks.last {
            if firstTask.start > 0 {
                spaces.append(0)
                spaces.append(firstTask.start - 1)
            }
            
            for i in 0..<tasks.count - 1 {
                if tasks[i+1].start > tasks[i].end + 1 {
                    spaces.append(tasks[i].end + 1)
                    spaces.append(tasks[i+1].start - 1)
                }
            }
            
            if lastTask.end < 1439 {
                spaces.append(lastTask.end + 1)
                spaces.append(1439)
            }
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
    
    if currentDayOfWeek == "0000000" {
        return true
    }
    
    if let currentDay = Int(dayOfWeekString) {
        // Adjust the index to start from 0 (Monday) to 6 (Sunday)
        let adjustedIndex = (currentDay + 5) % 7
        return currentDayOfWeek[currentDayOfWeek.index(currentDayOfWeek.startIndex, offsetBy: adjustedIndex)] == "1"
    }
    
    return false
}

// Function that compares two strings of seven digits and returns true if a 1 is in the exact same position in both
func isIncluded(_ string1: String, _ string2: String) -> Bool {
    for (char1, char2) in zip(string1, string2) {
        if (char1 == "1" && char2 == "1") || string1 == "0000000" || string2 == "0000000" {
            return true
        }
    }
    
    // No matching "1"s found at the same position
    return false
}

// Function that receives a date and returns a short date string
func dateStr(_ date: Date) -> String {
    let formatter1 = DateFormatter()
    formatter1.dateStyle = .short
    return formatter1.string(from: date)
}

// Checks if both dates coincide or not
func checkDate(_ first: String, _ second: String) -> Bool {
    return first != second
}

// Modifier to limit the input length of a TextField
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

// MARK: GitHub API Functions

// Function to get the login name of the authenticated user
func getLogin(_ config: TokenConfiguration) async -> String {
    var login = "..."
    
    do {
        let user = try await Octokit(config).me()
        login = user.login ?? "Not Found"
        print(login)
    } catch {
        print(error)
        login = "Error"
    }
    
    return login
}

// Function to get the repositories of the authenticated user
func getRepos(_ config: TokenConfiguration, _ login: String) async -> [reposWithIssues] {
    var repos: [reposWithIssues] = []
    
    do {
        let repo = try await Octokit(config).repositories()
        repos = []
        
        for i in repo {
            let temp = reposWithIssues(name: i.name ?? "No name", issues: await getIssues(repoName: i.name ?? "No name", login: login, config: config))
            repos.append(temp)
        }
    } catch {
        
    }
    
    return repos
}

// Function to get the issues of a repository
func getIssues(repoName: String, login: String, config: TokenConfiguration) async -> [Issue] {
    var issuesArr: [Issue]?
    issuesArr = []
    
    do {
        let issues = try await Octokit(config).issues(owner: login, repository: repoName, state: .all)
        issuesArr = []
        
        for issue in issues {
            issuesArr?.append(issue)
        }
    } catch {
        
    }
    
    return issuesArr!
}

