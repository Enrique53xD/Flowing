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
import UserNotifications

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



// Extension to transform a Date variable to HH:mm format
extension Date {
    func toHoursAndMinutes() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
    func timeComponents() -> DateComponents {
        let calendar = Calendar.current
        let hours = calendar.dateComponents([.hour, .minute, .second], from: self)
        return hours
    }

}

extension Int {
    enum TimeUnit {
        case hours
        case minutes
    }
    
    func toTime(_ unit: TimeUnit) -> Int {
        switch unit {
        case .hours:
            return self / 60
        case .minutes:
            return self % 60
        }
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

func minutesPassedToday() -> Int {
    // Get the current date and time
    let now = Date()

    // Get the start of today (midnight)
    let today = Calendar.current.startOfDay(for: now)

    // Calculate the time interval between the start of today and now
    let interval = now.timeIntervalSince(today)

    // Convert the interval to minutes
    let minutes = Int(interval / 60)

    return minutes
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
    
    // Check if notifications are enabled before scheduling
    let fetchDescriptor = FetchDescriptor<settingsItem>()
    if let settings = try? context.fetch(fetchDescriptor).first, settings.notify {
        // Use the new smart notification scheduling system
        setupNotificationsForUpcomingTasks(context)
    }
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
    let item = settingsItem(customMainColor: false, mainColor: Color.red.toHex()!, textColor: Color.cyan.toHex()!, customTextColor: false, showFreeTimes: false, customHome: false, githubEnabled: false, githubApiKey: "", notify: false)
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

// Extension to get the screen size was put here due to incompatibility with apple watch membership
extension UIScreen {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
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

// MARK: - Notification Functions

// This function schedules the next occurrence for each task
func scheduleSmartNotifications(_ tasks: [taskItem], before: Int = 5) {
    print("Smart scheduling notifications with \(before) minutes advance notice")
    
    // Clear all pending notifications first
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    
    // Current date components
    let calendar = Calendar.current
    let now = Date()
    let currentWeekday = calendar.component(.weekday, from: now) // 1 is Sunday, 2 is Monday, etc.
    let adjustedWeekday = currentWeekday == 1 ? 6 : currentWeekday - 2 // Convert to 0-6 index where 0 is Monday
    
    // For tracking how many notifications we've scheduled
    var scheduledCount = 0
    let maxNotifications = 60 // Keeping a buffer below the 64 limit
    
    for task in tasks {
        // Skip if we're at the notification limit
        if scheduledCount >= maxNotifications {
            print("⚠️ Notification limit reached! Some tasks won't be notified.")
            break
        }
        
        // Check all weekdays, starting with today
        for offset in 0..<7 {
            // Calculate the day index (0-6) we're checking, wrapping around the week
            let dayIndex = (adjustedWeekday + offset) % 7
            
            // Check if this task is scheduled for this day
            if task.days[task.days.index(task.days.startIndex, offsetBy: dayIndex)] == "1" {
                let dayName = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"][dayIndex]
                
                // Set up the notification date
                var dateComponents = DateComponents()
                dateComponents.weekday = dayIndex == 6 ? 1 : dayIndex + 2 // Convert to Calendar.weekday (1-7, 1 is Sunday)
                dateComponents.hour = task.start.toTime(.hours)
                dateComponents.minute = task.start.toTime(.minutes)
                
                // For same-day notifications, check if the time has already passed
                if offset == 0 {
                    let taskTimeToday = calendar.date(bySettingHour: task.start.toTime(.hours),
                                                      minute: task.start.toTime(.minutes),
                                                      second: 0,
                                                      of: now)!
                    
                    if taskTimeToday <= now {
                        print("⏭️ Skipping today's notification for \(task.name) - time already passed")
                        continue // Skip to next day
                    }
                }
                
                // Schedule notification at task start time
                let content = UNMutableNotificationContent()
                content.title = task.name
                content.body = task.desc == "" ? "\(task.name) starts now!" : task.desc
                content.sound = .default
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let identifier = "\(task.id)_\(dayIndex)_start"
                
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("❌ Error scheduling notification for \(task.name): \(error)")
                    } else {
                        print("✅ Scheduled \(task.name) on \(dayName) at \(task.start.toTime(.hours)):\(task.start.toTime(.minutes))")
                    }
                }
                scheduledCount += 1
                
                // Schedule notification before task start
                if before > 0 && scheduledCount < maxNotifications {
                    // Calculate time before task
                    let beforeTime = task.start - before
                    
                    // If the "before" time would be on the previous day, skip this notification
                    if beforeTime < 0 {
                        continue
                    }
                    
                    var beforeComponents = DateComponents()
                    beforeComponents.weekday = dayIndex == 6 ? 1 : dayIndex + 2
                    beforeComponents.hour = beforeTime.toTime(.hours)
                    beforeComponents.minute = beforeTime.toTime(.minutes)
                    
                    // For same-day notifications, check if the time has already passed
                    if offset == 0 {
                        let beforeTimeToday = calendar.date(bySettingHour: beforeTime.toTime(.hours),
                                                           minute: beforeTime.toTime(.minutes),
                                                           second: 0,
                                                           of: now)!
                        
                        if beforeTimeToday <= now {
                            print("⏭️ Skipping today's reminder for \(task.name) - time already passed")
                            continue // Skip this notification
                        }
                    }
                    
                    let beforeContent = UNMutableNotificationContent()
                    beforeContent.title = task.name
                    beforeContent.body = "\(task.name) starts in \(before) minutes!"
                    beforeContent.sound = .default
                    
                    let beforeTrigger = UNCalendarNotificationTrigger(dateMatching: beforeComponents, repeats: false)
                    let beforeIdentifier = "\(task.id)_\(dayIndex)_before"
                    
                    let beforeRequest = UNNotificationRequest(identifier: beforeIdentifier, content: beforeContent, trigger: beforeTrigger)
                    
                    UNUserNotificationCenter.current().add(beforeRequest) { error in
                        if let error = error {
                            print("❌ Error scheduling reminder for \(task.name): \(error)")
                        } else {
                            print("⏰ Scheduled reminder for \(task.name) on \(dayName) at \(beforeTime.toTime(.hours)):\(beforeTime.toTime(.minutes))")
                        }
                    }
                    scheduledCount += 1
                }
                
                // Only schedule the next occurrence of this task and then break
                break
            }
        }
    }
    
    print("📲 Scheduled \(scheduledCount) notifications")
}

// Add this function for app launch and to be called when the app comes to foreground
func setupNotificationsForUpcomingTasks(_ context: ModelContext, before: Int = 5) {
    // Check if notifications are enabled in settings
    let settingsFetchDescriptor = FetchDescriptor<settingsItem>()
    guard let settings = try? context.fetch(settingsFetchDescriptor).first, settings.notify else {
        print("ℹ️ Notifications are disabled in settings")
        return
    }
    
    // Fetch all tasks
    let tasksFetchDescriptor = FetchDescriptor<taskItem>(sortBy: [SortDescriptor(\taskItem.start)])
    guard let tasks = try? context.fetch(tasksFetchDescriptor) else {
        print("❌ Could not fetch tasks")
        return
    }
    
    // Schedule the next occurrence of each task
    scheduleSmartNotifications(tasks, before: before)
}

// MARK: - Legacy Notification Functions (Commented out)

/*
func scheduleAll(_ tasks: [taskItem], before: Int? = nil){
    // Clear existing notifications first
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    
    // Get the notification time (in minutes)
    let notificationTime = before ?? 5
    
    // Schedule notifications for each task
    for task in tasks {
        scheduleTaskNotifications(task, beforeStart: notificationTime)
    }
}

func scheduleTaskNotifications(_ task: taskItem, beforeStart: Int? = nil, ends: Bool? = false){
    for (index, day) in task.days.enumerated() {
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id+"\(index)"+"a"])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id+"\(index)"+"b"])
        
        if day == "1"{
            
            // Schedule notification for when the task starts
            var date = DateComponents()
            date.weekday = index == 6 ? 1 : index + 2
            date.hour = task.start.toTime(.hours)
            date.minute = task.start.toTime(.minutes)
            
            let content = UNMutableNotificationContent()
            content.title = task.name
            content.body = task.desc == "" ? "\(task.name) starts now!" : task.desc
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
            
            let request = UNNotificationRequest(identifier: task.id+"\(index)"+"a", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                } else {
                    print("\(task.name) at \(String(date.hour!)):\(String(date.minute!))")
                }
            }
            
            // Schedule notification 5 minutes before the task starts
            if beforeStart != nil {
                var date = DateComponents()
                date.weekday = index == 6 ? 1 : index + 2
                date.hour = (task.start-beforeStart!).toTime(.hours)
                date.minute = (task.start-beforeStart!).toTime(.minutes)
                
                let content = UNMutableNotificationContent()
                content.title = task.name
                content.body = "\(task.name) starts in \(String(beforeStart!)) minutes!"
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
                
                let request = UNNotificationRequest(identifier: task.id+"\(index)"+"b", content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error)")
                    } else {
                        print("\(task.name) at \(String(date.hour!)):\(String(date.minute!))")
                    }
                }
            }
        }
    }
}

func deleteTaskNotifications(_ id: String){
    
    for i in 0...6 {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id+"\(i)"+"a"])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id+"\(i)"+"b"])
    }
    print("\(id) deleted successfully")
}
*/
