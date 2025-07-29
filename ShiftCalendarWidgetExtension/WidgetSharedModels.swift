//
//  WidgetSharedModels.swift
//  ShiftCalendarWidgetExtension
//
//  Created by cham on 7/24/25.
//

import SwiftUI

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