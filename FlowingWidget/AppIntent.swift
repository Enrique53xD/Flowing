//
//  AppIntent.swift
//
//  Created by Saúl González on 9/04/24.
//

import WidgetKit
import AppIntents
import SwiftUI

// Define a struct for WidgetOptions that conforms to the AppEntity protocol
struct WidgetOptions: AppEntity {
    var id: String
    var use: String
    
    // Define a static variable for the type display representation
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Widget Options"
    
    // Define a static variable for the default query
    static var defaultQuery = WidgetQuery()
    
    // Define a computed property for the display representation
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(id)")
    }
    
    // Define some sample options
    static let options: [WidgetOptions] = [
        WidgetOptions(id: "Nothing", use: "Nothing"),
        WidgetOptions(id: "Name", use: "Name"),
        WidgetOptions(id: "Time Range", use: "Time Range")
    ]
}

// Define a struct for WidgetQuery that conforms to the EntityQuery protocol
struct WidgetQuery: EntityQuery {
    // Implement the entities(for:) method to return entities for the given identifiers
    func entities(for identifiers: [WidgetOptions.ID]) async throws -> [WidgetOptions] {
        WidgetOptions.options.filter {
            identifiers.contains($0.id)
        }
    }
    
    // Implement the suggestedEntities() method to return suggested entities
    func suggestedEntities() async throws -> [WidgetOptions] {
        WidgetOptions.options
    }
    
    // Implement the defaultResult() method to return the default result
    func defaultResult() async -> WidgetOptions? {
        WidgetOptions.options.first
    }
}

// Define a struct for ConfigurationAppIntent that conforms to the WidgetConfigurationIntent protocol
struct ConfigurationAppIntent: WidgetConfigurationIntent {
    // Define a static variable for the title
    static var title: LocalizedStringResource = "Configuration"
    
    // Define a static variable for the description
    static var description = IntentDescription("This is an example widget.")
    
    // Define a configurable parameter for the top text
    @Parameter(title: "Top Text")
    var topText: WidgetOptions?
    
    // Define a configurable parameter for the bottom text
    @Parameter(title: "Bottom Text")
    var bottomText: WidgetOptions?
}
