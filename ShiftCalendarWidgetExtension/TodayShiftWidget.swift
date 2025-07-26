//
//  TodayShiftWidget.swift
//  ShiftCalendarWidgetExtension
//
//  Created by cham on 7/24/25.
//

import WidgetKit
import SwiftUI

// 간단한 데이터 구조
struct SimpleShiftData: Codable {
    let shiftType: String
    let team: String
    let patternType: String
    let shiftOffset: Int
}

// 근무 타입별 색상 매핑 (WidgetSharedModels의 ShiftType 사용)
extension String {
    var shiftColor: Color {
        if let shiftType = ShiftType(rawValue: self) {
            return shiftType.color
        }
        return .gray
    }
}

struct TodayShiftWidgetEntryView: View {
    var entry: TodayShiftProvider.Entry
    @State private var isRefreshing = false
    
    private var todayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더: 제목과 날짜
            HStack {
                Text("오늘 근무")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(todayDate)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            Spacer()
            
            // 근무 타입 (원 안에 텍스트) - 중앙 정렬
            VStack(spacing: 8) {
                ZStack {
                    // 배경 원 (85% 크기로 조정)
                    Circle()
                        .fill(entry.shiftType.shiftColor)
                        .frame(width: 85, height: 85)
                    
                    // 근무 타입 텍스트 (크기 조정)
                    Text(entry.shiftType)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                
                // 팀 정보
                Text(entry.team)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 새로고침 상태
            if isRefreshing {
                ProgressView()
                    .scaleEffect(0.6)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onTapGesture {
            print("🔄 Widget tapped - refreshing")
            isRefreshing = true
            
            // 위젯 타임라인 새로고침
            WidgetCenter.shared.reloadAllTimelines()
            
            // 1초 후 새로고침 상태 해제
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isRefreshing = false
            }
        }
    }
}

struct TodayShiftProvider: TimelineProvider {
    typealias Entry = TodayShiftEntry
    
    func placeholder(in context: Context) -> TodayShiftEntry {
        TodayShiftEntry(date: Date(), shiftType: "주간", team: "1조")
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayShiftEntry) -> ()) {
        let entry = TodayShiftEntry(date: Date(), shiftType: getTodayShift(), team: getCurrentTeam())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        print("🔄 Widget Timeline Requested")
        
        let currentDate = Date()
        let shiftType = getTodayShift()
        let team = getCurrentTeam()
        
        let entry = TodayShiftEntry(date: currentDate, shiftType: shiftType, team: team)
        
        // 5분마다 업데이트
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        print("✅ Widget Timeline Created: \(shiftType) for \(team)")
        completion(timeline)
    }
    
    private func getTodayShift() -> String {
        print("🔵 Widget getTodayShift START")
        
        let userDefaults = UserDefaults(suiteName: "group.com.chaeeun.ShiftCalendarApp")!
        
        // UserDefaults 동기화
        userDefaults.synchronize()
        
        // 간단한 데이터 구조로 읽기
        if let data = userDefaults.data(forKey: "simpleShiftData"),
           let shiftData = try? JSONDecoder().decode(SimpleShiftData.self, from: data) {
            
            print("📄 Widget Debug - Found simple data: \(shiftData.shiftType), team: \(shiftData.team), offset: \(shiftData.shiftOffset)")
            
            // 오늘 날짜 계산
            let today = Date()
            let calendar = Calendar.current
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today) ?? 1
            
            // shiftOffset 적용
            let adjustedDay = dayOfYear + shiftData.shiftOffset
            
            // 패턴에 따른 근무 계산
            let shiftType = calculateShiftType(pattern: shiftData.patternType, team: shiftData.team, day: adjustedDay)
            
            print("🔵 Widget getTodayShift END: \(shiftType)")
            return shiftType
        }
        
        print("🔵 Widget getTodayShift END: 기본값")
        return "주간"
    }
    
    private func getCurrentTeam() -> String {
        let userDefaults = UserDefaults(suiteName: "group.com.chaeeun.ShiftCalendarApp")!
        
        if let data = userDefaults.data(forKey: "simpleShiftData"),
           let shiftData = try? JSONDecoder().decode(SimpleShiftData.self, from: data) {
            return shiftData.team
        }
        
        return "1조"
    }
    
    private func calculateShiftType(pattern: String, team: String, day: Int) -> String {
        let teamNumber = Int(team.replacingOccurrences(of: "조", with: "")) ?? 1
        
        switch pattern {
        case "2교대":
            let cycle = (day + teamNumber - 1) % 2
            return cycle == 0 ? "주간" : "야간"
            
        case "3교대":
            let cycle = (day + teamNumber - 1) % 3
            switch cycle {
            case 0: return "주간"
            case 1: return "야간"
            default: return "비번"
            }
            
        case "3조 2교대":
            let cycle = (day + teamNumber - 1) % 3
            switch cycle {
            case 0: return "주간"
            case 1: return "야간"
            default: return "휴무"
            }
            
        case "4조 2교대":
            let cycle = (day + teamNumber - 1) % 4
            switch cycle {
            case 0: return "주간"
            case 1: return "야간"
            case 2: return "비번"
            default: return "휴무"
            }
            
        case "4조 3교대":
            let cycle = (day + teamNumber - 1) % 4
            switch cycle {
            case 0: return "주간"
            case 1: return "오후"
            case 2: return "야간"
            default: return "휴무"
            }
            
        case "5조 3교대":
            let cycle = (day + teamNumber - 1) % 5
            switch cycle {
            case 0: return "주간"
            case 1: return "야간"
            case 2: return "심야"
            case 3: return "비번"
            default: return "휴무"
            }
            
        default:
            return "주간"
        }
    }
}

struct TodayShiftEntry: TimelineEntry {
    let date: Date
    let shiftType: String
    let team: String
}

struct TodayShiftWidget: Widget {
    let kind: String = "TodayShiftWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayShiftProvider()) { entry in
            TodayShiftWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("오늘 근무")
        .description("오늘의 근무를 표시합니다.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    TodayShiftWidget()
} timeline: {
    TodayShiftEntry(date: .now, shiftType: "주간", team: "1조")
} 