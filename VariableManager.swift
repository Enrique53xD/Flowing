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


// MARK: Objects

// Task Object
@Model
class taskItem: Identifiable {
    
    // Declaration of variables
    var id: String
    var name: String
    var color: String
    var desc: String
    var symbol: String
    var start: Int
    var end: Int
    var done: Bool
    var days: String
    
    // Initialization of variables
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

// ToDo Object
@Model
class toDoItem: Identifiable {
    
    // Declaration of variables
    var id: String
    var name: String
    var color: String
    var desc: String
    var symbol: String
    var done: Bool
    var daily: Bool
    var date: String
    
    // Initialization of variables
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

// Progressive Object
@Model
class progressiveItem: Identifiable {
    
    // Declaration of variables
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
    
    // Initialization of variables
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

// Settings Object


@Model
class settingsItem: Identifiable {
    
    // Declaration of variables
    var id: String
    var customMainColor: Bool
    var mainColor: String
    var customTextColor: Bool
    var textColor: String
    var showFreeTimes: Bool
    var customHome: Bool
    
    // TODO: add show free times variable
    
    // Initialization of variables
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
 


 
 


