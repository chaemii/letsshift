import WidgetKit
import SwiftUI

struct ShiftCalendarWidget: Widget {
    let kind: String = "ShiftCalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ShiftCalendarTimelineProvider()) { entry in
            ShiftCalendarWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("일주일 스케줄")
        .description("일주일치 근무 스케줄을 확인하세요.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct ShiftCalendarTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> ShiftCalendarEntry {
        ShiftCalendarEntry(date: Date(), weekSchedule: generateSampleWeekSchedule())
    }

    func getSnapshot(in context: Context, completion: @escaping (ShiftCalendarEntry) -> ()) {
        let entry = ShiftCalendarEntry(date: Date(), weekSchedule: generateSampleWeekSchedule())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let entry = ShiftCalendarEntry(date: currentDate, weekSchedule: generateWeekSchedule())
        
        // 다음날 자정에 업데이트
        let nextUpdate = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func generateWeekSchedule() -> [DaySchedule] {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        var weekSchedule: [DaySchedule] = []
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                let dayName = getDayName(from: date)
                let shiftType = getShiftTypeForDate(date)
                weekSchedule.append(DaySchedule(day: dayName, shiftType: shiftType, date: date))
            }
        }
        
        return weekSchedule
    }
    
    private func generateSampleWeekSchedule() -> [DaySchedule] {
        return [
            DaySchedule(day: "월", shiftType: .주간, date: Date()),
            DaySchedule(day: "화", shiftType: .야간, date: Date()),
            DaySchedule(day: "수", shiftType: .휴무, date: Date()),
            DaySchedule(day: "목", shiftType: .주간, date: Date()),
            DaySchedule(day: "금", shiftType: .야간, date: Date()),
            DaySchedule(day: "토", shiftType: .휴무, date: Date()),
            DaySchedule(day: "일", shiftType: .주간, date: Date())
        ]
    }
    
    private func getDayName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    private func getShiftTypeForDate(_ date: Date) -> ShiftType {
        // 실제 앱의 데이터를 사용하도록 구현
        // 현재는 샘플 데이터 반환
        let dayOfWeek = Calendar.current.component(.weekday, from: date)
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

struct ShiftCalendarEntry: TimelineEntry {
    let date: Date
    let weekSchedule: [DaySchedule]
}

struct DaySchedule {
    let day: String
    let shiftType: ShiftType
    let date: Date
}

struct ShiftCalendarWidgetEntryView: View {
    var entry: ShiftCalendarTimelineProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("일주일 스케줄")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(getCurrentDateString())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if family == .systemLarge {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(entry.weekSchedule, id: \.day) { daySchedule in
                        VStack(spacing: 4) {
                            Text(daySchedule.day)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Circle()
                                .fill(daySchedule.shiftType.color)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Text(getShiftTypeText(daySchedule.shiftType))
                                        .font(.system(size: 8))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                        }
                    }
                }
            } else {
                // Medium size
                HStack(spacing: 12) {
                    ForEach(entry.weekSchedule.prefix(4), id: \.day) { daySchedule in
                        VStack(spacing: 4) {
                            Text(daySchedule.day)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Circle()
                                .fill(daySchedule.shiftType.color)
                                .frame(width: 16, height: 16)
                                .overlay(
                                    Text(getShiftTypeText(daySchedule.shiftType))
                                        .font(.system(size: 7))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                        }
                    }
                }
            }
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
}

#Preview(as: .systemMedium) {
    ShiftCalendarWidget()
} timeline: {
    ShiftCalendarEntry(date: Date(), weekSchedule: [
        DaySchedule(day: "월", shiftType: .주간, date: Date()),
        DaySchedule(day: "화", shiftType: .야간, date: Date()),
        DaySchedule(day: "수", shiftType: .휴무, date: Date()),
        DaySchedule(day: "목", shiftType: .주간, date: Date()),
        DaySchedule(day: "금", shiftType: .야간, date: Date()),
        DaySchedule(day: "토", shiftType: .휴무, date: Date()),
        DaySchedule(day: "일", shiftType: .주간, date: Date())
    ])
}

#Preview(as: .systemLarge) {
    ShiftCalendarWidget()
} timeline: {
    ShiftCalendarEntry(date: Date(), weekSchedule: [
        DaySchedule(day: "월", shiftType: .주간, date: Date()),
        DaySchedule(day: "화", shiftType: .야간, date: Date()),
        DaySchedule(day: "수", shiftType: .휴무, date: Date()),
        DaySchedule(day: "목", shiftType: .주간, date: Date()),
        DaySchedule(day: "금", shiftType: .야간, date: Date()),
        DaySchedule(day: "토", shiftType: .휴무, date: Date()),
        DaySchedule(day: "일", shiftType: .주간, date: Date())
    ])
} 