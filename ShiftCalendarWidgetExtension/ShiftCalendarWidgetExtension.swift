//
//  ShiftCalendarWidgetExtension.swift
//  ShiftCalendarWidgetExtension
//
//  Created by cham on 7/24/25.
//

import WidgetKit
import SwiftUI

// MARK: - 일주일 스케줄 위젯
struct WeekScheduleProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeekScheduleEntry {
        WeekScheduleEntry(date: Date(), weekSchedule: generateSampleWeekSchedule())
    }

    func getSnapshot(in context: Context, completion: @escaping (WeekScheduleEntry) -> ()) {
        let entry = WeekScheduleEntry(date: Date(), weekSchedule: generateSampleWeekSchedule())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let entry = WeekScheduleEntry(date: currentDate, weekSchedule: generateSampleWeekSchedule())
        
        // 1시간마다 업데이트
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func generateSampleWeekSchedule() -> [DaySchedule] {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        let weekDays = ["월", "화", "수", "목", "금", "토", "일"]
        
        return weekDays.enumerated().map { index, day in
            let date = calendar.date(byAdding: .day, value: index, to: weekStart) ?? today
            let isToday = calendar.isDate(date, inSameDayAs: today)
            
            // 앱의 실제 데이터에서 근무 타입 가져오기
            let shiftType = getShiftTypeForDate(date)
            
            return DaySchedule(day: day, shiftType: shiftType, date: date, isToday: isToday)
        }
    }
    
    private func getShiftTypeForDate(_ date: Date) -> ShiftType {
        // UserDefaults에서 앱의 스케줄 데이터 가져오기
        let userDefaults = UserDefaults.standard
        let schedulesKey = "shiftSchedules"
        
        if let data = userDefaults.data(forKey: schedulesKey),
           let schedules = try? JSONDecoder().decode([ShiftScheduleData].self, from: data) {
            
            // 해당 날짜의 스케줄 찾기
            if let schedule = schedules.first(where: { 
                Calendar.current.isDate($0.date, inSameDayAs: date) 
            }) {
                return schedule.shiftType
            }
        }
        
        // 기본값 반환
        return .휴무
    }
}

struct WeekScheduleEntry: TimelineEntry {
    let date: Date
    let weekSchedule: [DaySchedule]
}

struct DaySchedule {
    let day: String
    let shiftType: ShiftType
    let date: Date
    let isToday: Bool
}







struct WeekScheduleWidgetEntryView: View {
    var entry: WeekScheduleProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("일주일 스케줄")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("7월 24일")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                ForEach(entry.weekSchedule, id: \.day) { schedule in
                    VStack(spacing: 2) {
                        Text(schedule.day)
                            .font(.caption)
                            .foregroundColor(schedule.isToday ? .primary : .secondary)
                            .fontWeight(schedule.isToday ? .bold : .regular)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(schedule.shiftType.color)
                            .frame(height: 22)
                            .overlay(
                                Text(schedule.shiftType.rawValue)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                            )
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(schedule.isToday ? Color(hex: "C7D6DB") : Color.clear)
                    )
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
}

struct WeekScheduleWidget: Widget {
    let kind: String = "WeekScheduleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeekScheduleProvider()) { entry in
            if #available(iOS 17.0, *) {
                WeekScheduleWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WeekScheduleWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("일주일 스케줄")
        .description("일주일치 근무 스케줄을 확인하세요.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

#Preview(as: .systemMedium) {
    WeekScheduleWidget()
} timeline: {
    WeekScheduleEntry(date: .now, weekSchedule: [
        DaySchedule(day: "월", shiftType: .주간, date: Date(), isToday: false),
        DaySchedule(day: "화", shiftType: .야간, date: Date(), isToday: false),
        DaySchedule(day: "수", shiftType: .휴무, date: Date(), isToday: false),
        DaySchedule(day: "목", shiftType: .주간, date: Date(), isToday: false),
        DaySchedule(day: "금", shiftType: .야간, date: Date(), isToday: false),
        DaySchedule(day: "토", shiftType: .휴무, date: Date(), isToday: false),
        DaySchedule(day: "일", shiftType: .주간, date: Date(), isToday: false)
    ])
}
