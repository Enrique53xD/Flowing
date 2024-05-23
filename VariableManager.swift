//
//  VariableManager.swift
//  Flowing
//
//  Created by Saúl González on 19/01/24.
//

import Foundation
import SwiftUI
import SwiftData
import OctoKit

// MARK: - Task Object

@Model
class taskItem: Identifiable {
    
    //Variables
    
    var id: String
    var name: String
    var color: String
    var desc: String
    var symbol: String
    var start: Int
    var end: Int
    var done: Bool
    var days: String
    
    //Initialization
    
    init(name: String, color: String, desc: String, symbol: String, start: Int, end: Int, done: Bool, days: String) {
        self.id = UUID().uuidString
        self.name = name
        self.color = color
        self.desc = desc
        self.symbol = symbol
        self.start = start
        self.end = end
        self.done = done
        self.days = days
    }
}

// MARK: ToDo Object

@Model
class toDoItem: Identifiable {
    
    //Variables
    
    var id: String
    var name: String
    var color: String
    var desc: String
    var symbol: String
    var done: Bool
    var daily: Bool
    var date: String
    
    //Initialization
    
    init(name: String, color: String, desc: String, symbol: String, done: Bool, daily: Bool = false, date: String = dateStr(Date.now)) {
        self.id = UUID().uuidString
        self.name = name
        self.color = color
        self.desc = desc
        self.symbol = symbol
        self.done = done
        self.daily = daily
        self.date = date
    }
}

// MARK: - Progressive Object

@Model
class progressiveItem: Identifiable {
    
    //Variables
    
    var id: String
    var name: String
    var color: String
    var desc: String
    var symbol: String
    var progress: CGFloat
    var goal: CGFloat
    var preffix: String
    var suffix: String
    var daily: Bool
    var date: String
    
    //Initialization
    
    init(name: String, color: String, desc: String, symbol: String, progress: CGFloat, goal: CGFloat, preffix: String, suffix: String, daily: Bool = false, date: String = dateStr(Date.now)) {
        self.id = UUID().uuidString
        self.name = name
        self.color = color
        self.desc = desc
        self.symbol = symbol
        self.progress = progress
        self.goal = goal
        self.preffix = preffix
        self.suffix = suffix
        self.daily = daily
        self.date = date
    }
}

// MARK: - Settings Object

@Model
class settingsItem: Identifiable {
    
    //Variables
    
    var id: String
    var customMainColor: Bool
    var mainColor: String
    var customTextColor: Bool
    var textColor: String
    var showFreeTimes: Bool
    var customHome: Bool
    
    //Initialization
    
    init(customMainColor: Bool, mainColor: String, textColor: String, customTextColor: Bool, showFreeTimes: Bool, customHome: Bool) {
        self.id = UUID().uuidString
        self.customMainColor = customMainColor
        self.mainColor = mainColor
        self.customTextColor = customTextColor
        self.textColor = textColor
        self.showFreeTimes = showFreeTimes
        self.customHome = customHome
    }
}

// MARK: - Repositories with Issues

struct reposWithIssues: Hashable {
    var name: String
    var issues: [Issue]

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    static func == (lhs: reposWithIssues, rhs: reposWithIssues) -> Bool {
        return lhs.name == rhs.name
    }
}

// MARK: - Free Times Variables

class freeTimesVariables : ObservableObject {
    
    //Variables
    
    @Published var tasks = [taskItem]()
    @Published var freeTimes = [(Int,Int)]()
    @Published var update = false
}

// MARK: - Personalization Variables

struct personalizationVariables {
    var customColor: Bool = false
    var mainColor: Color = .primary
    var customTextColor: Bool = false
    var textColor: Color = .primary
    var customHome: Bool = false
    var customIcon: String = "clock"
    var allTasks: Bool = false
    var showFreeTimes: Bool = false
}

// MARK: - Creating Variables

struct creatingVariables {
    var creatingTask = false
    var creatingToDo = false
    var creatingProgressive = false
    var creatingSome = false
    var creatingIssue = false
}

// MARK: - Task Object Variables

struct taskObjectVariables {
    var days: String = "0000000"
    var sheetContentHeight = CGFloat(0)
}
