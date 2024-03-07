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

    let name: String

    let start: Int

    
}
