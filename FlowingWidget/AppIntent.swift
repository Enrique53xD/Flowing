//
//  AppIntent.swift
//
//  Created by Saúl González on 9/04/24.
//

import WidgetKit
import AppIntents
import SwiftUI

struct WidgetOptions: AppEntity {
    var id: String
    var use: String
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Widget Options"
    static var defaultQuery = WidgetColorQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(id)")
    }
    // Mocked Data
    static let options: [WidgetOptions] = [
        WidgetOptions(id: "Nothing", use: "Nothing"),
        WidgetOptions(id: "Name", use: "Name"),
        WidgetOptions(id: "Time Range", use: "Time Range")
    ]
}

struct WidgetColorQuery: EntityQuery {
    func entities(for identifiers: [WidgetOptions.ID]) async throws -> [WidgetOptions] {
        WidgetOptions.options.filter {
            identifiers.contains($0.id)
        }
    }
    func suggestedEntities() async throws -> [WidgetOptions] {
        WidgetOptions.options
    }
    
    func defaultResult() async -> WidgetOptions? {
        WidgetOptions.options.first
    }
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

    // An example configurable parameter.
    @Parameter(title: "Top Text")
    var topText: WidgetOptions
    
    @Parameter(title: "Bottom Text")
    var bottomText: WidgetOptions
}
