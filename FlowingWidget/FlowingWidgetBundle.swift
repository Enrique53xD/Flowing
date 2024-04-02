//
//  FlowingWidgetBundle.swift
//  FlowingWidget
//
//  Created by Saúl González on 26/03/24.
//

import WidgetKit
import SwiftUI

@main
struct FlowingWidgetBundle: WidgetBundle {
    var body: some Widget {
        FlowingWidget()
        FlowingWidgetLiveActivity()
    }
}
