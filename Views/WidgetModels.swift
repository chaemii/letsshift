import SwiftUI

// 위젯에서 사용할 ShiftType 확장
extension ShiftType {
    var color: Color {
        switch self {
        case .주간:
            return Color(hex: "4CAF50") // 녹색
        case .야간:
            return Color(hex: "2196F3") // 파란색
        case .휴무:
            return Color(hex: "FF9800") // 주황색
        case .비번:
            return Color(hex: "9C27B0") // 보라색
        case .대기:
            return Color(hex: "607D8B") // 회색
        default:
            return Color(hex: "E0E0E0") // 기본 회색
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

// 위젯에서 사용할 기본 ShiftType enum
enum ShiftType: String, CaseIterable {
    case 주간 = "주간"
    case 야간 = "야간"
    case 휴무 = "휴무"
    case 비번 = "비번"
    case 대기 = "대기"
} 