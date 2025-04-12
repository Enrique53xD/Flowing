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
class taskItem: Identifiable, Codable {
    
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
    
    func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(color, forKey: .color)
            try container.encode(desc, forKey: .desc)
            try container.encode(symbol, forKey: .symbol)
            try container.encode(start, forKey: .start)
            try container.encode(end, forKey: .end)
            try container.encode(done, forKey: .done)
            try container.encode(days, forKey: .days)
        }
        
        // Decodable conformance
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            color = try container.decode(String.self, forKey: .color)
            desc = try container.decode(String.self, forKey: .desc)
            symbol = try container.decode(String.self, forKey: .symbol)
            start = try container.decode(Int.self, forKey: .start)
            end = try container.decode(Int.self, forKey: .end)
            done = try container.decode(Bool.self, forKey: .done)
            days = try container.decode(String.self, forKey: .days)
        }
        
        // CodingKeys enum
        private enum CodingKeys: String, CodingKey {
            case id, name, color, desc, symbol, start, end, done, days
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
    var githubEnabled: Bool
    var githubApiKey: String
    var notify: Bool
    
    //Initialization
    
    init(customMainColor: Bool, mainColor: String, textColor: String, customTextColor: Bool, showFreeTimes: Bool, customHome: Bool, githubEnabled: Bool, githubApiKey: String, notify: Bool) {
        self.id = UUID().uuidString
        self.customMainColor = customMainColor
        self.mainColor = mainColor
        self.customTextColor = customTextColor
        self.textColor = textColor
        self.showFreeTimes = showFreeTimes
        self.customHome = customHome
        self.githubEnabled = githubEnabled
        self.githubApiKey = githubApiKey
        self.notify = notify
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
    @Published var updateGitHub = false
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
    var githubEnabled: Bool = false
    var githubApiKey: String = ""
    var notify: Bool = false
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


