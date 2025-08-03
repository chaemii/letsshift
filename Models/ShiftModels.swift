import Foundation
import SwiftUI
import WidgetKit

// 간단한 위젯 데이터 구조
struct SimpleShiftData: Codable {
    let shiftType: String
    let team: String
    let patternType: String
    let shiftOffset: Int
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

// MARK: - Color Extensions
extension Color {
    static let charcoalBlack = Color(hex: "1A1A1A")
    static let mainColor = Color(hex: "D5E7EB")        // 배경용 (카드, 호버 등)
    static let mainColorButton = Color(hex: "C3DDE5")  // 버튼, 텍스트용
    static let mainColorDark = Color(hex: "A0B2B6")
    static let pointColor = Color(hex: "FF5D73")
    static let subColor1 = Color(hex: "CDB5EB")        // 개선된 서브컬러1
    static let subColor2 = Color(hex: "C7E89C")        // 개선된 서브컬러2
    static let backgroundLight = Color(hex: "EFF0F2")
    static let backgroundWhite = Color(hex: "FFFFFF")
    
    // Shift type colors
    static let nightShift = Color(hex: "7E85F9")    // 야간 - 라벤더 블루
    static let deepNightShift = Color(hex: "A0B2B6") // 메인컬러 다크
    static let dayShift = Color(hex: "77BBFB")      // 주간 - 밝은 하늘색
    static let offDuty = Color(hex: "F47F4C")       // 휴무 - 따뜻한 오렌지
    static let standby = Color(hex: "92E3A9")       // 비번 - 민트 그린
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        let hex = String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        return hex
    }
}

// MARK: - Shift Models
enum ShiftType: String, CaseIterable, Codable, Identifiable {
    case 주간 = "주간"
    case 야간 = "야간"
    case 심야 = "심야"
    case 오후 = "오후"
    case 당직 = "당직"
    case 비번 = "비번"
    case 휴무 = "휴무"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .주간: return NSLocalizedString("shift_day", comment: "Day shift")
        case .오후: return NSLocalizedString("shift_afternoon", comment: "Afternoon shift")
        case .야간: return NSLocalizedString("shift_evening", comment: "Evening shift")
        case .심야: return NSLocalizedString("shift_night", comment: "Night shift")
        case .당직: return NSLocalizedString("shift_duty", comment: "Duty shift")
        case .비번: return NSLocalizedString("shift_off", comment: "Off shift")
        case .휴무: return NSLocalizedString("shift_rest", comment: "Rest shift")
        }
    }
    
    var color: Color {
        let defaultColor: Color
        switch self {
        case .야간: defaultColor = .nightShift
        case .심야: defaultColor = .deepNightShift
        case .주간: defaultColor = .dayShift
        case .오후: defaultColor = .subColor1
        case .당직: defaultColor = .pointColor
        case .휴무: defaultColor = .offDuty
        case .비번: defaultColor = .standby
        }
        return defaultColor // Placeholder, actual color from ShiftManager
    }
    
    var workingHours: Int {
        switch self {
        case .주간: return 8
        case .야간: return 8
        case .심야: return 8
        case .오후: return 8
        case .당직: return 24
        case .비번: return 0
        case .휴무: return 0
        }
    }
    
    var timeRange: String {
        switch self {
        case .주간: return "07:00-15:00"
        case .오후: return "15:00-23:00"
        case .야간: return "19:00-07:00"
        case .심야: return "23:00-07:00"
        case .당직: return NSLocalizedString("time_24_hours", comment: "24 hours")
        case .비번: return NSLocalizedString("time_standby", comment: "Standby")
        case .휴무: return NSLocalizedString("time_off", comment: "Off")
        }
    }
    
    var defaultShiftTime: ShiftTime {
        switch self {
        case .주간: return ShiftTime(startHour: 7, startMinute: 0, endHour: 15, endMinute: 0)
        case .오후: return ShiftTime(startHour: 15, startMinute: 0, endHour: 23, endMinute: 0)
        case .야간: return ShiftTime(startHour: 19, startMinute: 0, endHour: 7, endMinute: 0)
        case .심야: return ShiftTime(startHour: 23, startMinute: 0, endHour: 7, endMinute: 0)
        case .당직: return ShiftTime(startHour: 0, startMinute: 0, endHour: 24, endMinute: 0)
        case .비번: return ShiftTime(startHour: 0, startMinute: 0, endHour: 0, endMinute: 0)
        case .휴무: return ShiftTime(startHour: 0, startMinute: 0, endHour: 0, endMinute: 0)
        }
    }
}

// MARK: - Shift Time Structure
struct ShiftTime: Codable {
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    
    init(startHour: Int, startMinute: Int, endHour: Int, endMinute: Int) {
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
    }
    
    var startTimeString: String {
        return String(format: "%02d:%02d", startHour, startMinute)
    }
    
    var endTimeString: String {
        return String(format: "%02d:%02d", endHour, endMinute)
    }
    
    var timeRangeString: String {
        return "\(startTimeString)-\(endTimeString)"
    }
    
    var workingHours: Double {
        var hours = Double(endHour - startHour) + Double(endMinute - startMinute) / 60.0
        
        // 야간 근무의 경우 다음날로 넘어가는 경우 처리
        if endHour < startHour {
            hours += 24.0
        }
        
        return max(0, hours)
    }
}

// MARK: - Custom Shift Type
struct CustomShiftType: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var color: String // hex color string
    var workingHours: ShiftTime
    
    init(name: String, color: String = "77BBFB", workingHours: ShiftTime? = nil) {
        self.name = name
        self.color = color
        self.workingHours = workingHours ?? ShiftTime(startHour: 9, startMinute: 0, endHour: 18, endMinute: 0)
    }
    
    var displayColor: Color {
        return Color(hex: color)
    }
    
    static func == (lhs: CustomShiftType, rhs: CustomShiftType) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Custom Shift Pattern
