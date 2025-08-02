import SwiftUI

struct ShiftTableView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @State private var selectedMonth = Date()
    @State private var hasUnsavedChanges: Bool = false
    @State private var isEditMode: Bool = false
    @State private var selectedDate: Date?
    @State private var selectedTeam: Int?
    @State private var showingShiftEditSheet: Bool = false
    
    private let calendar = Calendar.current
    private let daysInWeek = ["일", "월", "화", "수", "목", "금", "토"]
    
    // shiftOffset을 ShiftManager에서 가져오기
    private var shiftOffset: Int {
        return shiftManager.shiftOffset
    }
    
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
                
                // Table header and content - 통합 스크롤
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Table header
                        HStack(spacing: 0) {
                            Text(NSLocalizedString("date", comment: "Date"))
                                .frame(width: 60, alignment: .leading)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.charcoalBlack)
                            
                            ForEach(1...shiftManager.getTeamCount(), id: \.self) { teamNumber in
                                Text(NSLocalizedString("team_\(teamNumber)", comment: "Team name"))
                                    .frame(width: getTeamColumnWidth(), alignment: .center)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(teamNumber == getTeamNumber() ? .charcoalBlack : .charcoalBlack.opacity(0.6))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(Color.backgroundLight)
                        .frame(minWidth: getTableTotalWidth())
                        
                        // Table content
                        LazyVStack(spacing: 2) {
                            ForEach(daysInMonth, id: \.self) { date in
                                ShiftTableRow(
                                    date: date,
                                    currentTeam: getTeamNumber(),
                                    shiftOffset: shiftOffset,
                                    isEditMode: isEditMode,
                                    teamColumnWidth: getTeamColumnWidth(),
                                    onShiftTap: { team in
                                        selectedDate = date
                                        selectedTeam = team
                                        showingShiftEditSheet = true
                                    }
                                )
                            }
                        }
                        .frame(minWidth: getTableTotalWidth())
                        .padding(.horizontal)
                        .padding(.bottom, 140) // 플로팅 버튼 공간 확보 (버튼 높이 + 여백)
                    }
                }
            }
            .background(Color.white)
            .navigationTitle(NSLocalizedString("tab_team", comment: "Team"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditMode ? NSLocalizedString("done", comment: "Done") : NSLocalizedString("edit", comment: "Edit")) {
                        isEditMode.toggle()
                    }
                }
            }
            .sheet(isPresented: $showingShiftEditSheet) {
                if let selectedDate = selectedDate, let selectedTeam = selectedTeam {
                    TeamShiftEditView(
                        date: selectedDate,
                        team: selectedTeam,
                        currentShiftType: getShiftTypeForTeam(team: selectedTeam, date: selectedDate),
                        onSave: { newShiftType in
                            // 변경사항 저장 로직
                            updateShiftForTeam(date: selectedDate, team: selectedTeam, shiftType: newShiftType)
                            hasUnsavedChanges = true
                        }
                    )
                }
            }
            .overlay(
                // 플로팅 버튼과 그라디언트 배경
                VStack {
                    // 플로팅 버튼들을 네비게이션 바 위로 고정
                    Spacer()
                    
                    // 플로팅 버튼들
                    HStack(spacing: 10) {
                        Button(action: {
                            shiftManager.shiftOffset -= 1
                            hasUnsavedChanges = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.up")
                                    .font(.system(size: 14))
                                Text(NSLocalizedString("shift_up", comment: "Shift up"))
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.charcoalBlack)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(Color.mainColor.opacity(0.8))
                            .cornerRadius(8)
                        }
                        
                        Button(action: {
                            shiftManager.shiftOffset += 1
                            hasUnsavedChanges = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14))
                                Text(NSLocalizedString("shift_down", comment: "Shift down"))
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
                                // ShiftManager의 데이터 저장
                                shiftManager.saveData()
                                hasUnsavedChanges = false
                            }) {
                                Text(NSLocalizedString("save", comment: "Save"))
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
    
    // 월/년 표시를 로컬라이제이션 대응
    private var monthYearString: String {
        let formatter = DateFormatter()
        let language = Locale.current.language.languageCode?.identifier ?? "ko"
        
        if language == "en" {
            formatter.dateFormat = "yyyy. MMM"
        } else {
            formatter.dateFormat = "yyyy년 M월"
        }
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
    
    // 팀별 근무 타입 가져오기 (ShiftTableRow와 동일한 로직)
    private func getShiftTypeForTeam(team: Int, date: Date) -> ShiftType {
        return shiftManager.getShiftTypeForTeam(team: team, date: date, shiftOffset: shiftOffset) ?? .휴무
    }
    
    // 팀별 근무 업데이트
    private func updateShiftForTeam(date: Date, team: Int, shiftType: ShiftType) {
        shiftManager.updateShiftForTeam(date: date, team: team, shiftType: shiftType)
    }
    
    // 팀 컬럼 너비 계산 (최대 5조까지 한 화면에 표시)
    private func getTeamColumnWidth() -> CGFloat {
        let teamCount = shiftManager.getTeamCount()
        let screenWidth = UIScreen.main.bounds.width
        let dateColumnWidth: CGFloat = 60
        let horizontalPadding: CGFloat = 32 // 좌우 패딩
        
        if teamCount <= 5 {
            // 5조 이하: 화면에 맞춰 균등 분할 (스크롤 없음)
            return (screenWidth - dateColumnWidth - horizontalPadding) / CGFloat(teamCount)
        } else {
            // 6조 이상: 고정 너비 (스크롤 가능)
            // 5조까지는 화면에 맞춰 표시하고, 나머지는 고정 너비
            let availableWidth = screenWidth - dateColumnWidth - horizontalPadding
            let widthFor5Teams = availableWidth / 5.0
            return widthFor5Teams
        }
    }
    
    // 테이블 전체 너비 계산
    private func getTableTotalWidth() -> CGFloat {
        let teamCount = shiftManager.getTeamCount()
        let screenWidth = UIScreen.main.bounds.width
        let dateColumnWidth: CGFloat = 60
        let horizontalPadding: CGFloat = 32
        
        if teamCount <= 5 {
            // 5조 이하: 화면 너비에 맞춤 (스크롤 없음)
            return screenWidth - horizontalPadding
        } else {
            // 6조 이상: 실제 테이블 너비 (스크롤 필요)
            let teamColumnWidth = getTeamColumnWidth()
            return dateColumnWidth + (teamColumnWidth * CGFloat(teamCount))
        }
    }
}

struct ShiftTableRow: View {
    let date: Date
    let currentTeam: Int
    let shiftOffset: Int
    let isEditMode: Bool
    let teamColumnWidth: CGFloat
    let onShiftTap: (Int) -> Void
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
                    .frame(width: teamColumnWidth, alignment: .center)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(getBackgroundColor(isCurrentTeam: isCurrentTeam, isTodayColumn: isTodayColumn, isHighlighted: isHighlighted, shiftType: shiftType))
                    )
                    .onTapGesture {
                        if isEditMode {
                            onShiftTap(team)
                        }
                    }
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
        return shiftManager.getShiftTypeForTeam(team: team, date: date, shiftOffset: shiftOffset) ?? .휴무
    }
}

