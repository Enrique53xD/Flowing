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
    // give every property a default
    var id: String       = UUID().uuidString
    var name: String     = ""
    var color: String    = ""
    var desc: String     = ""
    var symbol: String   = ""
    var start: Int       = 0
    var end: Int         = 0
    var done: Bool       = false
    var days: String     = ""

    /// Zero‑arg init for SwiftData
    init() {}

    /// Your existing initializer
    init(name: String,
         color: String,
         desc: String,
         symbol: String,
         start: Int,
         end: Int,
         done: Bool,
         days: String)
    {
        self.name   = name
        self.color  = color
        self.desc   = desc
        self.symbol = symbol
        self.start  = start
        self.end    = end
        self.done   = done
        self.days   = days
    }

    // Codable conformance
    private enum CodingKeys: String, CodingKey {
        case id, name, color, desc, symbol, start, end, done, days
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,     forKey: .id)
        try c.encode(name,   forKey: .name)
        try c.encode(color,  forKey: .color)
        try c.encode(desc,   forKey: .desc)
        try c.encode(symbol, forKey: .symbol)
        try c.encode(start,  forKey: .start)
        try c.encode(end,    forKey: .end)
        try c.encode(done,   forKey: .done)
        try c.encode(days,   forKey: .days)
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id     = try c.decode(String.self, forKey: .id)
        name   = try c.decode(String.self, forKey: .name)
        color  = try c.decode(String.self, forKey: .color)
        desc   = try c.decode(String.self, forKey: .desc)
        symbol = try c.decode(String.self, forKey: .symbol)
        start  = try c.decode(Int.self,    forKey: .start)
        end    = try c.decode(Int.self,    forKey: .end)
        done   = try c.decode(Bool.self,   forKey: .done)
        days   = try c.decode(String.self, forKey: .days)
    }
}

// MARK: - ToDo Object

@Model
class toDoItem: Identifiable {
    var id: String     = UUID().uuidString
    var name: String   = ""
    var color: String  = ""
    var desc: String   = ""
    var symbol: String = ""
    var done: Bool     = false
    var daily: Bool    = false
    var date: String   = dateStr(Date.now)

    init() {}

    init(name: String,
         color: String,
         desc: String,
         symbol: String,
         done: Bool,
         daily: Bool = false,
         date: String = dateStr(Date.now))
    {
        self.name   = name
        self.color  = color
        self.desc   = desc
        self.symbol = symbol
        self.done   = done
        self.daily  = daily
        self.date   = date
    }
}

// MARK: - Progressive Object

@Model
class progressiveItem: Identifiable {
    var id: String       = UUID().uuidString
    var name: String     = ""
    var color: String    = ""
    var desc: String     = ""
    var symbol: String   = ""
    var progress: CGFloat = 0
    var goal: CGFloat     = 0
    var preffix: String   = ""
    var suffix: String    = ""
    var daily: Bool       = false
    var date: String      = dateStr(Date.now)

    init() {}

    init(name: String,
         color: String,
         desc: String,
         symbol: String,
         progress: CGFloat,
         goal: CGFloat,
         preffix: String,
         suffix: String,
         daily: Bool = false,
         date: String = dateStr(Date.now))
    {
        self.name     = name
        self.color    = color
        self.desc     = desc
        self.symbol   = symbol
        self.progress = progress
        self.goal     = goal
        self.preffix  = preffix
        self.suffix   = suffix
        self.daily    = daily
        self.date     = date
    }
}

// MARK: - Settings Object

@Model
class settingsItem: Identifiable {
    var id: String            = UUID().uuidString
    var customMainColor: Bool = false
    var mainColor: String     = ""
    var customTextColor: Bool = false
    var textColor: String     = ""
    var showFreeTimes: Bool   = false
    var customHome: Bool      = false
    var githubEnabled: Bool   = false
    var githubApiKey: String  = ""
    var notify: Bool          = false

    init() {}

    init(customMainColor: Bool,
         mainColor: String,
         textColor: String,
         customTextColor: Bool,
         showFreeTimes: Bool,
         customHome: Bool,
         githubEnabled: Bool,
         githubApiKey: String,
         notify: Bool)
    {
        self.customMainColor = customMainColor
        self.mainColor       = mainColor
        self.customTextColor = customTextColor
        self.textColor       = textColor
        self.showFreeTimes   = showFreeTimes
        self.customHome      = customHome
        self.githubEnabled   = githubEnabled
        self.githubApiKey    = githubApiKey
        self.notify          = notify
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
        lhs.name == rhs.name
    }
}

// MARK: - Free Times Variables

class freeTimesVariables: ObservableObject {
    @Published var tasks       = [taskItem]()
    @Published var freeTimes   = [(Int,Int)]()
    @Published var update      = false
    @Published var updateGitHub = false
}

// MARK: - Personalization Variables

struct personalizationVariables {
    var customColor: Bool      = false
    var mainColor: Color       = .primary
    var customTextColor: Bool  = false
    var textColor: Color       = .primary
    var customHome: Bool       = false
    var customIcon: String     = "clock"
    var allTasks: Bool         = false
    var showFreeTimes: Bool    = false
    var githubEnabled: Bool    = false
    var githubApiKey: String   = ""
    var notify: Bool           = false
}

// MARK: - Creating Variables

struct creatingVariables {
    var creatingTask: Bool        = false
    var creatingToDo: Bool        = false
    var creatingProgressive: Bool = false
    var creatingSome: Bool        = false
    var creatingIssue: Bool       = false
}

// MARK: - Task Object Variables

struct taskObjectVariables {
    var days: String              = "0000000"
    var sheetContentHeight: CGFloat = 0
}