struct CustomShiftPattern: Codable, Identifiable {
    var id = UUID()
    var name: String
    var dayShifts: [ShiftType] // 각 일차별 근무 요소 (1일차, 2일차, 3일차...)
    var customDayShifts: [CustomShiftType] // 커스텀 근무 요소들
    var cycleLength: Int // 패턴이 반복되는 주기 (일 단위)
    var startDate: Date // 패턴이 시작되는 날짜
    var description: String
    
    // 기존 호환성을 위한 computed property
    var shifts: [ShiftType] {
        return dayShifts
    }
    
    init(name: String, dayShifts: [ShiftType], cycleLength: Int, startDate: Date, description: String = "") {
        self.name = name
        
        // dayShifts 검증 및 안전장치
        if dayShifts.isEmpty {
            print("Warning: dayShifts is empty, using default pattern")
            self.dayShifts = [.주간, .야간, .휴무]
        } else {
            self.dayShifts = dayShifts
        }
        
        self.customDayShifts = []
        
        // cycleLength 검증
        if cycleLength <= 0 {
            print("Warning: cycleLength is invalid, using dayShifts count")
            self.cycleLength = self.dayShifts.count
        } else {
            self.cycleLength = cycleLength
        }
        
        self.startDate = startDate
        self.description = description.isEmpty ? "\(self.dayShifts.count)일 주기" : description
        
        print("CustomShiftPattern initialized: \(self.dayShifts.count) shifts, \(self.cycleLength) cycle length")
    }
    
    // 기존 호환성을 위한 initializer
    init(name: String, shifts: [ShiftType], cycleLength: Int, description: String = "") {
        self.name = name
        self.dayShifts = shifts
        self.customDayShifts = []
        self.cycleLength = cycleLength
        self.startDate = Date() // 기본값으로 오늘 날짜
        self.description = description.isEmpty ? "\(shifts.count)일 주기" : description
    }
    
    // 새로운 간단한 initializer
    init(cycleLength: Int, startDate: Date, dayShifts: [ShiftType]) {
        self.name = "커스텀 패턴"
        self.cycleLength = max(2, min(15, cycleLength)) // 2-15일 제한
        self.startDate = startDate
        self.dayShifts = dayShifts.isEmpty ? [.주간, .야간, .휴무] : dayShifts
        self.customDayShifts = []
        self.description = "\(self.dayShifts.count)일 주기"
    }
    
    // 커스텀 근무 요소를 지원하는 새로운 initializer
    init(cycleLength: Int, startDate: Date, dayShifts: [ShiftType], customDayShifts: [CustomShiftType]) {
        self.name = "커스텀 패턴"
        self.cycleLength = max(2, min(15, cycleLength)) // 2-15일 제한
        self.startDate = startDate
        self.dayShifts = dayShifts
        self.customDayShifts = customDayShifts
        self.description = "\(dayShifts.count + customDayShifts.count)일 주기"
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "name": name,
            "dayShifts": dayShifts.map { $0.rawValue },
            "customDayShifts": customDayShifts.map { [
                "id": $0.id.uuidString,
                "name": $0.name,
                "color": $0.color,
                "workingHours": [
                    "startHour": $0.workingHours.startHour,
                    "startMinute": $0.workingHours.startMinute,
                    "endHour": $0.workingHours.endHour,
                    "endMinute": $0.workingHours.endMinute
                ]
            ] },
            "cycleLength": cycleLength,
            "startDate": startDate.timeIntervalSince1970,
            "description": description
        ]
    }
}

// MARK: - Shift Pattern Types
enum ShiftPatternType: String, CaseIterable, Codable {
    case none = "none"
    case twoShift = "2교대"
    case threeShift = "3교대"
    case threeTeamTwoShift = "3조 2교대"
    case fourTeamTwoShift = "4조 2교대"
    case fourTeamThreeShift = "4조 3교대"
    case fiveTeamThreeShift = "5조 3교대"
    case irregular = "비주기적"
    case custom = "나만의 패턴"
    
    var displayName: String {
        switch self {
        case .none: return NSLocalizedString("pattern_none", comment: "Please select pattern")
        case .twoShift: return NSLocalizedString("pattern_two_shift", comment: "2 shift")
        case .threeShift: return NSLocalizedString("pattern_three_shift", comment: "3 shift")
        case .threeTeamTwoShift: return NSLocalizedString("pattern_three_team_two_shift", comment: "3 team 2 shift")
        case .fourTeamTwoShift: return NSLocalizedString("pattern_four_team_two_shift", comment: "4 team 2 shift")
        case .fourTeamThreeShift: return NSLocalizedString("pattern_four_team_three_shift", comment: "4 team 3 shift")
        case .fiveTeamThreeShift: return NSLocalizedString("pattern_five_team_three_shift", comment: "5 team 3 shift")
        case .irregular: return NSLocalizedString("pattern_irregular", comment: "Irregular")
        case .custom: return NSLocalizedString("pattern_custom", comment: "Custom pattern")
        }
    }
    
    var description: String {
        switch self {
        case .none: return ""
        case .twoShift: return "주간-야간 반복"
        case .threeShift: return "주간-야간-비번 반복"
        case .threeTeamTwoShift: return "주간-야간-휴무"
        case .fourTeamTwoShift: return "주간-야간-비번-휴무"
        case .fourTeamThreeShift: return "주간-오후-야간-휴무"
        case .fiveTeamThreeShift: return "주간-야간-심야-비번-휴무"
        case .irregular: return "월마다 비주기적 배치"
        case .custom: return "직접 만드는 근무 패턴"
        }
    }
    
    func generatePattern() -> [ShiftType] {
        switch self {
        case .none:
            return []
        case .twoShift:
            return [.주간, .야간]
        case .threeShift:
            return [.주간, .야간, .비번]
        case .threeTeamTwoShift:
            return [.주간, .야간, .휴무]
        case .fourTeamTwoShift:
            return [.주간, .야간, .비번, .휴무]
        case .fourTeamThreeShift:
            return [.주간, .오후, .야간, .휴무]
        case .fiveTeamThreeShift:
            return [.주간, .야간, .심야, .비번, .휴무]
        case .irregular:
            return [.주간, .오후, .야간, .심야, .비번, .휴무]
        case .custom:
            return [] // 커스텀 패턴은 ShiftManager에서 처리
        }
    }
}

