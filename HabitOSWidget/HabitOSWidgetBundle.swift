//
//  HabitOSWidgetBundle.swift
//  HabitOSWidget
//
//  Created by Micael on 7/3/26.
//

import WidgetKit
import SwiftUI

@main
struct HabitOSWidgetBundle: WidgetBundle {
    var body: some Widget {
        HabitOSWidget()
        HabitOSWidgetControl()
        HabitOSWidgetLiveActivity()
    }
}
