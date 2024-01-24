//
//  VariableManager.swift
//  Flowing
//
//  Created by Saúl González on 19/01/24.
//

import Foundation
import SwiftUI

struct TaskVariables {
    var color: Color
    var name: String
    var description: String
    var symbol: String
    var start: Int
    var end: Int

}

struct Day: Identifiable {
    let id = UUID()
    let name: String
    var isSelected: Bool
}