enum VacationType: String, CaseIterable, Codable {
    case 연차 = "연차"
    case 특별휴가 = "특별 휴가"
}

struct ShiftSchedule: Codable, Identifiable {
    var id = UUID()
    let date: Date
    var shiftType: ShiftType
    var overtimeHours: Int
    var isVacation: Bool = false
    var vacationType: VacationType? = nil
    var isVolunteerWork: Bool = false
    
    init(date: Date, shiftType: ShiftType, overtimeHours: Int = 0, isVacation: Bool = false, vacationType: VacationType? = nil, isVolunteerWork: Bool = false) {
        self.date = date
        self.shiftType = shiftType
        self.overtimeHours = overtimeHours
        self.isVacation = isVacation
        self.vacationType = vacationType
        self.isVolunteerWork = isVolunteerWork
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "date": date.timeIntervalSince1970,
            "shiftType": shiftType.rawValue,
            "overtimeHours": overtimeHours,
            "isVacation": isVacation,
            "vacationType": vacationType?.rawValue as Any,
            "isVolunteerWork": isVolunteerWork
        ]
    }
}

struct ShiftSettings: Codable {
    var team: String = "1조"
    var shiftPatternType: ShiftPatternType = .fiveTeamThreeShift
    var colors: [String: String] = [:]
    var shiftNames: [String: String] = [:]
    
    // 커스텀 패턴 추가
    var customPattern: CustomShiftPattern?
    
    // 급여 정보 추가
    var baseSalary: Double = 0.0        // 기본급 (월급)
    var nightShiftRate: Double = 1.5    // 야간 근무 수당 배율 (기본 1.5배)
    var deepNightShiftRate: Double = 2.0 // 심야 근무 수당 배율 (기본 2.0배)
    var overtimeRate: Double = 1.5      // 초과근무 배율 (기본 1.5배)
    var holidayWorkRate: Double = 1.5   // 휴일 근무 수당 배율 (기본 1.5배)
    
    // 휴가 정보 추가
    var annualVacationDays: Int = 15  // 연간 휴가 일수
    
    // 근무 시간 설정 추가
    var shiftTimes: [String: ShiftTime] = [:]
    
    // 커스텀 근무 요소 추가
    var customShiftTypes: [CustomShiftType] = []
}

// MARK: - Calendar Extensions
extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
    
    func endOfMonth(for date: Date) -> Date {
        let startOfNextMonth = self.date(byAdding: .month, value: 1, to: startOfMonth(for: date)) ?? date
        return self.date(byAdding: .day, value: -1, to: startOfNextMonth) ?? date
    }
}

// MARK: - Shift Manager
class ShiftManager: ObservableObject {
    static let shared = ShiftManager()
    
    @Published var schedules: [ShiftSchedule] = []
    @Published var settings = ShiftSettings()
    @Published var shiftOffset: Int = 0 // 하루 밀기/당기기 오프셋
    
    private let userDefaults = UserDefaults(suiteName: "group.com.chaeeun.gyodaehaja")!
    private let schedulesKey = "shiftSchedules"
    private let settingsKey = "shiftSettings"
    private let shiftOffsetKey = "shiftOffset"
    
    init() {
        loadData()
        if schedules.isEmpty {
            generateDefaultSchedule()
        }
    }
    
