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
    typealias Entry = TodayShiftEntry
    func placeholder(in context: Context) -> TodayShiftEntry {
        TodayShiftEntry(date: Date(), todayShift: .주간, isToday: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayShiftEntry) -> ()) {
        let entry = TodayShiftEntry(date: Date(), todayShift: getTodayShift(), isToday: true)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let calendar = Calendar.current
        
        // 여러 시간대의 엔트리 생성 (1분마다, 최대 10개)
        var entries: [TodayShiftEntry] = []
        
        for i in 0..<10 {
            let entryDate = calendar.date(byAdding: .minute, value: i, to: currentDate) ?? currentDate
            let entry = TodayShiftEntry(date: entryDate, todayShift: getTodayShift(), isToday: true)
            entries.append(entry)
        }
        
        // 1분마다 업데이트
        let oneMinuteLater = calendar.date(byAdding: .minute, value: 1, to: currentDate)!
        
        let timeline = Timeline(entries: entries, policy: .after(oneMinuteLater))
        completion(timeline)
    }
    
    private func getTodayShift() -> ShiftType {
        // 앱의 실제 데이터에서 오늘 근무 가져오기
        let userDefaults = UserDefaults(suiteName: "group.com.chaeeun.ShiftCalendarApp")!
        let schedulesKey = "shiftSchedules"
        
        // 디버그: UserDefaults 키 확인
        print("🔍 Widget Debug - Available keys: \(userDefaults.dictionaryRepresentation().keys.filter { $0.contains("shift") })")
        
        if let data = userDefaults.data(forKey: schedulesKey) {
            print("📅 Widget Debug - Found schedules data: \(data.count) bytes")
            if let schedules = try? JSONDecoder().decode([ShiftScheduleData].self, from: data) {
                print("✅ Widget Debug - Successfully decoded \(schedules.count) schedules")
                for (index, schedule) in schedules.enumerated() {
                    print("📅 Widget Debug - Schedule \(index): date=\(schedule.date), shiftType=\(schedule.shiftType.rawValue), isVacation=\(schedule.isVacation), isVolunteerWork=\(schedule.isVolunteerWork)")
                }
                
                let today = Date()
                if let schedule = schedules.first(where: { 
                    Calendar.current.isDate($0.date, inSameDayAs: today) 
                }) {
                    print("📅 Widget Debug - Found today's schedule: \(schedule.shiftType.rawValue), isVacation: \(schedule.isVacation), isVolunteerWork: \(schedule.isVolunteerWork)")
                    
                    // 휴가인 경우
                    if schedule.isVacation {
                        return .휴무 // 휴가는 휴무로 표시
                    }
                    // 자원근무인 경우
                    if schedule.isVolunteerWork {
                        return .당직 // 자원근무는 당직으로 표시
                    }
                    return schedule.shiftType
                } else {
                    print("📅 Widget Debug - No schedule found for today")
                }
            } else {
                print("❌ Widget Debug - Failed to decode schedules")
            }
        } else {
            print("📅 Widget Debug - No schedules data found")
        }
        
        // 스케줄이 없는 경우, 앱의 패턴에 따라 오늘 근무 계산
        return calculateTodayShiftFromPattern()
    }
    
    private func calculateTodayShiftFromPattern() -> ShiftType {
        let userDefaults = UserDefaults(suiteName: "group.com.chaeeun.ShiftCalendarApp")!
        let settingsKey = "shiftSettings"
        
        if let data = userDefaults.data(forKey: settingsKey) {
            print("⚙️ Widget Debug - Found settings data: \(data.count) bytes")
            if let settings = try? JSONDecoder().decode(ShiftSettingsData.self, from: data) {
                print("⚙️ Widget Debug - Pattern: \(settings.shiftPatternType), Team: \(settings.team)")
                print("⚙️ Widget Debug - Custom pattern exists: \(settings.customPattern != nil)")
                if let customPattern = settings.customPattern {
                    print("⚙️ Widget Debug - Custom pattern: \(customPattern.dayShifts.map { $0.rawValue })")
                }
                
                // 현재 설정된 패턴에 따라 오늘 근무 계산
                let today = Date()
                let calendar = Calendar.current
                
                // 패턴 타입에 따른 근무 계산
                let patternType = settings.shiftPatternType.rawValue
                let team = settings.team
                let calculatedShift = calculateShiftFromPattern(patternType: patternType, date: today, team: team)
                print("⚙️ Widget Debug - Calculated shift: \(calculatedShift.rawValue)")
                return calculatedShift
            } else {
                print("❌ Widget Debug - Failed to decode settings")
            }
        } else {
            print("⚙️ Widget Debug - No settings data found")
        }
        
        print("❌ Widget Debug - Returning default: 휴무")
        return .휴무
    }
    
    private func calculateShiftFromPattern(patternType: String, date: Date, team: String) -> ShiftType {
        let calendar = Calendar.current
        let today = Date()
        
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
            print("❌ Widget Debug - Custom pattern not found")
            return .휴무
        }
        
        print("🔧 Widget Debug - Custom pattern found: \(customPattern.dayShifts)")
        
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
            print("❌ Widget Debug - Pattern index out of bounds: \(patternIndex) >= \(dayShifts.count)")
            return .휴무
        }
        
        let shiftType = dayShifts[patternIndex]
        
        print("🔧 Widget Debug - Custom pattern calculation: daysSinceStart=\(daysSinceStart), patternIndex=\(patternIndex), shiftType=\(shiftType.rawValue)")
        
        return shiftType
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
            Group {
                if entry.todayShift == .휴무 && getIsVacation() {
                    // 휴가인 경우
                    VStack(spacing: 4) {
                        Circle()
                            .fill(Color.pointColor.opacity(0.2))
                            .frame(width: 70, height: 70)
                            .overlay(
                                Text("휴가")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.pointColor)
                            )
                    }
                } else if entry.todayShift == .당직 && getIsVolunteerWork() {
                    // 자원근무인 경우
                    VStack(spacing: 4) {
                        Circle()
                            .fill(Color.pointColor.opacity(0.2))
                            .frame(width: 70, height: 70)
                            .overlay(
                                Text("자원근무")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.pointColor)
                            )
                    }
                } else {
                    // 일반 근무인 경우
                    Circle()
                        .fill(entry.todayShift.color)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Text(entry.todayShift.rawValue)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .onAppear {
            // 디버그: 위젯이 로드될 때 콘솔에 정보 출력
            print("Widget loaded - Today's shift: \(entry.todayShift.rawValue)")
        }
    }
    
    private func getIsVacation() -> Bool {
        let userDefaults = UserDefaults(suiteName: "group.com.chaeeun.ShiftCalendarApp")!
        let schedulesKey = "shiftSchedules"
        
        if let data = userDefaults.data(forKey: schedulesKey),
           let schedules = try? JSONDecoder().decode([ShiftScheduleData].self, from: data) {
            
            let today = Date()
            if let schedule = schedules.first(where: { 
                Calendar.current.isDate($0.date, inSameDayAs: today) 
            }) {
                return schedule.isVacation
            }
        }
        return false
    }
    
    private func getIsVolunteerWork() -> Bool {
        let userDefaults = UserDefaults(suiteName: "group.com.chaeeun.ShiftCalendarApp")!
        let schedulesKey = "shiftSchedules"
        
        if let data = userDefaults.data(forKey: schedulesKey),
           let schedules = try? JSONDecoder().decode([ShiftScheduleData].self, from: data) {
            
            let today = Date()
            if let schedule = schedules.first(where: { 
                Calendar.current.isDate($0.date, inSameDayAs: today) 
            }) {
                return schedule.isVolunteerWork
            }
        }
        return false
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