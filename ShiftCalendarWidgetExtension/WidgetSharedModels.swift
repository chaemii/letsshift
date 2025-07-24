//
//  WidgetSharedModels.swift
//  ShiftCalendarWidgetExtension
//
//  Created by cham on 7/24/25.
//

import SwiftUI

// 앱의 스케줄 데이터 구조체 (위젯에서 사용)
struct ShiftScheduleData: Codable {
    let date: Date
    let shiftType: ShiftType
    let overtimeHours: Int
    let isVacation: Bool
    let vacationType: String?
    let isVolunteerWork: Bool
}

// 앱의 설정 데이터 구조체 (위젯에서 사용)
struct ShiftSettingsData: Codable {
    let colors: [String: String]
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
        let userDefaults = UserDefaults.standard
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
        case .야간: return "nightShift"
        case .심야: return "deepNightShift"
        case .주간: return "dayShift"
        case .오후: return "afternoonShift"
        case .당직: return "dutyShift"
        case .휴무: return "offDuty"
        case .비번: return "standby"
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
} 