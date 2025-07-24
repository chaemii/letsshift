//
//  ShiftCalendarApp_App.swift
//  ShiftCalendarApp_
//
//  Created by cham on 7/21/25.
//

import SwiftUI

@main
struct ShiftCalendarApp_App: App {
    @StateObject private var shiftManager = ShiftManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(shiftManager)
                .onOpenURL { url in
                    handleDeepLink(url: url)
                }
        }
    }
    
    private func handleDeepLink(url: URL) {
        guard url.scheme == "letsshift" else { return }
        
        if url.host == "schedule" {
            // URL 쿼리 파라미터에서 데이터 추출
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            if let dataParam = components?.queryItems?.first(where: { $0.name == "data" })?.value,
               let data = Data(base64Encoded: dataParam) {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        applySharedSchedule(from: json)
                    }
                } catch {
                    print("Error parsing shared schedule data: \(error)")
                }
            }
        }
    }
    
    private func applySharedSchedule(from json: [String: Any]) {
        // 패턴 타입 적용
        if let patternTypeString = json["patternType"] as? String,
           let patternType = ShiftPatternType(rawValue: patternTypeString) {
            shiftManager.settings.shiftPatternType = patternType
        }
        
        // 팀 적용
        if let team = json["team"] as? String {
            shiftManager.settings.team = team
        }
        
        // 커스텀 패턴 적용
        if let customPatternDict = json["customPattern"] as? [String: Any] {
            applyCustomPattern(from: customPatternDict)
        }
        
        // 스케줄은 자동 생성 (기존 스케줄 삭제 후 새로 생성)
        shiftManager.schedules.removeAll()
        // 설정 변경 후 스케줄 재생성
        shiftManager.objectWillChange.send()
        // 앱이 다시 시작될 때 자동으로 스케줄이 생성됨
        
        // 설정 저장
        shiftManager.saveData()
    }
    
    private func applyCustomPattern(from dict: [String: Any]) {
        guard let name = dict["name"] as? String,
              let dayShiftsStrings = dict["dayShifts"] as? [String],
              let cycleLength = dict["cycleLength"] as? Int,
              let startDateInterval = dict["startDate"] as? TimeInterval,
              let description = dict["description"] as? String else {
            return
        }
        
        let dayShifts = dayShiftsStrings.compactMap { ShiftType(rawValue: $0) }
        let startDate = Date(timeIntervalSince1970: startDateInterval)
        
        let customPattern = CustomShiftPattern(
            name: name,
            dayShifts: dayShifts,
            cycleLength: cycleLength,
            startDate: startDate,
            description: description
        )
        
        shiftManager.settings.customPattern = customPattern
    }
    
    private func applySchedules(from schedulesArray: [[String: Any]]) {
        var newSchedules: [ShiftSchedule] = []
        
        for scheduleDict in schedulesArray {
            guard let _ = scheduleDict["id"] as? String,
                  let dateInterval = scheduleDict["date"] as? TimeInterval,
                  let shiftTypeString = scheduleDict["shiftType"] as? String,
                  let shiftType = ShiftType(rawValue: shiftTypeString),
                  let overtimeHours = scheduleDict["overtimeHours"] as? Int,
                  let isVacation = scheduleDict["isVacation"] as? Bool,
                  let isVolunteerWork = scheduleDict["isVolunteerWork"] as? Bool else {
                continue
            }
            
            let date = Date(timeIntervalSince1970: dateInterval)
            let vacationTypeString = scheduleDict["vacationType"] as? String
            let vacationType = vacationTypeString.flatMap { VacationType(rawValue: $0) }
            
            let schedule = ShiftSchedule(
                date: date,
                shiftType: shiftType,
                overtimeHours: overtimeHours,
                isVacation: isVacation,
                vacationType: vacationType,
                isVolunteerWork: isVolunteerWork
            )
            
            newSchedules.append(schedule)
        }
        
        shiftManager.schedules = newSchedules
    }
}
