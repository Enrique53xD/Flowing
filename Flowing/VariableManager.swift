//
//  VariableManager.swift
//  Flowing
//
//  Created by Saúl González on 19/01/24.
//

import Foundation
import SwiftUI

struct Day: Identifiable {
    let id = UUID()
    let name: String
    var isSelected: Bool
}

struct TaskVariables: Identifiable {
    let id = UUID()
    let color: Color
    let name: String
    let description: String
    let symbol: String
    let start: Int
    let end: Int
    let done: Bool
    
}
