//
//  TodayShiftWidget.swift
//  ShiftCalendarWidgetExtension
//
//  Created by cham on 7/24/25.
//

import WidgetKit
import SwiftUI

// MARK: - 오늘 스케줄 위젯
struct TodayShiftProvider: TimelineProvider {
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
        
        // 1시간마다 업데이트
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func getTodayShift() -> ShiftType {
        // 앱의 실제 데이터에서 오늘 근무 가져오기
        let userDefaults = UserDefaults.standard
        let schedulesKey = "shiftSchedules"
        
        if let data = userDefaults.data(forKey: schedulesKey),
           let schedules = try? JSONDecoder().decode([ShiftScheduleData].self, from: data) {
            
            let today = Date()
            if let schedule = schedules.first(where: { 
                Calendar.current.isDate($0.date, inSameDayAs: today) 
            }) {
                return schedule.shiftType
            }
        }
        
        // 기본값 반환
        return .휴무
    }
}

struct TodayShiftEntry: TimelineEntry {
    let date: Date
    let todayShift: ShiftType
    let isToday: Bool
}



struct TodayShiftWidgetEntryView: View {
    var entry: TodayShiftProvider.Entry

    var body: some View {
        VStack(spacing: 6) {
            // 상단에 작은 그레이 글씨로 '오늘의 근무' 표시
            Text("오늘의 근무")
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 날짜와 요일 표시
            HStack {
                Text(formatDate(entry.date))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(formatWeekday(entry.date))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 근무 요소 컴포넌트
            Circle()
                .fill(entry.todayShift.color)
                .frame(width: 70, height: 70)
                .overlay(
                    Text(entry.todayShift.rawValue)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    private func formatWeekday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

struct TodayShiftWidget: Widget {
    let kind: String = "TodayShiftWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayShiftProvider()) { entry in
            if #available(iOS 17.0, *) {
                TodayShiftWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                TodayShiftWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("오늘 스케줄")
        .description("오늘의 근무 스케줄을 확인하세요.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    TodayShiftWidget()
} timeline: {
    TodayShiftEntry(date: .now, todayShift: .주간, isToday: true)
} 