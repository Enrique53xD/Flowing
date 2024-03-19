//
//  VariableManager.swift
//  Flowing
//
//  Created by Saúl González on 19/01/24.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class taskItem: Identifiable {
    
    var id: String
    var name: String
    var color: String
    var desc: String
    var symbol: String
    var start: Int
    var end: Int
    var done: Bool
    var days: String
   
    
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

@Model
class toDoItem: Identifiable {
    
    var id: String
    var name: String
    var color: String
    var desc: String
    var symbol: String
    var done: Bool
    var daily: Bool
    var date: String
   
    
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

@Model
class progressiveItem: Identifiable {
    
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



@Model
class settingsItem: Identifiable {
    var id: String
    var customMainColor: Bool
    var mainColor: String
    
    init(customMainColor: Bool, mainColor: String) {
        self.id = UUID().uuidString
        self.customMainColor = customMainColor
        self.mainColor = mainColor
    }
}
