import Foundation
import SwiftUI

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
enum ShiftType: String, CaseIterable, Codable {
    case 주간 = "주간"
    case 야간 = "야간"
    case 심야 = "심야"
    case 오후 = "오후"
    case 당직 = "당직"
    case 비번 = "비번"
    case 휴무 = "휴무"
    
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
        case .당직: return "24시간"
        case .비번: return "대기"
        case .휴무: return "휴무"
        }
    }
}

// MARK: - Shift Pattern Types
enum ShiftPatternType: String, CaseIterable, Codable {
    case twoShift = "2교대"
    case threeShift = "3교대"
    case threeTeamTwoShift = "3조 2교대"
    case fourTeamTwoShift = "4조 2교대"
    case fourTeamThreeShift = "4조 3교대"
    case fiveTeamThreeShift = "5조 3교대"
    case irregular = "비주기적"
    
    var displayName: String {
        switch self {
        case .twoShift: return "2교대"
        case .threeShift: return "3교대"
        case .threeTeamTwoShift: return "3조 2교대"
        case .fourTeamTwoShift: return "4조 2교대"
        case .fourTeamThreeShift: return "4조 3교대"
        case .fiveTeamThreeShift: return "5조 3교대"
        case .irregular: return "비주기적"
        }
    }
    
    var description: String {
        switch self {
        case .twoShift: return "주간/야간 (12시간씩)"
        case .threeShift: return "주간/오후/야간 (8시간씩)"
        case .threeTeamTwoShift: return "당직-비번-휴무 (3조 2교대)"
        case .fourTeamTwoShift: return "주간-야간-비번-휴무 (4조 2교대)"
        case .fourTeamThreeShift: return "4조로 3교대 + 휴일 보장"
        case .fiveTeamThreeShift: return "5조로 3교대 + 충분한 휴무"
        case .irregular: return "월마다 비주기적 배치"
        }
    }
    
    func generatePattern() -> [ShiftType] {
        switch self {
        case .twoShift:
            return [.주간, .야간]
        case .threeShift:
            return [.주간, .오후, .야간]
        case .threeTeamTwoShift:
            return [.당직, .비번, .휴무]
        case .fourTeamTwoShift:
            return [.주간, .야간, .비번, .휴무]
        case .fourTeamThreeShift:
            return [.주간, .오후, .야간, .휴무]
        case .fiveTeamThreeShift:
            return [.주간, .야간, .심야, .비번, .휴무]
        case .irregular:
            return [.주간, .오후, .야간, .심야, .비번, .휴무]
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
}

struct ShiftSettings: Codable {
    var team: String = "1조"
    var shiftPatternType: ShiftPatternType = .fiveTeamThreeShift
    var colors: [String: String] = [:]
    
    // 급여 정보 추가
    var hourlyWage: Double = 0.0
    var nightShiftBonus: Double = 0.0  // 야간 근무 시간당 추가 금액
    var overtimeRate: Double = 1.5      // 초과근무 배율 (기본 1.5배)
    var deepNightShiftBonus: Double = 0.0  // 심야 근무 시간당 추가 금액
    
    // 휴가 정보 추가
    var annualVacationDays: Int = 15  // 연간 휴가 일수
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
    
    private let userDefaults = UserDefaults.standard
    private let schedulesKey = "shiftSchedules"
    private let settingsKey = "shiftSettings"
    
    init() {
        loadData()
        if schedules.isEmpty {
            generateDefaultSchedule()
        }
    }
    
    private func generateDefaultSchedule() {
        let calendar = Calendar.current
        let today = Date()
        let startOfMonth = calendar.startOfMonth(for: today)
        
        let shiftPattern = settings.shiftPatternType.generatePattern()
        
        var currentDate = startOfMonth
        var patternIndex = 0
        
        // Generate schedule for the current month
        while calendar.isDate(currentDate, equalTo: startOfMonth, toGranularity: .month) {
            let shiftType = shiftPattern[patternIndex % shiftPattern.count]
            let schedule = ShiftSchedule(date: currentDate, shiftType: shiftType)
            schedules.append(schedule)
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            patternIndex += 1
        }
        
        saveData()
    }
    
    func regenerateSchedule() {
        schedules.removeAll()
        generateDefaultSchedule()
    }
    
    func getTeamCount() -> Int {
        switch settings.shiftPatternType {
        case .twoShift: return 2
        case .threeShift: return 3
        case .threeTeamTwoShift: return 3
        case .fourTeamTwoShift: return 4
        case .fourTeamThreeShift: return 4
        case .fiveTeamThreeShift: return 5
        case .irregular: return 6
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
        if let encoded = try? JSONEncoder().encode(schedules) {
            userDefaults.set(encoded, forKey: schedulesKey)
        }
        if let encoded = try? JSONEncoder().encode(settings) {
            userDefaults.set(encoded, forKey: settingsKey)
        }
    }
    
    private func loadData() {
        if let data = userDefaults.data(forKey: schedulesKey),
           let decoded = try? JSONDecoder().decode([ShiftSchedule].self, from: data) {
            schedules = decoded
        }
        if let data = userDefaults.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(ShiftSettings.self, from: data) {
            settings = decoded
        }
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
        
        for schedule in schedules {
            let baseHours = Double(schedule.shiftType.workingHours)
            let overtimeHours = Double(schedule.overtimeHours)
            
            // 기본 급여
            var dailySalary = baseHours * settings.hourlyWage
            
            // 야간 근무 보너스
            if schedule.shiftType == .야간 {
                dailySalary += baseHours * settings.nightShiftBonus
            }
            
            // 심야 근무 보너스
            if schedule.shiftType == .심야 {
                dailySalary += baseHours * settings.deepNightShiftBonus
            }
            
            // 초과근무 급여
            if overtimeHours > 0 {
                dailySalary += overtimeHours * settings.hourlyWage * settings.overtimeRate
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
}

