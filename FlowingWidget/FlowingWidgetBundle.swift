//
//  FlowingWidgetBundle.swift
//  FlowingWidget
//
//  Created by Saúl González on 3/04/24.
//

import WidgetKit
import SwiftUI

@main
struct FlowingWidgetBundle: WidgetBundle {
    var body: some Widget {
        FlowingWidget()
        LockFlowingWidget()
        FlowingWidgetLiveActivity()
    }
}
