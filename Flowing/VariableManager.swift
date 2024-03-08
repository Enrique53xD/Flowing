//
//  VariableManager.swift
//  Flowing
//
//  Created by Saúl González on 19/01/24.
//

import Foundation
import SwiftUI
import SwiftData
import CoreData



struct TaskVariables: Identifiable {
    let id = UUID()

    let name: String

    let start: Int

    
}

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


