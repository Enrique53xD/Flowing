//
//  Item.swift
//  Flowing
//
//  Created by Saúl González on 9/01/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
