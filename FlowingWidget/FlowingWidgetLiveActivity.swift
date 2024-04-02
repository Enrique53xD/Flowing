//
//  FlowingWidgetLiveActivity.swift
//  FlowingWidget
//
//  Created by Saúl González on 26/03/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FlowingWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct FlowingWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FlowingWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension FlowingWidgetAttributes {
    fileprivate static var preview: FlowingWidgetAttributes {
        FlowingWidgetAttributes(name: "World")
    }
}

extension FlowingWidgetAttributes.ContentState {
    fileprivate static var smiley: FlowingWidgetAttributes.ContentState {
        FlowingWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: FlowingWidgetAttributes.ContentState {
         FlowingWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: FlowingWidgetAttributes.preview) {
   FlowingWidgetLiveActivity()
} contentStates: {
    FlowingWidgetAttributes.ContentState.smiley
    FlowingWidgetAttributes.ContentState.starEyes
}
