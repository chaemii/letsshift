import WidgetKit
import SwiftUI

@main
struct ShiftCalendarWidgetBundle: WidgetBundle {
    var body: some Widget {
        ShiftCalendarWidget()
        TodayShiftWidget()
    }
} 