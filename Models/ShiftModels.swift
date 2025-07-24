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

// MARK: - Custom Shift Pattern
struct CustomShiftPattern: Codable, Identifiable {
    var id = UUID()
    var name: String
    var dayShifts: [ShiftType] // 각 일차별 근무 요소 (1일차, 2일차, 3일차...)
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
        self.cycleLength = cycleLength
        self.startDate = Date() // 기본값으로 오늘 날짜
        self.description = description.isEmpty ? "\(shifts.count)일 주기" : description
    }
    
    // 새로운 간단한 initializer
    init(cycleLength: Int, startDate: Date, dayShifts: [ShiftType]) {
        self.name = "커스텀 패턴"
        self.cycleLength = max(2, min(7, cycleLength)) // 2-7일 제한
        self.startDate = startDate
        self.dayShifts = dayShifts.isEmpty ? [.주간, .야간, .휴무] : dayShifts
        self.description = "\(self.dayShifts.count)일 주기"
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
    case custom = "나만의 패턴"
    
    var displayName: String {
        switch self {
        case .twoShift: return "2교대"
        case .threeShift: return "3교대"
        case .threeTeamTwoShift: return "3조 2교대"
        case .fourTeamTwoShift: return "4조 2교대"
        case .fourTeamThreeShift: return "4조 3교대"
        case .fiveTeamThreeShift: return "5조 3교대"
        case .irregular: return "비주기적"
        case .custom: return "나만의 패턴"
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
        case .custom: return "직접 만드는 근무 패턴"
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
        
        // 1. 패턴 결정 - 완전히 안전한 방식
        let (shiftPattern, patternStartDate) = getSafeShiftPattern()
        
        // 2. 최종 패턴 검증 - 절대 빈 배열이 되지 않도록
        let finalShiftPattern = validateAndGetFinalPattern(shiftPattern)
        
        print("=== Schedule Generation Debug ===")
        print("Pattern Type: \(settings.shiftPatternType)")
        print("Final Pattern Count: \(finalShiftPattern.count)")
        print("Final Pattern: \(finalShiftPattern)")
        
        var currentDate = startOfMonth
        var patternIndex = 0
        
        // 커스텀 패턴의 경우 시작일부터 패턴 계산
        if settings.shiftPatternType == .custom {
            // 시작일이 현재 월보다 나중인 경우, 시작일부터 스케줄 생성
            if patternStartDate > startOfMonth {
                print("Warning: patternStartDate (\(patternStartDate)) is after current month start (\(startOfMonth))")
                print("Starting schedule from patternStartDate")
                currentDate = patternStartDate
                patternIndex = 0
            } else {
                let daysFromStart = calendar.dateComponents([.day], from: patternStartDate, to: currentDate).day ?? 0
                patternIndex = daysFromStart % finalShiftPattern.count
                print("Pattern calculation - daysFromStart: \(daysFromStart), patternIndex: \(patternIndex)")
            }
        }
        
        // Generate schedule for the current month
        while calendar.isDate(currentDate, equalTo: startOfMonth, toGranularity: .month) {
            // 절대적인 안전장치: patternIndex가 음수이거나 배열 범위를 벗어나지 않도록
            let safeIndex = max(0, patternIndex) % finalShiftPattern.count
            let shiftType = finalShiftPattern[safeIndex]
            
            print("Schedule generation - currentDate: \(currentDate), patternIndex: \(patternIndex), safeIndex: \(safeIndex), shiftType: \(shiftType)")
            
            let schedule = ShiftSchedule(date: currentDate, shiftType: shiftType)
            schedules.append(schedule)
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            patternIndex += 1
        }
        
        saveData()
    }
    
    // 안전한 패턴 가져오기
    private func getSafeShiftPattern() -> ([ShiftType], Date) {
        if settings.shiftPatternType == .custom, let customPattern = settings.customPattern {
            print("Using custom pattern: \(customPattern.dayShifts)")
            return (customPattern.dayShifts, customPattern.startDate)
        } else {
            let pattern = settings.shiftPatternType.generatePattern()
            print("Using generated pattern: \(pattern)")
            return (pattern, Date())
        }
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
    func createCustomPattern(name: String, shifts: [ShiftType], cycleLength: Int, description: String = "") {
        createCustomPattern(name: name, dayShifts: shifts, cycleLength: cycleLength, startDate: Date(), description: description)
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
            return ShiftType.allCases
        case .custom:
            return settings.customPattern?.dayShifts ?? []
        }
    }
    
    // 근무요소 이름 가져오기
    func getShiftName(for shiftType: ShiftType) -> String {
        let nameKey = getNameKey(for: shiftType)
        return settings.shiftNames[nameKey] ?? shiftType.rawValue
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
        print("=== ShiftManager saveData ===")
        
        if let encoded = try? JSONEncoder().encode(schedules) {
            userDefaults.set(encoded, forKey: schedulesKey)
            print("Schedules saved successfully")
        } else {
            print("Error: Failed to encode schedules")
        }
        
        if let encoded = try? JSONEncoder().encode(settings) {
            userDefaults.set(encoded, forKey: settingsKey)
            print("Settings saved successfully")
            print("Settings custom pattern: \(settings.customPattern != nil)")
            if let customPattern = settings.customPattern {
                print("Custom pattern name: \(customPattern.name)")
                print("Custom pattern day shifts: \(customPattern.dayShifts)")
            }
        } else {
            print("Error: Failed to encode settings")
        }
        
        userDefaults.synchronize()
        print("UserDefaults synchronized")
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
        
        // 시급 계산 (기본급 ÷ 209)
        let hourlyWage = settings.baseSalary / 209.0
        
        for schedule in schedules {
            var dailySalary: Double = 0.0
            
            switch schedule.shiftType {
            case .주간:
                // 주간근무: 09:00~18:00 (9시간) - 1.0배
                dailySalary = 9.0 * hourlyWage * 1.0
                
            case .야간:
                // 야간근무: 18:00~23:00 (5시간) - 1.5배
                dailySalary = 5.0 * hourlyWage * settings.nightShiftRate
                
            case .심야:
                // 심야근무: 23:00~익일 07:00 (8시간) - 2.0배
                dailySalary = 8.0 * hourlyWage * settings.deepNightShiftRate
                
            case .당직:
                // 당직근무: 24시간 대기 (4시간 실제근무 가정) - 1.0배
                dailySalary = 4.0 * hourlyWage * 1.0
                
            case .오후:
                // 오후근무: 주간과 동일하게 처리
                dailySalary = 9.0 * hourlyWage * 1.0
                
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
        saveData()
    }
    
    // MARK: - Color Management
    func updateShiftTypeColor(shiftType: ShiftType, color: Color) {
        if let hexString = color.toHex() {
            settings.colors[shiftType.rawValue] = hexString
            saveData()
        }
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