    // 안전한 패턴 가져오기
    private func getSafeShiftPattern() -> ([ShiftType], Date) {
        if settings.shiftPatternType == .custom, let customPattern = settings.customPattern {
            print("=== getSafeShiftPattern: Custom Pattern ===")
            print("Custom Pattern Name: \(customPattern.name)")
            print("Custom Pattern Start Date: \(customPattern.startDate)")
            print("Custom Pattern Day Shifts: \(customPattern.dayShifts)")
            print("Custom Pattern Cycle Length: \(customPattern.cycleLength)")
            return (customPattern.dayShifts, customPattern.startDate)
        } else {
            let pattern = settings.shiftPatternType.generatePattern()
            print("=== getSafeShiftPattern: Regular Pattern ===")
            print("Pattern Type: \(settings.shiftPatternType)")
            print("Generated Pattern: \(pattern)")
            // 일반 패턴의 경우 2024년 1월 1일부터 시작
            let patternStartDate = Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 1)) ?? Date()
            print("Regular Pattern Start Date: \(patternStartDate)")
            return (pattern, patternStartDate)
        }
    }

    private func generateDefaultSchedule() {
        let calendar = Calendar.current
        let today = Date()
        
        // 1. 패턴 결정
        let (shiftPattern, patternStartDate) = getSafeShiftPattern()
        let finalShiftPattern = validateAndGetFinalPattern(shiftPattern)
        
        print("=== Schedule Generation Debug ===")
        print("Pattern Type: \(settings.shiftPatternType)")
        print("Pattern Start Date: \(patternStartDate)")
        print("Final Pattern Count: \(finalShiftPattern.count)")
        print("Final Pattern: \(finalShiftPattern)")
        
        // 2. 스케줄 생성 범위 결정
        let startDate: Date
        let endDate = calendar.date(from: DateComponents(year: 2026, month: 12, day: 31)) ?? today
        
        if settings.shiftPatternType == .custom {
            // 커스텀 패턴의 경우: 시작일부터 스케줄 생성
            startDate = patternStartDate
            print("Custom pattern: Starting from pattern start date: \(startDate)")
        } else {
            // 일반 패턴의 경우: 2024년 1월 1일부터 스케줄 생성
            startDate = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1)) ?? today
            print("Regular pattern: Starting from 2024-01-01")
        }
        
        var currentDate = startDate
        var newSchedules: [ShiftSchedule] = []
        let patternCount = finalShiftPattern.count
        
        while currentDate <= endDate {
            if settings.shiftPatternType == .custom {
                // 커스텀 패턴: 시작일부터 패턴 적용
                let daysFromStart = calendar.dateComponents([.day], from: patternStartDate, to: currentDate).day ?? 0
                if daysFromStart >= 0 {
                    // 시작일 이후에만 패턴 적용
                    let patternIndex = daysFromStart % patternCount
                    let shiftType = finalShiftPattern[patternIndex]
                    let schedule = ShiftSchedule(date: currentDate, shiftType: shiftType)
                    newSchedules.append(schedule)
                }
                // 시작일 이전에는 스케줄을 생성하지 않음
            } else {
                // 일반 패턴: 전체 기간에 패턴 적용
                let daysFromStart = calendar.dateComponents([.day], from: patternStartDate, to: currentDate).day ?? 0
                let patternIndex = ((daysFromStart % patternCount) + patternCount) % patternCount
                let shiftType = finalShiftPattern[patternIndex]
                let schedule = ShiftSchedule(date: currentDate, shiftType: shiftType)
                newSchedules.append(schedule)
            }
            
            // 다음 날짜로 이동
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        print("=== Schedule Generation Complete ===")
        print("Total schedules generated: \(newSchedules.count)")
        if !newSchedules.isEmpty {
            print("First schedule: \(newSchedules.first!.date) - \(newSchedules.first!.shiftType)")
            print("Last schedule: \(newSchedules.last!.date) - \(newSchedules.last!.shiftType)")
        }
        
        self.schedules = newSchedules
        saveData()
    }
    
    // 패턴 검증 및 최종 패턴 반환
    private func validateAndGetFinalPattern(_ pattern: [ShiftType]) -> [ShiftType] {
        // 1차 검증: 패턴이 비어있지 않은지 확인
        guard !pattern.isEmpty else {
            print("Warning: Pattern is empty, using default 3-day pattern")
            return [.주간, .야간, .휴무]
        }
        
        // 2차 검증: 패턴에 유효한 값만 있는지 확인
        let validPattern = pattern.filter { shiftType in
            switch shiftType {
            case .주간, .야간, .심야, .오후, .당직, .휴무, .비번:
                return true
            }
        }
        
        guard !validPattern.isEmpty else {
            print("Warning: Pattern contains no valid shift types, using default")
            return [.주간, .야간, .휴무]
        }
        
        // 3차 검증: 패턴 길이가 0이 아닌지 확인 (이중 안전장치)
        guard validPattern.count > 0 else {
            print("Critical Error: Valid pattern count is 0, using emergency default")
            return [.주간, .야간, .휴무]
        }
        
        print("Valid pattern confirmed: \(validPattern) (count: \(validPattern.count))")
        return validPattern
    }
    
    func regenerateSchedule() {
        schedules.removeAll()
        
        // 커스텀 패턴 타입이지만 커스텀 패턴이 없는 경우 처리
        if settings.shiftPatternType == .custom && settings.customPattern == nil {
            print("Warning: Custom pattern type selected but no custom pattern exists. Resetting to default pattern.")
            settings.shiftPatternType = .fiveTeamThreeShift
        }
        
        generateDefaultSchedule()
    }
    
    // 커스텀 패턴 관련 함수들
    func createCustomPattern(name: String, dayShifts: [ShiftType], cycleLength: Int, startDate: Date, description: String = "") {
        print("=== ShiftManager createCustomPattern ===")
        print("Name: \(name)")
        print("Day Shifts: \(dayShifts)")
        print("Cycle Length: \(cycleLength)")
        print("Start Date: \(startDate)")
        print("Description: \(description)")
        
        // 입력 데이터 검증
        guard !dayShifts.isEmpty else {
            print("Error: dayShifts cannot be empty")
            return
        }
        
        guard cycleLength > 0 else {
            print("Error: cycleLength must be greater than 0")
            return
        }
        
        let customPattern = CustomShiftPattern(
            name: name,
            dayShifts: dayShifts,
            cycleLength: cycleLength,
            startDate: startDate,
            description: description
        )
        
        print("Custom Pattern Created: \(customPattern)")
        print("Final dayShifts count: \(customPattern.dayShifts.count)")
        
        settings.customPattern = customPattern
        settings.shiftPatternType = .custom
        settings.team = "1조" // 커스텀 패턴 시 항상 1조로 설정
        
        print("Settings updated - Custom Pattern: \(settings.customPattern != nil)")
        print("Settings updated - Pattern Type: \(settings.shiftPatternType)")
        print("Settings updated - Team: \(settings.team)")
        
        saveData()
        regenerateSchedule()
        
        print("Custom pattern creation completed!")
    }
    
    // 기존 호환성을 위한 함수
    func createCustomPattern(name: String, shifts: [ShiftType], cycleLength: Int, startDate: Date, description: String = "") {
        createCustomPattern(name: name, dayShifts: shifts, cycleLength: cycleLength, startDate: startDate, description: description)
    }
    
    func updateCustomPattern(_ pattern: CustomShiftPattern) {
        settings.customPattern = pattern
        settings.shiftPatternType = .custom // 근무 유형을 커스텀으로 설정
        saveData()
        regenerateSchedule()
    }
    
    func deleteCustomPattern() {
        settings.customPattern = nil
        settings.shiftPatternType = .fiveTeamThreeShift // 기본값으로 변경
        saveData()
        regenerateSchedule()
    }
    
    func getTeamCount() -> Int {
        switch settings.shiftPatternType {
        case .none: return 0
        case .twoShift: return 2
        case .threeShift: return 3
        case .threeTeamTwoShift: return 3
        case .fourTeamTwoShift: return 4
        case .fourTeamThreeShift: return 4
        case .fiveTeamThreeShift: return 5
        case .irregular: return 6
        case .custom:
            return settings.customPattern?.cycleLength ?? 0
        }
    }
    
    private func getPatternDisplayName(_ patternType: ShiftPatternType) -> String {
        switch patternType {
        case .twoShift:
            return "2교대"
        case .threeShift:
            return "3교대"
        case .threeTeamTwoShift:
            return "3조 2교대"
        case .fourTeamTwoShift:
            return "4조 2교대"
        case .fourTeamThreeShift:
            return "4조 3교대"
        case .fiveTeamThreeShift:
            return "5조 3교대"
        case .irregular:
            return "불규칙"
        case .custom:
            return "커스텀"
        case .none:
            return "없음"
        }
    }
    
    func getColor(for shiftType: ShiftType) -> Color {
        let colorKey = getColorKey(for: shiftType)
        if let hexString = settings.colors[colorKey] {
            return Color(hex: hexString)
        }
        return shiftType.color // Fallback to default if not found in settings
    }
    
    func setColor(_ color: Color, for shiftType: ShiftType) {
        let colorKey = getColorKey(for: shiftType)
        if let hexString = color.toHex() {
            settings.colors[colorKey] = hexString
            saveData()
        }
    }
    
    // 현재 근무 패턴에 해당하는 근무 유형들만 반환
    func getShiftTypesForCurrentPattern() -> [ShiftType] {
        switch settings.shiftPatternType {
        case .none:
            return []
        case .twoShift:
            return [.주간, .야간]
        case .threeShift:
            return [.주간, .야간, .비번]
        case .threeTeamTwoShift:
            return [.주간, .야간, .휴무]
        case .fourTeamTwoShift:
            return [.주간, .야간, .비번, .휴무]
        case .fourTeamThreeShift:
            return [.주간, .오후, .야간, .휴무]
        case .fiveTeamThreeShift:
            return [.주간, .야간, .심야, .비번, .휴무]
        case .irregular:
            return ShiftType.allCases
        case .custom:
            return settings.customPattern?.dayShifts ?? []
        }
    }
    
    // 근무요소 이름 가져오기
    func getShiftName(for shiftType: ShiftType) -> String {
        let nameKey = getNameKey(for: shiftType)
        return settings.shiftNames[nameKey] ?? shiftType.displayName
    }
    
    // 근무요소 이름 업데이트
    func updateShiftName(_ newName: String, for shiftType: ShiftType) {
        let nameKey = getNameKey(for: shiftType)
        settings.shiftNames[nameKey] = newName
        saveData()
    }
    
    func updateColor(for shiftType: ShiftType, newColor: Color) {
        setColor(newColor, for: shiftType)
    }
    
    // 근무 시간 관련 메서드들
    func getShiftTime(for shiftType: ShiftType) -> ShiftTime {
        let timeKey = getTimeKey(for: shiftType)
        return settings.shiftTimes[timeKey] ?? shiftType.defaultShiftTime
    }
    
    func updateShiftTime(_ newTime: ShiftTime, for shiftType: ShiftType) {
        let timeKey = getTimeKey(for: shiftType)
        settings.shiftTimes[timeKey] = newTime
        saveData()
    }
    
    func getShiftTimeRange(for shiftType: ShiftType) -> String {
        let shiftTime = getShiftTime(for: shiftType)
        
        // 특별한 케이스들은 로컬라이제이션된 timeRange 사용
        switch shiftType {
        case .당직, .비번, .휴무:
            return shiftType.timeRange
        default:
            return shiftTime.timeRangeString
        }
    }
    
    func getShiftWorkingHours(for shiftType: ShiftType) -> Double {
        let shiftTime = getShiftTime(for: shiftType)
        return shiftTime.workingHours
    }
    
    private func getTimeKey(for shiftType: ShiftType) -> String {
        switch shiftType {
        case .야간: return "nightShift"
        case .심야: return "deepNightShift"
        case .주간: return "dayShift"
        case .오후: return "afternoonShift"
        case .당직: return "dutyShift"
        case .휴무: return "offDuty"
        case .비번: return "standby"
        }
    }
    
    private func getNameKey(for shiftType: ShiftType) -> String {
        switch shiftType {
        case .야간: return "nightShift"
        case .심야: return "deepNightShift"
        case .주간: return "dayShift"
        case .오후: return "afternoonShift"
        case .당직: return "dutyShift"
        case .휴무: return "offDuty"
        case .비번: return "standby"
        }
    }
    
    private func getColorKey(for shiftType: ShiftType) -> String {
        switch shiftType {
        case .야간: return "nightShift"
        case .심야: return "deepNightShift"
        case .주간: return "dayShift"
        case .오후: return "afternoonShift"
        case .당직: return "dutyShift"
        case .휴무: return "offDuty"
        case .비번: return "standby"
        }
    }
    
    func addSchedule(_ schedule: ShiftSchedule) {
        if let index = schedules.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: schedule.date) }) {
            schedules[index] = schedule
        } else {
            schedules.append(schedule)
        }
        saveData()
    }
    
    func removeSchedule(for date: Date) {
        schedules.removeAll { calendar.isDate($0.date, inSameDayAs: date) }
        saveData()
    }
    
    func saveData() {
        print("🔴 === ShiftManager saveData START ===")
        print("🔴 Current time: \(Date())")
        print("🔴 Schedules count: \(schedules.count)")
        print("🔴 Settings team: \(settings.team)")
        print("🔴 Settings pattern: \(settings.shiftPatternType.rawValue)")

        print("Saving \(schedules.count) schedules")
        for (index, schedule) in schedules.enumerated() {
            print("Schedule \(index): date=\(schedule.date), shiftType=\(schedule.shiftType.rawValue), isVacation=\(schedule.isVacation), isVolunteerWork=\(schedule.isVolunteerWork)")
        }

        if let encoded = try? JSONEncoder().encode(schedules) {
            userDefaults.set(encoded, forKey: schedulesKey)
            print("Schedules saved successfully - \(encoded.count) bytes")
            print("Schedules saved with key: \(schedulesKey)")
            
            // 저장된 JSON 데이터 확인
            if let jsonString = String(data: encoded, encoding: .utf8) {
                print("📄 App Debug - Saved JSON: \(jsonString)")
            }
        } else {
            print("Error: Failed to encode schedules")
        }

        print("Settings: team=\(settings.team), patternType=\(settings.shiftPatternType.rawValue)")
        print("Settings custom pattern: \(settings.customPattern != nil)")
        if let customPattern = settings.customPattern {
            print("Custom pattern name: \(customPattern.name)")
            print("Custom pattern day shifts: \(customPattern.dayShifts.map { $0.rawValue })")
            print("Custom pattern startDate: \(customPattern.startDate)")
            print("Custom pattern cycleLength: \(customPattern.cycleLength)")
        }

        if let encoded = try? JSONEncoder().encode(settings) {
            userDefaults.set(encoded, forKey: settingsKey)
            print("Settings saved successfully - \(encoded.count) bytes")
            print("Settings saved with key: \(settingsKey)")
        } else {
            print("Error: Failed to encode settings")
        }

        // shiftOffset 저장
        userDefaults.set(shiftOffset, forKey: shiftOffsetKey)
        print("ShiftOffset saved: \(shiftOffset)")
        print("ShiftOffset saved with key: \(shiftOffsetKey)")

        // 강제 동기화
        userDefaults.synchronize()
        print("UserDefaults synchronized")

        // App Group UserDefaults도 동기화
        let appGroupDefaults = UserDefaults(suiteName: "group.com.chaeeun.gyodaehaja")!
        appGroupDefaults.synchronize()

        // 간단한 위젯 데이터 저장
        let simpleData = SimpleShiftData(
            shiftType: getCurrentUserShiftType(for: Date(), shiftOffset: shiftOffset).rawValue, // 실제 오늘 근무
            team: settings.team,
            patternType: getPatternDisplayName(settings.shiftPatternType),
            shiftOffset: shiftOffset
        )
        
        if let simpleEncoded = try? JSONEncoder().encode(simpleData) {
            userDefaults.set(simpleEncoded, forKey: "simpleShiftData")
            print("Simple shift data saved: \(simpleData.patternType), team: \(simpleData.team), shift: \(simpleData.shiftType), offset: \(simpleData.shiftOffset)")
            if let jsonString = String(data: simpleEncoded, encoding: .utf8) {
                print("📄 App Debug - Saved Simple JSON: \(jsonString)")
            }
        } else {
            print("Error: Failed to encode simple shift data")
        }

        // 일주일 스케줄 데이터 저장
        let weekData = generateWeekScheduleData()
        if let weekEncoded = try? JSONEncoder().encode(weekData) {
            userDefaults.set(weekEncoded, forKey: "weekScheduleData")
            print("Week schedule data saved: team=\(weekData.team), pattern=\(weekData.patternType), offset=\(weekData.shiftOffset)")
            if let jsonString = String(data: weekEncoded, encoding: .utf8) {
                print("📄 App Debug - Saved Week JSON: \(jsonString)")
            }
        } else {
            print("Error: Failed to encode week schedule data")
        }
        
        // 위젯 타임라인 새로고침 (즉시 + 지연)
        WidgetCenter.shared.reloadAllTimelines()
        print("Widget timelines reloaded (immediate)")
        
        // 지연 후 다시 새로고침
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            WidgetCenter.shared.reloadAllTimelines()
            print("Widget timelines reloaded (delayed)")
        }
        
        print("🔴 === ShiftManager saveData END ===")
    }
    
    private func loadData() {
        print("=== ShiftManager loadData ===")
        
        if let data = userDefaults.data(forKey: schedulesKey) {
            print("Found schedules data: \(data.count) bytes")
            if let decoded = try? JSONDecoder().decode([ShiftSchedule].self, from: data) {
                schedules = decoded
                print("Loaded \(decoded.count) schedules")
                for (index, schedule) in decoded.enumerated() {
                    print("Loaded schedule \(index): date=\(schedule.date), shiftType=\(schedule.shiftType.rawValue), isVacation=\(schedule.isVacation), isVolunteerWork=\(schedule.isVolunteerWork)")
                }
            } else {
                print("Error: Failed to decode schedules")
            }
        } else {
            print("No schedules data found")
        }
        
        if let data = userDefaults.data(forKey: settingsKey) {
            print("Found settings data: \(data.count) bytes")
            if let decoded = try? JSONDecoder().decode(ShiftSettings.self, from: data) {
                settings = decoded
                print("Loaded settings: team=\(decoded.team), patternType=\(decoded.shiftPatternType.rawValue)")
                print("Loaded custom pattern: \(decoded.customPattern != nil)")
                if let customPattern = decoded.customPattern {
                    print("Loaded custom pattern: \(customPattern.dayShifts.map { $0.rawValue })")
                }
            } else {
                print("Error: Failed to decode settings")
            }
        } else {
            print("No settings data found")
        }
        
        // shiftOffset 로드
        shiftOffset = userDefaults.integer(forKey: shiftOffsetKey)
        print("Loaded shiftOffset: \(shiftOffset)")
    }
    
    private let calendar = Calendar.current
    
    // 급여 계산 함수들
    func calculateMonthlySalary(for date: Date) -> Double {
        let calendar = Calendar.current
        let startOfMonth = calendar.startOfMonth(for: date)
        let endOfMonth = calendar.endOfMonth(for: date)
        
        let monthlySchedules = schedules.filter { 
            $0.date >= startOfMonth && $0.date <= endOfMonth 
        }
        
        return calculateSalary(for: monthlySchedules)
    }
    
    func calculateYearlySalary(for date: Date) -> Double {
        let calendar = Calendar.current
        let startOfYear = calendar.dateInterval(of: .year, for: date)?.start ?? date
        let endOfYear = calendar.dateInterval(of: .year, for: date)?.end ?? date
        
        let yearlySchedules = schedules.filter { 
            $0.date >= startOfYear && $0.date < endOfYear 
        }
        
        return calculateSalary(for: yearlySchedules)
    }
    
    private func calculateSalary(for schedules: [ShiftSchedule]) -> Double {
        var totalSalary: Double = 0.0
        
        // 시급 계산 (기본급 ÷ 209)
        let hourlyWage = settings.baseSalary / 209.0
        
        for schedule in schedules {
            var dailySalary: Double = 0.0
            
            // 사용자 설정된 근무 시간 사용
            let workingHours = getShiftWorkingHours(for: schedule.shiftType)
            
            switch schedule.shiftType {
            case .주간:
                // 주간근무: 기본 1.0배
                dailySalary = workingHours * hourlyWage * 1.0
                
            case .야간:
                // 야간근무: 설정된 배율 적용
                dailySalary = workingHours * hourlyWage * settings.nightShiftRate
                
            case .심야:
                // 심야근무: 설정된 배율 적용
                dailySalary = workingHours * hourlyWage * settings.deepNightShiftRate
                
            case .당직:
                // 당직근무: 기본 1.0배
                dailySalary = workingHours * hourlyWage * 1.0
                
            case .오후:
                // 오후근무: 기본 1.0배
                dailySalary = workingHours * hourlyWage * 1.0
                
            case .휴무, .비번:
                // 휴무, 비번: 무급
                dailySalary = 0.0
            }
            
            // 초과근무 수당 추가
            let overtimeHours = Double(schedule.overtimeHours)
            if overtimeHours > 0 {
                dailySalary += overtimeHours * hourlyWage * settings.overtimeRate
            }
            
            totalSalary += dailySalary
        }
        
        return totalSalary
    }
    
    // 요일별 근무 시간 계산
    func getWeeklyWorkHours(for date: Date) -> [String: Int] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.end ?? date
        
        let weeklySchedules = schedules.filter { 
            $0.date >= startOfWeek && $0.date < endOfWeek 
        }
        
        var weeklyHours: [String: Int] = [
            "월요일": 0, "화요일": 0, "수요일": 0, "목요일": 0,
            "금요일": 0, "토요일": 0, "일요일": 0
        ]
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "EEEE"
        
        for schedule in weeklySchedules {
            let dayOfWeek = formatter.string(from: schedule.date)
            let totalHours = schedule.shiftType.workingHours + schedule.overtimeHours
            weeklyHours[dayOfWeek, default: 0] += totalHours
        }
        
        return weeklyHours
    }
    
    // 휴가 관련 메서드들
    func getUsedVacationDays(for year: Int) -> Int {
        let calendar = Calendar.current
        let startOfYear = calendar.dateInterval(of: .year, for: calendar.date(from: DateComponents(year: year)) ?? Date())?.start ?? Date()
        let endOfYear = calendar.dateInterval(of: .year, for: calendar.date(from: DateComponents(year: year)) ?? Date())?.end ?? Date()
        
        return schedules.filter { 
            $0.date >= startOfYear && $0.date < endOfYear && $0.isVacation 
        }.count
    }
    
    func getRemainingVacationDays(for year: Int) -> Int {
        return settings.annualVacationDays - getUsedVacationDays(for: year)
    }
    
    func getVacationDaysByMonth(for year: Int) -> [Int: Int] {
        let calendar = Calendar.current
        var monthlyVacations: [Int: Int] = [:]
        
        for month in 1...12 {
            let startOfMonth = calendar.date(from: DateComponents(year: year, month: month)) ?? Date()
            let endOfMonth = calendar.dateInterval(of: .month, for: startOfMonth)?.end ?? Date()
            
            let monthlyVacationCount = schedules.filter { 
                $0.date >= startOfMonth && $0.date < endOfMonth && $0.isVacation 
            }.count
            
            monthlyVacations[month] = monthlyVacationCount
        }
        
        return monthlyVacations
    }
    
    // MARK: - Data Reset
    func resetAllData() {
        schedules.removeAll()
        settings = ShiftSettings()
        
        // 온보딩 상태 초기화
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        
        // 데이터 저장
        saveData()
        
        // 위젯 업데이트
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: - Color Management
    func updateShiftTypeColor(shiftType: ShiftType, color: Color) {
        if let hexString = color.toHex() {
            settings.colors[shiftType.rawValue] = hexString
            saveData()
        }
    }
    
    // 팀별 근무 타입 가져오기
    func getShiftTypeForTeam(team: Int, date: Date, shiftOffset: Int = 0) -> ShiftType? {
        let calendar = Calendar.current
        
        // 안전한 패턴 가져오기
        var shiftPattern: [ShiftType]
        
        if settings.shiftPatternType == .custom, let customPattern = settings.customPattern {
            // 커스텀 패턴 사용
            shiftPattern = customPattern.dayShifts
            
            // 커스텀 패턴의 경우 시작일 이전에는 nil 반환 (근무 없음)
            let startOfDay = calendar.startOfDay(for: customPattern.startDate)
            let targetStartOfDay = calendar.startOfDay(for: date)
            let daysFromStart = calendar.dateComponents([.day], from: startOfDay, to: targetStartOfDay).day ?? 0
            
            print("=== Custom Pattern Debug ===")
            print("Start date: \(customPattern.startDate)")
            print("Target date: \(date)")
            print("Days from start: \(daysFromStart)")
            print("Pattern: \(shiftPattern.map { $0.rawValue })")
            
            if daysFromStart < 0 {
                // 시작일 이전에는 nil 반환 (근무 없음)
                print("Before start date, returning nil")
                return nil
            }
            
            // 커스텀 패턴: 시작일부터의 일수를 사용
            // 팀별로 근무가 하나씩 밀려서 엇갈리게 구성
            let teamOffset = (team - 1) // 각 조는 1일씩 차이
            let adjustedDay = daysFromStart + teamOffset + shiftOffset
            let patternIndex = adjustedDay % shiftPattern.count
            let positiveIndex = patternIndex >= 0 ? patternIndex : shiftPattern.count + patternIndex
            
            print("Team: \(team), Team offset: \(teamOffset), Shift offset: \(shiftOffset)")
            print("Adjusted day: \(adjustedDay), Pattern index: \(patternIndex), Positive index: \(positiveIndex)")
            print("Returning shift type: \(shiftPattern[positiveIndex % shiftPattern.count].rawValue)")
            
            return shiftPattern[positiveIndex % shiftPattern.count]
        } else {
            // 기본 패턴 사용
            shiftPattern = settings.shiftPatternType.generatePattern()
            
            // 패턴이 비어있으면 기본 패턴 사용
            if shiftPattern.isEmpty {
                shiftPattern = [.주간, .야간, .휴무]
            }
            
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
            let adjustedDayOfYear = dayOfYear + shiftOffset // 전체 근무 패턴을 밀고 당김
            
            // 팀별로 근무가 하나씩 밀려서 엇갈리게 구성
            // 같은 날에 1팀이 주간이면 2팀은 야간, 3팀은 비번, 4팀은 휴무 순서
            let teamOffset = (team - 1) // 각 조는 1일씩 차이
            let adjustedDay = (adjustedDayOfYear + teamOffset) % shiftPattern.count
            let positiveIndex = adjustedDay >= 0 ? adjustedDay : shiftPattern.count + adjustedDay
            
            print("=== Standard Pattern Debug ===")
            print("Pattern type: \(settings.shiftPatternType.rawValue)")
            print("Pattern: \(shiftPattern.map { $0.rawValue })")
            print("Day of year: \(dayOfYear), Shift offset: \(shiftOffset)")
            print("Team: \(team), Team offset: \(teamOffset)")
            print("Adjusted day: \(adjustedDay), Positive index: \(positiveIndex)")
            print("Returning shift type: \(shiftPattern[positiveIndex % shiftPattern.count].rawValue)")
            
            return shiftPattern[positiveIndex % shiftPattern.count]
        }
    }
    
    // 팀별 근무 업데이트 (내스케줄과 연동)
    func updateShiftForTeam(date: Date, team: Int, shiftType: ShiftType) {
        let calendar = Calendar.current
        
        // 해당 날짜의 스케줄을 찾거나 생성
        if let index = schedules.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            // 기존 스케줄이 있으면 업데이트
            schedules[index].shiftType = shiftType
        } else {
            // 새 스케줄 생성
            let newSchedule = ShiftSchedule(date: date, shiftType: shiftType)
            schedules.append(newSchedule)
        }
        
        // 데이터 저장
        saveData()
        print("Updated shift for team \(team) on \(date): \(shiftType.rawValue)")
    }
    
    // 현재 사용자의 팀 번호 가져오기
    func getCurrentTeamNumber() -> Int {
        let teamString = settings.team
        if teamString.hasSuffix("조") {
            let numberString = String(teamString.dropLast())
            return Int(numberString) ?? 1
        }
        return 1
    }
    
    // 현재 사용자의 근무 타입 가져오기 (내스케줄용)
    func getCurrentUserShiftType(for date: Date, shiftOffset: Int = 0) -> ShiftType {
        let currentTeam = getCurrentTeamNumber()
        print("📱 App Debug - getCurrentUserShiftType: date=\(date), currentTeam=\(currentTeam), shiftOffset=\(shiftOffset)")
        let result = getShiftTypeForTeam(team: currentTeam, date: date, shiftOffset: shiftOffset) ?? .휴무 // 근무 없을 경우 휴무 반환
        print("📱 App Debug - getCurrentUserShiftType result: \(result.rawValue)")
        return result
    }
    
    // 일주일 스케줄 데이터 생성
    func generateWeekScheduleData() -> WeekScheduleData {
        let calendar = Calendar.current
        let today = Date()
        
        // 이번 주의 시작일 (월요일) 계산
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = weekday == 1 ? 6 : weekday - 2
        let weekStart = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
        
        let dayNames = ["월", "화", "수", "목", "금", "토", "일"]
        var weekData: [DayScheduleData] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: i, to: weekStart) ?? today
            let dayName = dayNames[i]
            
            // 날짜 포맷팅
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M/d"
            let dateString = dateFormatter.string(from: date)
            
            // 해당 날짜의 근무 타입 가져오기
            let shiftType = getCurrentUserShiftType(for: date, shiftOffset: shiftOffset)
            
            weekData.append(DayScheduleData(
                day: dayName,
                shiftType: shiftType.rawValue,
                date: dateString
            ))
        }
        
        return WeekScheduleData(
            weekData: weekData,
            team: settings.team,
            patternType: getPatternDisplayName(settings.shiftPatternType),
            shiftOffset: shiftOffset
        )
    }
    
    // MARK: - Custom Shift Type Management
    
    // 커스텀 근무 요소 추가
    func addCustomShiftType(_ customShiftType: CustomShiftType) {
        settings.customShiftTypes.append(customShiftType)
        saveData()
    }
    
    // 커스텀 근무 요소 삭제
    func removeCustomShiftType(_ customShiftType: CustomShiftType) {
        settings.customShiftTypes.removeAll { $0.id == customShiftType.id }
        saveData()
    }
    
    // 커스텀 근무 요소 업데이트
    func updateCustomShiftType(_ customShiftType: CustomShiftType) {
        if let index = settings.customShiftTypes.firstIndex(where: { $0.id == customShiftType.id }) {
            settings.customShiftTypes[index] = customShiftType
            saveData()
        }
    }
    
    // 모든 커스텀 근무 요소 가져오기
    func getAllCustomShiftTypes() -> [CustomShiftType] {
        return settings.customShiftTypes
    }
    
    // 이름으로 커스텀 근무 요소 찾기
    func findCustomShiftType(by name: String) -> CustomShiftType? {
        return settings.customShiftTypes.first { $0.name == name }
    }
}

// MARK: - ShiftType Extensions
extension ShiftType {
    static var allColors: [Color] {
        return [
            .nightShift, .deepNightShift, .dayShift, .offDuty, .standby,
            .mainColor, .mainColorButton, .mainColorDark, .pointColor, .subColor1, .subColor2,
            Color(hex: "439897"), Color(hex: "4B4B4B"), Color(hex: "F47F4C"), Color(hex: "2C3E50"), Color(hex: "77BBFB"),
            Color(hex: "7E85F9"), Color(hex: "FFA8D2"), Color(hex: "C39DF4"), Color(hex: "92E3A9"), Color(hex: "B9D831"),
            .red, .orange, .yellow, .green, .blue, .purple, .pink, .gray, .brown, .cyan, .mint, .indigo, .teal
        ]
    }
}

