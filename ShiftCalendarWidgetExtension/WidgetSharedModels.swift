//
//  WidgetSharedModels.swift
//  ShiftCalendarWidgetExtension
//
//  Created by cham on 7/24/25.
//

import SwiftUI

// Widget Localization Helper
struct WidgetLocalizer {
    static var isEnglish: Bool {
        let preferredLanguage = Locale.preferredLanguages.first ?? "ko"
        return preferredLanguage.hasPrefix("en")
    }
    
    static func localizedString(_ key: String) -> String {
        if isEnglish {
            switch key {
            // Widget titles
            case "today_shift": return "Today's Shift"
            case "today_schedule": return "Today's Schedule"  
            case "today_schedule_description": return "Check today's work schedule."
            case "this_week": return "This Week"
            
            // Shift types
            case "DAY": return "DAY"
            case "EVE": return "EVE"
            case "NGT": return "NGT"
            case "AFT": return "AFT"
            case "ONC": return "ONC"
            case "OFF": return "OFF"
            case "RST": return "RST"
            
            // Weekdays
            case "weekday_mon_short": return "Mon"
            case "weekday_tue_short": return "Tue"
            case "weekday_wed_short": return "Wed"
            case "weekday_thu_short": return "Thu"
            case "weekday_fri_short": return "Fri"
            case "weekday_sat_short": return "Sat"
            case "weekday_sun_short": return "Sun"
            
            // Pattern types  
            case "pattern_three_shift": return "3 Shift"
            case "team_format": return "Team %d"
            case "pattern_label": return "Pattern:"
            case "no_info": return "No info"
            case "week_schedule_title": return "This Week"
            
            default: return key
            }
        } else {
            switch key {
            // Widget titles
            case "today_shift": return "오늘 근무"
            case "today_schedule": return "오늘 스케줄"
            case "today_schedule_description": return "오늘의 근무 스케줄을 확인하세요."
            case "this_week": return "이번 주"
            
            // Shift types
            case "DAY": return "주간"
            case "EVE": return "야간"
            case "NGT": return "심야"
            case "AFT": return "오후"
            case "ONC": return "당직"
            case "OFF": return "비번"
            case "RST": return "휴무"
            
            // Weekdays
            case "weekday_mon_short": return "월"
            case "weekday_tue_short": return "화"
            case "weekday_wed_short": return "수"
            case "weekday_thu_short": return "목"
            case "weekday_fri_short": return "금"
            case "weekday_sat_short": return "토"
            case "weekday_sun_short": return "일"
            
            // Pattern types
            case "pattern_three_shift": return "3교대"
            case "team_format": return "%d조"
            case "pattern_label": return "패턴:"
            case "no_info": return "정보 없음"
            case "week_schedule_title": return "일주일 스케줄"
            
            default: return key
            }
        }
    }
}

// String extension for localized shift names
extension String {
    var localizedShiftName: String {
        if let shiftType = ShiftType(rawValue: self) {
            return shiftType.displayName
        }
        return self // 변환 실패시 원래 문자열 반환
    }
}

// 앱의 VacationType enum (위젯에서 사용)
enum VacationType: String, CaseIterable, Codable {
    case 연차 = "연차"
    case 특별휴가 = "특별 휴가"
}

// 앱의 스케줄 데이터 구조체 (위젯에서 사용) - 앱과 동일한 구조
struct ShiftScheduleData: Codable {
    let id: UUID
    let date: Date
    let shiftType: ShiftType
    let overtimeHours: Int
    let isVacation: Bool
    let vacationType: VacationType?
    let isVolunteerWork: Bool
}

// 앱의 ShiftPatternType enum (위젯에서 사용)
enum ShiftPatternType: String, CaseIterable, Codable {
    case twoShift = "2교대"
    case threeShift = "3교대"
    case threeTeamTwoShift = "3조 2교대"
    case fourTeamTwoShift = "4조 2교대"
    case fourTeamThreeShift = "4조 3교대"
    case fiveTeamThreeShift = "5조 3교대"
    case irregular = "비주기적"
    case custom = "나만의 패턴"
}

// 앱의 설정 데이터 구조체 (위젯에서 사용) - 앱과 동일한 구조
struct ShiftSettingsData: Codable {
    let team: String
    let shiftPatternType: ShiftPatternType
    let colors: [String: String]
    let shiftNames: [String: String]
    let customPattern: CustomPatternData?
    let baseSalary: Double
    let nightShiftRate: Double
    let deepNightShiftRate: Double
    let overtimeRate: Double
    let holidayWorkRate: Double
    let annualVacationDays: Int
}

// 커스텀 패턴 데이터 (위젯에서 사용)
struct CustomPatternData: Codable {
    let id: UUID
    let name: String
    let dayShifts: [ShiftType]
    let cycleLength: Int
    let startDate: Date
    let description: String
}

// 위젯에서 사용할 ShiftType
enum ShiftType: String, CaseIterable, Codable {
    case 주간 = "주간"
    case 야간 = "야간"
    case 심야 = "심야"
    case 오후 = "오후"
    case 당직 = "당직"
    case 비번 = "비번"
    case 휴무 = "휴무"
    
    var displayName: String {
        switch self {
        case .주간: return WidgetLocalizer.localizedString("DAY")
        case .야간: return WidgetLocalizer.localizedString("EVE")
        case .심야: return WidgetLocalizer.localizedString("NGT")
        case .오후: return WidgetLocalizer.localizedString("AFT")
        case .당직: return WidgetLocalizer.localizedString("ONC")
        case .비번: return WidgetLocalizer.localizedString("OFF")
        case .휴무: return WidgetLocalizer.localizedString("RST")
        }
    }
    
    var color: Color {
        // 앱의 색상 설정에서 가져오기
        return getColorFromAppSettings()
    }
    
    private func getColorFromAppSettings() -> Color {
        let userDefaults = UserDefaults(suiteName: "group.com.chaeeun.gyodaehaja")!
        let settingsKey = "shiftSettings"
        
        if let data = userDefaults.data(forKey: settingsKey),
           let settings = try? JSONDecoder().decode(ShiftSettingsData.self, from: data) {
            
            let colorKey = getColorKey()
            if let hexString = settings.colors[colorKey] {
                return Color(hex: hexString)
            }
        }
        
        // 기본 색상 반환
        return getDefaultColor()
    }
    
    private func getColorKey() -> String {
        switch self {
        case .야간: return "야간"
        case .심야: return "심야"
        case .주간: return "주간"
        case .오후: return "오후"
        case .당직: return "당직"
        case .휴무: return "휴무"
        case .비번: return "비번"
        }
    }
    
    private func getDefaultColor() -> Color {
        switch self {
        case .주간:
            return Color(hex: "77BBFB")
        case .야간:
            return Color(hex: "7E85F9")
        case .심야:
            return Color(hex: "A0B2B6")
        case .오후:
            return Color(hex: "CDB5EB")
        case .당직:
            return Color(hex: "FF5D73")
        case .휴무:
            return Color(hex: "F47F4C")
        case .비번:
            return Color(hex: "92E3A9")
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

// Color 확장 (hex 초기화)
extension Color {
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
    
    static let pointColor = Color(hex: "FF5D73")
} 