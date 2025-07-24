import SwiftUI

struct ShiftTableView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @State private var selectedMonth = Date()
    @State private var shiftOffset: Int = 0
    @State private var hasUnsavedChanges: Bool = false
    
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Month selector
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18))
                            .foregroundColor(.charcoalBlack)
                    }
                    
                    Spacer()
                    
                    Text(monthYearString)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.charcoalBlack)
                    
                    Spacer()
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18))
                            .foregroundColor(.charcoalBlack)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 24)
                
                // Table header
                HStack(spacing: 0) {
                    Text("날짜")
                        .frame(width: 60, alignment: .leading)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.charcoalBlack)
                    
                    ForEach(1...shiftManager.getTeamCount(), id: \.self) { teamNumber in
                        Text("\(teamNumber)조")
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(teamNumber == getTeamNumber() ? .charcoalBlack : .charcoalBlack.opacity(0.6))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color.backgroundLight)
                
                // Table content - 스크롤 가능하게
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(daysInMonth, id: \.self) { date in
                            ShiftTableRow(
                                date: date,
                                currentTeam: getTeamNumber(),
                                shiftOffset: shiftOffset
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 140) // 플로팅 버튼 공간 확보 (버튼 높이 + 여백)
                }
            }
            .background(Color.white)
            .overlay(
                // 플로팅 버튼과 그라디언트 배경
                VStack {
                    // 플로팅 버튼들을 네비게이션 바 위로 고정
                    Spacer()
                    
                    // 플로팅 버튼들
                    HStack(spacing: 10) {
                        Button(action: {
                            shiftOffset -= 1
                            hasUnsavedChanges = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.up")
                                    .font(.system(size: 14))
                                Text("하루 당기기")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.charcoalBlack)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(Color.mainColor.opacity(0.8))
                            .cornerRadius(8)
                        }
                        
                        Button(action: {
                            shiftOffset += 1
                            hasUnsavedChanges = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14))
                                Text("하루 밀기")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.charcoalBlack)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(Color.mainColor.opacity(0.8))
                            .cornerRadius(8)
                        }
                        
                        if hasUnsavedChanges {
                            Button(action: {
                                // TODO: 실제 근무 스케줄에 변경사항 저장
                                hasUnsavedChanges = false
                            }) {
                                Text("저장")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 10)
                                    .background(Color.pointColor)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 80) // 네비게이션 바 위로 적당히 올림
                    .background(
                        // 그라디언트 배경 - 가로에 꽉 차게 확장
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0),
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.9),
                                Color.white
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(width: UIScreen.main.bounds.width, height: 120)
                        .offset(y: -20) // 버튼과 겹치도록 위로 이동
                    )
                }
            )
        }
    }
    
    private func getTeamNumber() -> Int {
        let teamString = shiftManager.settings.team
        if teamString.hasSuffix("조") {
            let numberString = String(teamString.dropLast())
            return Int(numberString) ?? 1
        }
        return 1
    }
    

    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: selectedMonth)
    }
    
    private var daysInMonth: [Date] {
        let startOfMonth = calendar.startOfMonth(for: selectedMonth)
        let endOfMonth = calendar.endOfMonth(for: selectedMonth)
        
        var days: [Date] = []
        var currentDate = startOfMonth
        
        while currentDate <= endOfMonth {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
}

struct ShiftTableRow: View {
    let date: Date
    let currentTeam: Int
    let shiftOffset: Int
    @EnvironmentObject var shiftManager: ShiftManager
    
    private let calendar = Calendar.current
    
    var body: some View {
        HStack(spacing: 0) {
            // Date column - 날짜와 요일을 한 줄로 표시
            HStack(spacing: 3) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isToday ? .white : .charcoalBlack)
                
                Text(dayOfWeek)
                    .font(.system(size: 13))
                    .foregroundColor(isToday ? .white : (dayOfWeek == "일" ? .pointColor : dayOfWeek == "토" ? .mainColorDark : .charcoalBlack.opacity(0.6)))
            }
            .frame(width: 60, alignment: .leading)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isToday ? .pointColor : Color.clear)
            )
            
            // Team columns - 조별로 근무가 교대되도록
            ForEach(1...shiftManager.getTeamCount(), id: \.self) { team in
                let shiftType = getShiftTypeForTeam(team: team, date: date)
                let isCurrentTeam = team == currentTeam
                let isTodayColumn = isToday
                let isHighlighted = isCurrentTeam && isTodayColumn
                
                Text(shiftType.rawValue)
                    .font(.system(size: 15, weight: isCurrentTeam ? .bold : .medium))
                    .foregroundColor(getTextColor(for: shiftType, isCurrentTeam: isCurrentTeam))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(getBackgroundColor(isCurrentTeam: isCurrentTeam, isTodayColumn: isTodayColumn, isHighlighted: isHighlighted, shiftType: shiftType))
                    )
            }
        }
        .padding(.vertical, 2)
    }
    
    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    // 근무형태별 텍스트 색상 (내 조도 근무형태별 색상 적용)
    private func getTextColor(for shiftType: ShiftType, isCurrentTeam: Bool) -> Color {
        if isCurrentTeam {
            return shiftManager.getColor(for: shiftType) // 내 조도 근무형태별 색상
        } else {
            return shiftManager.getColor(for: shiftType) // 다른 조도 근무형태별 색상
        }
    }
    
    // 배경색 결정 로직
    private func getBackgroundColor(isCurrentTeam: Bool, isTodayColumn: Bool, isHighlighted: Bool, shiftType: ShiftType) -> Color {
        if isHighlighted {
            // 내 조 + 오늘 날짜 = 해당 근무 형태의 지정색으로 강조
            return shiftManager.getColor(for: shiftType).opacity(0.3)
        } else if isCurrentTeam {
            // 내 조 행 = 연한 강조
            return Color.mainColor.opacity(0.5)
        } else if isTodayColumn {
            // 오늘 날짜 열 = 연한 강조
            return Color.mainColor.opacity(0.1)
        } else {
            // 기본 = 배경 없음
            return Color.clear
        }
    }
    
    // 조별로 근무가 교대되도록 계산 (offset 적용)
    private func getShiftTypeForTeam(team: Int, date: Date) -> ShiftType {
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let teamOffset = (team - 1) * 2 // 각 조는 2일씩 차이
        let adjustedDayOfYear = dayOfYear + shiftOffset // 전체 근무 패턴을 밀고 당김
        
        // 안전한 패턴 가져오기
        var shiftPattern: [ShiftType]
        
        if shiftManager.settings.shiftPatternType == .custom, let customPattern = shiftManager.settings.customPattern {
            // 커스텀 패턴 사용
            shiftPattern = customPattern.dayShifts
            print("Using custom pattern in getShiftTypeForTeam: \(shiftPattern)")
        } else {
            // 기본 패턴 사용
            shiftPattern = shiftManager.settings.shiftPatternType.generatePattern()
            print("Using generated pattern in getShiftTypeForTeam: \(shiftPattern)")
        }
        
        // 패턴이 비어있으면 기본 패턴 사용
        if shiftPattern.isEmpty {
            print("Warning: shiftPattern is empty in getShiftTypeForTeam, using default pattern")
            shiftPattern = [.주간, .야간, .휴무]
        }
        
        // 절대적인 안전장치: 패턴이 여전히 비어있으면 기본값 반환
        guard !shiftPattern.isEmpty else {
            print("Critical Error: shiftPattern is still empty, returning default shift type")
            return .주간
        }
        
        let adjustedDay = (adjustedDayOfYear + teamOffset) % shiftPattern.count
        let positiveIndex = adjustedDay >= 0 ? adjustedDay : shiftPattern.count + adjustedDay
        return shiftPattern[positiveIndex % shiftPattern.count]
    }
}
