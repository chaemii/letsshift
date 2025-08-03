import WidgetKit
import SwiftUI

// 위젯에서 사용할 커스텀 컬러 확장
extension Color {
    static let dayShift = Color(red: 0.47, green: 0.73, blue: 0.98)
    static let nightShift = Color(red: 0.49, green: 0.52, blue: 0.98)
    static let deepNightShift = Color(red: 0.63, green: 0.70, blue: 0.71)
    static let offDuty = Color(red: 0.96, green: 0.50, blue: 0.30)
    static let standby = Color(red: 0.57, green: 0.89, blue: 0.66)
    static let afternoon = Color(red: 0.80, green: 0.71, blue: 0.92)
    static let duty = Color(red: 1.00, green: 0.36, blue: 0.45)
}

// 일주일 스케줄 데이터 구조
struct WeekScheduleData: Codable {
    let weekData: [DayScheduleData]
    let team: String
    let patternType: String
    let shiftOffset: Int
}

struct DayScheduleData: Codable {
    let day: String
    let shiftType: String
    let date: String
}

struct WeekScheduleEntry: TimelineEntry {
    let date: Date
    let weekData: [DayScheduleData]
    let team: String
    let patternType: String
    let shiftOffset: Int
}

struct WeekScheduleProvider: TimelineProvider {
    typealias Entry = WeekScheduleEntry
    
