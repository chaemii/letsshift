//
//  ShiftCalendarWidgetExtensionBundle.swift
//  ShiftCalendarWidgetExtension
//
//  Created by cham on 7/24/25.
//

import WidgetKit
import SwiftUI

@main
struct ShiftCalendarWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        WeekScheduleWidget()
        TodayShiftWidget()
    }
}
