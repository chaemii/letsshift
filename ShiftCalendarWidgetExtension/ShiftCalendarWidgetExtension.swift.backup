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
    typealias Entry = WeekScheduleEntry
    func placeholder(in context: Context) -> WeekScheduleEntry {
        WeekScheduleEntry(date: Date(), weekSchedule: generateSampleWeekSchedule())
    }

    func getSnapshot(in context: Context, completion: @escaping (WeekScheduleEntry) -> ()) {
        let entry = WeekScheduleEntry(date: Date(), weekSchedule: generateSampleWeekSchedule())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let calendar = Calendar.current
        
        // 여러 시간대의 엔트리 생성 (1분마다, 최대 10개)
        var entries: [WeekScheduleEntry] = []
        
        for i in 0..<10 {
            let entryDate = calendar.date(byAdding: .minute, value: i, to: currentDate) ?? currentDate
            let entry = WeekScheduleEntry(date: entryDate, weekSchedule: generateSampleWeekSchedule())
            entries.append(entry)
        }
        
        // 1분마다 업데이트
        let oneMinuteLater = calendar.date(byAdding: .minute, value: 1, to: currentDate)!
        
        let timeline = Timeline(entries: entries, policy: .after(oneMinuteLater))
        completion(timeline)
    }
    
    private func generateSampleWeekSchedule() -> [DaySchedule] {
        let calendar = Calendar.current
        let today = Date()
        
        // 정확한 주의 시작일 계산 (월요일부터 시작)
        let weekStart = getWeekStart(for: today)
        
        print("📅 Week Widget Debug - Today: \(today), Week Start: \(weekStart)")
        
        let weekDays = ["월", "화", "수", "목", "금", "토", "일"]
        
        return weekDays.enumerated().map { index, day in
            let date = calendar.date(byAdding: .day, value: index, to: weekStart) ?? today
            let isToday = calendar.isDate(date, inSameDayAs: today)
            
            print("📅 Week Widget Debug - Day \(index): \(day), Date: \(date), IsToday: \(isToday)")
            
            // 앱의 실제 데이터에서 근무 타입 가져오기
            let shiftInfo = getShiftInfoForDate(date)
            
            return DaySchedule(
                day: day, 
                shiftType: shiftInfo.shiftType, 
                date: date, 
                isToday: isToday,
                isVacation: shiftInfo.isVacation,
                isVolunteerWork: shiftInfo.isVolunteerWork
            )
        }
    }
    
    private func getWeekStart(for date: Date) -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        // Calendar.weekday는 1(일요일)부터 7(토요일)까지
        // 월요일을 1로 만들기 위해 조정
        let daysFromMonday = weekday == 1 ? 6 : weekday - 2
        
        return calendar.date(byAdding: .day, value: -daysFromMonday, to: date) ?? date
    }
    
    private func getShiftInfoForDate(_ date: Date) -> (shiftType: ShiftType, isVacation: Bool, isVolunteerWork: Bool) {
        // UserDefaults에서 앱의 스케줄 데이터 가져오기
        let userDefaults = UserDefaults(suiteName: "group.com.chaeeun.ShiftCalendarApp")!
        let schedulesKey = "shiftSchedules"
        
        // 디버그: UserDefaults 키 확인
        print("🔍 Week Widget Debug - Available keys: \(userDefaults.dictionaryRepresentation().keys.filter { $0.contains("shift") })")
        
        if let data = userDefaults.data(forKey: schedulesKey) {
            print("📅 Week Widget Debug - Found schedules data: \(data.count) bytes")
            if let schedules = try? JSONDecoder().decode([ShiftScheduleData].self, from: data) {
                print("✅ Week Widget Debug - Successfully decoded \(schedules.count) schedules")
                for (index, schedule) in schedules.enumerated() {
                    print("📅 Week Widget Debug - Schedule \(index): date=\(schedule.date), shiftType=\(schedule.shiftType.rawValue), isVacation=\(schedule.isVacation), isVolunteerWork=\(schedule.isVolunteerWork)")
                }
                
                // 해당 날짜의 스케줄 찾기
                if let schedule = schedules.first(where: { 
                    Calendar.current.isDate($0.date, inSameDayAs: date) 
                }) {
                    print("📅 Week Widget Debug - Found schedule for \(date): \(schedule.shiftType.rawValue), isVacation: \(schedule.isVacation), isVolunteerWork: \(schedule.isVolunteerWork)")
                    return (schedule.shiftType, schedule.isVacation, schedule.isVolunteerWork)
                } else {
                    print("📅 Week Widget Debug - No schedule found for \(date)")
                }
            } else {
                print("❌ Week Widget Debug - Failed to decode schedules")
            }
        } else {
            print("📅 Week Widget Debug - No schedules data found")
        }
        
        // 스케줄이 없는 경우 패턴에 따라 계산
        let calculated = calculateShiftFromPattern(for: date)
        print("📅 Week Widget Debug - Calculated shift for \(date): \(calculated.shiftType.rawValue)")
        return calculated
    }
    
    private func calculateShiftFromPattern(for date: Date) -> (shiftType: ShiftType, isVacation: Bool, isVolunteerWork: Bool) {
        let userDefaults = UserDefaults(suiteName: "group.com.chaeeun.ShiftCalendarApp")!
        let settingsKey = "shiftSettings"
        
        if let data = userDefaults.data(forKey: settingsKey) {
            print("⚙️ Week Widget Debug - Found settings data: \(data.count) bytes")
            if let settings = try? JSONDecoder().decode(ShiftSettingsData.self, from: data) {
                print("⚙️ Week Widget Debug - Pattern: \(settings.shiftPatternType), Team: \(settings.team)")
                print("⚙️ Week Widget Debug - Custom pattern exists: \(settings.customPattern != nil)")
                if let customPattern = settings.customPattern {
                    print("⚙️ Week Widget Debug - Custom pattern: \(customPattern.dayShifts.map { $0.rawValue })")
                }
                
                let patternType = settings.shiftPatternType.rawValue
                let team = settings.team
                
                let shiftType = calculateShiftFromPattern(patternType: patternType, date: date, team: team)
                print("⚙️ Week Widget Debug - Pattern: \(patternType), Team: \(team), Calculated: \(shiftType.rawValue)")
                return (shiftType, false, false)
            } else {
                print("❌ Week Widget Debug - Failed to decode settings")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📄 Week Widget Debug - Raw settings JSON: \(jsonString)")
                }
            }
        } else {
            print("⚙️ Week Widget Debug - No settings data found")
        }
        
        print("❌ Week Widget Debug - Returning default for \(date)")
        return (.휴무, false, false)
    }
    
    private func calculateShiftFromPattern(patternType: String, date: Date, team: String) -> ShiftType {
        let calendar = Calendar.current
        
        // 팀 번호 추출 (예: "1조" -> 1)
        let teamNumber = Int(team.replacingOccurrences(of: "조", with: "")) ?? 1
        
        switch patternType {
        case "twoShift":
            // 2교대: 주간/야간
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
            return (dayOfYear % 2 == 1) ? .주간 : .야간
            
        case "threeShift":
            // 3교대: 주간/오후/야간
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
            switch dayOfYear % 3 {
            case 1: return .주간
            case 2: return .오후
            default: return .야간
            }
            
        case "threeTeamTwoShift":
            // 3조 2교대: 당직-비번-휴무
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
            switch (dayOfYear + teamNumber - 1) % 3 {
            case 1: return .당직
            case 2: return .비번
            default: return .휴무
            }
            
        case "fourTeamTwoShift":
            // 4조 2교대: 주간-야간-비번-휴무
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
            switch (dayOfYear + teamNumber - 1) % 4 {
            case 1: return .주간
            case 2: return .야간
            case 3: return .비번
            default: return .휴무
            }
            
        case "fourTeamThreeShift":
            // 4조 3교대: 주간-오후-야간-휴무
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
            switch (dayOfYear + teamNumber - 1) % 4 {
            case 1: return .주간
            case 2: return .오후
            case 3: return .야간
            default: return .휴무
            }
            
        case "fiveTeamThreeShift":
            // 5조 3교대: 주간-오후-야간-비번-휴무
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
            switch (dayOfYear + teamNumber - 1) % 5 {
            case 1: return .주간
            case 2: return .오후
            case 3: return .야간
            case 4: return .비번
            default: return .휴무
            }
            
        case "custom":
            // 커스텀 패턴 처리
            return calculateCustomPatternShift(date: date, team: team)
            
        default:
            return .휴무
        }
    }
    
    private func calculateCustomPatternShift(date: Date, team: String) -> ShiftType {
        let userDefaults = UserDefaults(suiteName: "group.com.chaeeun.ShiftCalendarApp")!
        let settingsKey = "shiftSettings"
        
        guard let data = userDefaults.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(ShiftSettingsData.self, from: data),
              let customPattern = settings.customPattern else {
            print("❌ Week Widget Debug - Custom pattern not found")
            return .휴무
        }
        
        print("🔧 Week Widget Debug - Custom pattern found: \(customPattern.dayShifts)")
        print("🔧 Week Widget Debug - Custom pattern startDate: \(customPattern.startDate)")
        print("🔧 Week Widget Debug - Custom pattern cycleLength: \(customPattern.cycleLength)")
        
        let calendar = Calendar.current
        let startDate = customPattern.startDate
        let dayShifts = customPattern.dayShifts
        let cycleLength = customPattern.cycleLength
        
        // 시작일부터 해당 날짜까지의 일수 계산
        let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: date).day ?? 0
        
        // 패턴 인덱스 계산 (음수인 경우 0으로 처리)
        let patternIndex = max(0, daysSinceStart) % cycleLength
        
        // 안전한 인덱스 확인
        guard patternIndex < dayShifts.count else {
            print("❌ Week Widget Debug - Pattern index out of bounds: \(patternIndex) >= \(dayShifts.count)")
            return .휴무
        }
        
        let shiftType = dayShifts[patternIndex]
        
        print("🔧 Week Widget Debug - Custom pattern calculation: daysSinceStart=\(daysSinceStart), patternIndex=\(patternIndex), shiftType=\(shiftType.rawValue)")
        
        return shiftType
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
    let isVacation: Bool
    let isVolunteerWork: Bool
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
                
                Text(formatWeekRange())
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
                        
                        Group {
                            if schedule.isVacation {
                                // 휴가는 배경 없이 텍스트만
                                Text("휴가")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.pointColor)
                                    .frame(height: 22)
                            } else if schedule.isVolunteerWork {
                                // 자원근무는 배경 없이 텍스트만
                                Text("자원근무")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.pointColor)
                                    .frame(height: 22)
                            } else {
                                // 일반 근무는 배경과 함께
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
                        }
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
    
    private func formatWeekRange() -> String {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = getWeekStart(for: today)
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? today
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        
        let startString = formatter.string(from: weekStart)
        let endString = formatter.string(from: weekEnd)
        
        print("📅 Week Widget Debug - Week Range: \(startString) - \(endString)")
        
        return "\(startString) - \(endString)"
    }
    
    private func getWeekStart(for date: Date) -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        // Calendar.weekday는 1(일요일)부터 7(토요일)까지
        // 월요일을 1로 만들기 위해 조정
        let daysFromMonday = weekday == 1 ? 6 : weekday - 2
        
        return calendar.date(byAdding: .day, value: -daysFromMonday, to: date) ?? date
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
        DaySchedule(day: "월", shiftType: .주간, date: Date(), isToday: false, isVacation: false, isVolunteerWork: false),
        DaySchedule(day: "화", shiftType: .야간, date: Date(), isToday: false, isVacation: false, isVolunteerWork: false),
        DaySchedule(day: "수", shiftType: .휴무, date: Date(), isToday: false, isVacation: false, isVolunteerWork: false),
        DaySchedule(day: "목", shiftType: .주간, date: Date(), isToday: false, isVacation: false, isVolunteerWork: false),
        DaySchedule(day: "금", shiftType: .야간, date: Date(), isToday: false, isVacation: false, isVolunteerWork: false),
        DaySchedule(day: "토", shiftType: .휴무, date: Date(), isToday: false, isVacation: false, isVolunteerWork: false),
        DaySchedule(day: "일", shiftType: .주간, date: Date(), isToday: false, isVacation: false, isVolunteerWork: false)
    ])
}