    func placeholder(in context: Context) -> WeekScheduleEntry {
        let sampleData = [
            DayScheduleData(day: WidgetLocalizer.localizedString("weekday_mon_short"), shiftType: WidgetLocalizer.localizedString("DAY"), date: "7/28"),
            DayScheduleData(day: WidgetLocalizer.localizedString("weekday_tue_short"), shiftType: WidgetLocalizer.localizedString("EVE"), date: "7/29"),
            DayScheduleData(day: WidgetLocalizer.localizedString("weekday_wed_short"), shiftType: WidgetLocalizer.localizedString("OFF"), date: "7/30"),
            DayScheduleData(day: WidgetLocalizer.localizedString("weekday_thu_short"), shiftType: WidgetLocalizer.localizedString("RST"), date: "7/31"),
            DayScheduleData(day: WidgetLocalizer.localizedString("weekday_fri_short"), shiftType: WidgetLocalizer.localizedString("DAY"), date: "8/1"),
            DayScheduleData(day: WidgetLocalizer.localizedString("weekday_sat_short"), shiftType: WidgetLocalizer.localizedString("EVE"), date: "8/2"),
            DayScheduleData(day: WidgetLocalizer.localizedString("weekday_sun_short"), shiftType: WidgetLocalizer.localizedString("OFF"), date: "8/3")
        ]
        return WeekScheduleEntry(date: Date(), weekData: sampleData, team: String(format: WidgetLocalizer.localizedString("team_format"), 1), patternType: WidgetLocalizer.localizedString("pattern_three_shift"), shiftOffset: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (WeekScheduleEntry) -> ()) {
        let entry = getWeekScheduleEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [WeekScheduleEntry] = []
        let currentDate = Date()

        // 현재 시간 기준 엔트리 추가
        let initialEntry = getWeekScheduleEntry()
        entries.append(initialEntry)

        // 다음 24시간 동안 1시간 간격으로 엔트리 추가
        for hourOffset in 1..<24 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = getWeekScheduleEntry(for: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func getWeekScheduleEntry(for date: Date = Date()) -> WeekScheduleEntry {
        print("🔵 === Week Widget getWeekScheduleEntry START ===")
        print("🔵 Current time: \(Date())")
        let userDefaults = UserDefaults(suiteName: "group.com.chaeeun.gyodaehaja")!
        userDefaults.synchronize()
        
        print("🔵 UserDefaults synchronized")
        print("🔵 Checking for weekScheduleData key...")

        if let data = userDefaults.data(forKey: "weekScheduleData") {
            print("🔵 Found weekScheduleData: \(data.count) bytes")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 Week Widget Debug - Read JSON: \(jsonString)")
            }
            if let weekData = try? JSONDecoder().decode(WeekScheduleData.self, from: data) {
                print("✅ Week Widget Debug - Successfully decoded WeekScheduleData: \(weekData.weekData.count) days, \(weekData.team), \(weekData.patternType), offset: \(weekData.shiftOffset)")
                for (index, dayData) in weekData.weekData.enumerated() {
                    print("📅 Day \(index): \(dayData.day) - \(dayData.shiftType) (\(dayData.date))")
                }
                print("🔵 === Week Widget getWeekScheduleEntry END ===")
                return WeekScheduleEntry(date: date, weekData: weekData.weekData, team: weekData.team, patternType: weekData.patternType, shiftOffset: weekData.shiftOffset)
            } else {
                print("❌ Week Widget Debug - Failed to decode WeekScheduleData")
                print("❌ JSON decode error occurred")
            }
        } else {
            print("📅 Week Widget Debug - No weekScheduleData found")
            print("📅 Available keys in UserDefaults:")
            for key in userDefaults.dictionaryRepresentation().keys {
                if key.contains("week") || key.contains("shift") || key.contains("schedule") {
                    print("📅 Found key: \(key)")
                }
            }
        }
        
        // 폴백 데이터
        let fallbackData = [
            DayScheduleData(day: WidgetLocalizer.localizedString("weekday_mon_short"), shiftType: WidgetLocalizer.localizedString("no_info"), date: "7/28"),
            DayScheduleData(day: WidgetLocalizer.localizedString("weekday_tue_short"), shiftType: WidgetLocalizer.localizedString("no_info"), date: "7/29"),
            DayScheduleData(day: WidgetLocalizer.localizedString("weekday_wed_short"), shiftType: WidgetLocalizer.localizedString("no_info"), date: "7/30"),
            DayScheduleData(day: WidgetLocalizer.localizedString("weekday_thu_short"), shiftType: WidgetLocalizer.localizedString("no_info"), date: "7/31"),
            DayScheduleData(day: WidgetLocalizer.localizedString("weekday_fri_short"), shiftType: WidgetLocalizer.localizedString("no_info"), date: "8/1"),
            DayScheduleData(day: WidgetLocalizer.localizedString("weekday_sat_short"), shiftType: WidgetLocalizer.localizedString("no_info"), date: "8/2"),
            DayScheduleData(day: WidgetLocalizer.localizedString("weekday_sun_short"), shiftType: WidgetLocalizer.localizedString("no_info"), date: "8/3")
        ]
        print("🔵 === Week Widget getWeekScheduleEntry END (fallback) ===")
        return WeekScheduleEntry(date: date, weekData: fallbackData, team: WidgetLocalizer.localizedString("no_info"), patternType: WidgetLocalizer.localizedString("no_info"), shiftOffset: 0)
    }
}

struct WeekScheduleWidgetEntryView: View {
    var entry: WeekScheduleProvider.Entry
    @State private var isRefreshing = false
    
    var body: some View {
                            VStack(spacing: 10) {
                                    // 헤더: 제목과 팀 정보
                        HStack {
                            Text(WidgetLocalizer.localizedString("week_schedule_title"))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(entry.team)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
            
            // 일주일 스케줄 그리드
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 4) {
                ForEach(entry.weekData, id: \.day) { dayData in
                    let isToday = isToday(dayData.day)
                    
                    VStack(spacing: 3) {
                        // 요일
                        Text(dayData.day)
                            .font(.system(size: 12, weight: isToday ? .bold : .medium))
                            .foregroundColor(isToday ? Color(hex: "000000") : .secondary)
                        
                        // 근무 타입 (작은 원)
                        ZStack {
                            Circle()
                                .fill(getShiftColor(dayData.shiftType))
                                .frame(width: 29, height: 29)
                            
                            Text(dayData.shiftType.localizedShiftName)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        
                        // 날짜
                        Text(dayData.date)
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isToday ? Color.gray.opacity(0.2) : Color.clear)
                    )
                }
            }
            
                                    // 패턴 정보 (하단)
                        Text("\(WidgetLocalizer.localizedString("pattern_label")) \(entry.patternType)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
            
            if isRefreshing {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(0.6)
            }
        }
        .padding()
        .onTapGesture {
            // 위젯 탭 시 새로고침
            print("🔄 Week Widget tapped - starting refresh")
            isRefreshing = true

            // UserDefaults 동기화
            let userDefaults = UserDefaults(suiteName: "group.com.chaeeun.gyodaehaja")!
            userDefaults.synchronize()
            UserDefaults.standard.synchronize()

            // 위젯 타임라인 새로고침
            WidgetCenter.shared.reloadAllTimelines()
            print("✅ Week Widget timeline reloaded from widget tap")

            // 1초 후 새로고침 상태 해제
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isRefreshing = false
                print("🔄 Week Widget refresh animation completed")
            }
        }
    }
    
    private func getShiftColor(_ shiftType: String) -> Color {
        switch shiftType {
        case "주간": return .dayShift
        case "야간": return .nightShift
        case "심야": return .deepNightShift
        case "비번": return .standby
        case "휴무": return .offDuty
        case "오후": return .afternoon
        case "당직": return .duty
        default: return .gray
        }
    }
    
    private func isToday(_ dayString: String) -> Bool {
        let today = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "E"
        let todayDay = formatter.string(from: today)
        
        // 요일 매핑 (현재 요일 -> 위젯 표시 요일)
        let dayMapping = [
            WidgetLocalizer.localizedString("weekday_mon_short"): WidgetLocalizer.localizedString("weekday_mon_short"),
            WidgetLocalizer.localizedString("weekday_tue_short"): WidgetLocalizer.localizedString("weekday_tue_short"), 
            WidgetLocalizer.localizedString("weekday_wed_short"): WidgetLocalizer.localizedString("weekday_wed_short"),
            WidgetLocalizer.localizedString("weekday_thu_short"): WidgetLocalizer.localizedString("weekday_thu_short"),
            WidgetLocalizer.localizedString("weekday_fri_short"): WidgetLocalizer.localizedString("weekday_fri_short"),
            WidgetLocalizer.localizedString("weekday_sat_short"): WidgetLocalizer.localizedString("weekday_sat_short"),
            WidgetLocalizer.localizedString("weekday_sun_short"): WidgetLocalizer.localizedString("weekday_sun_short")
        ]
        
        return dayMapping[todayDay] == dayString
    }
}

struct WeekScheduleWidget: Widget {
    let kind: String = "WeekScheduleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeekScheduleProvider()) { entry in
            WeekScheduleWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(WidgetLocalizer.localizedString("this_week"))
        .description(WidgetLocalizer.localizedString("today_schedule_description"))
        .supportedFamilies([.systemMedium, .systemLarge])
    }
} 