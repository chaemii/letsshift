import WidgetKit
import SwiftUI

struct TodayShiftWidget: Widget {
    let kind: String = "TodayShiftWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayShiftTimelineProvider()) { entry in
            TodayShiftWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(NSLocalizedString("today_schedule", comment: "Today's schedule"))
        .description(NSLocalizedString("today_schedule_description", comment: "Check today's work schedule."))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TodayShiftTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayShiftEntry {
        TodayShiftEntry(date: Date(), todayShift: .주간, isToday: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayShiftEntry) -> ()) {
        let entry = TodayShiftEntry(date: Date(), todayShift: getTodayShift(), isToday: true)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let entry = TodayShiftEntry(date: currentDate, todayShift: getTodayShift(), isToday: true)
        
        // 다음날 자정에 업데이트
        let nextUpdate = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func getTodayShift() -> ShiftType {
        // 실제 앱의 데이터를 사용하도록 구현
        // 현재는 샘플 데이터 반환
        let dayOfWeek = Calendar.current.component(.weekday, from: Date())
        switch dayOfWeek {
        case 1: return .주간 // 일요일
        case 2: return .야간 // 월요일
        case 3: return .휴무 // 화요일
        case 4: return .주간 // 수요일
        case 5: return .야간 // 목요일
        case 6: return .휴무 // 금요일
        case 7: return .주간 // 토요일
        default: return .주간
        }
    }
}

struct TodayShiftEntry: TimelineEntry {
    let date: Date
    let todayShift: ShiftType
    let isToday: Bool
}

struct TodayShiftWidgetEntryView: View {
    var entry: TodayShiftTimelineProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("오늘")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(getCurrentDateString())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Circle()
                    .fill(entry.todayShift.color)
                    .frame(width: family == .systemSmall ? 60 : 80, height: family == .systemSmall ? 60 : 80)
                    .overlay(
                        Text(getShiftTypeText(entry.todayShift))
                            .font(.system(size: family == .systemSmall ? 20 : 24))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                Text(getShiftTypeFullText(entry.todayShift))
                    .font(.system(size: family == .systemSmall ? 14 : 16))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                if family == .systemMedium {
                    Text(getShiftTimeText(entry.todayShift))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(hex: "EFF0F2"))
    }
    
    private func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: entry.date)
    }
    
    private func getShiftTypeText(_ shiftType: ShiftType) -> String {
        switch shiftType {
        case .주간: return "주"
        case .야간: return "야"
        case .휴무: return "휴"
        default: return "?"
        }
    }
    
    private func getShiftTypeFullText(_ shiftType: ShiftType) -> String {
        switch shiftType {
        case .주간: return "주간근무"
        case .야간: return "야간근무"
        case .휴무: return "휴무"
        default: return "근무"
        }
    }
    
    private func getShiftTimeText(_ shiftType: ShiftType) -> String {
        switch shiftType {
        case .주간: return "09:00 - 18:00"
        case .야간: return "18:00 - 09:00"
        case .휴무: return "휴식일"
        default: return ""
        }
    }
}

#Preview(as: .systemSmall) {
    TodayShiftWidget()
} timeline: {
    TodayShiftEntry(date: Date(), todayShift: .주간, isToday: true)
}

#Preview(as: .systemMedium) {
    TodayShiftWidget()
} timeline: {
    TodayShiftEntry(date: Date(), todayShift: .야간, isToday: true)
} 