// MARK: - Team Shift Edit View
struct TeamShiftEditView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    
    let date: Date
    let team: Int
    let currentShiftType: ShiftType
    let onSave: (ShiftType) -> Void
    
    @State private var selectedShiftType: ShiftType
    
    init(date: Date, team: Int, currentShiftType: ShiftType, onSave: @escaping (ShiftType) -> Void) {
        self.date = date
        self.team = team
        self.currentShiftType = currentShiftType
        self.onSave = onSave
        self._selectedShiftType = State(initialValue: currentShiftType)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                VStack(spacing: 15) {
                    Text(dateString)
                        .font(.headline)
                        .foregroundColor(.charcoalBlack.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("\(team)조 근무 수정")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoalBlack)
                }
                
                VStack(spacing: 15) {
                    Text("근무 유형 선택")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.charcoalBlack)
                    
                    // 근무 유형 선택
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(ShiftType.allCases, id: \.self) { shiftType in
                            Button(action: {
                                selectedShiftType = shiftType
                            }) {
                                HStack {
                                    Circle()
                                        .fill(shiftType.color)
                                        .frame(width: 20, height: 20)
                                    
                                    Text(shiftType.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.charcoalBlack)
                                    
                                    Spacer()
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedShiftType == shiftType ? Color(hex: "1A1A1A") : Color.clear, lineWidth: 2)
                                )
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                Spacer()
                
                // 저장 버튼
                Button("저장") {
                    onSave(selectedShiftType)
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(selectedShiftType == currentShiftType)
            }
            .padding()
            .background(Color.backgroundLight)
            .navigationTitle("근무 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}
