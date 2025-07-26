import SwiftUI
import WidgetKit

struct SettingsView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @State private var showingPatternSelection = false
    @State private var showingTeamSelection = false
    @State private var showingSalarySetup = false
    @State private var showingColorPicker = false
    @State private var selectedShiftType: ShiftType?
    @State private var showingCustomPatternEdit = false
    @State private var showingDataExport = false
    @State private var showingDataReset = false
    @State private var showingCustomPatternView = false

    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 35) {
                        // 근무 설정 섹션
                        VStack(alignment: .leading, spacing: 8) {
                            // 섹션 헤더
                    HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundColor(Color(hex: "1A1A1A"))
                                    .font(.title3)
                                Text("근무 설정")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.charcoalBlack)
                            }
                            
                            // 근무 패턴 카드
                            Button(action: { showingPatternSelection = true }) {
                                HStack {
                                    Image(systemName: "repeat.circle")
                                        .foregroundColor(Color(hex: "1A1A1A"))
                                        .font(.title3)
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                        Text("근무 패턴")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.charcoalBlack)
                        Text(shiftManager.settings.shiftPatternType.displayName)
                                            .font(.caption)
                                            .foregroundColor(.charcoalBlack.opacity(0.7))
                    }
                    
                        Spacer()
                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.charcoalBlack.opacity(0.5))
                    }
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
                            .buttonStyle(PlainButtonStyle())
                
                            // 소속 팀 카드
                            Button(action: { showingTeamSelection = true }) {
                        HStack {
                                    Image(systemName: "person.2")
                                        .foregroundColor(Color(hex: "1A1A1A"))
                                        .font(.title3)
                                        .frame(width: 20)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("소속 팀")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.charcoalBlack)
                                        Text(shiftManager.settings.team)
                                            .font(.caption)
                                            .foregroundColor(.charcoalBlack.opacity(0.7))
                                    }
                            
                            Spacer()
                            
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.charcoalBlack.opacity(0.5))
                                }
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // 커스텀 패턴 편집 버튼 (커스텀 패턴일 때만)
                            if shiftManager.settings.shiftPatternType == .custom {
                                Button(action: { showingCustomPatternEdit = true }) {
                    HStack {
                                        Image(systemName: "pencil.circle")
                                            .foregroundColor(Color(hex: "1A1A1A"))
                                            .font(.title3)
                                            .frame(width: 24)
                                        
                                        Text("커스텀 패턴 편집")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(Color(hex: "1A1A1A"))
                                        
                        Spacer()
                                    }
                                    .padding(20)
                                    .background(Color(hex: "C7D6DB"))
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        // 근무요소 수정 섹션 (커스텀 패턴이 아닐 때만)
                        if shiftManager.settings.shiftPatternType != .custom {
                            VStack(alignment: .leading, spacing: 8) {
                                // 섹션 헤더
                    HStack {
                                    Image(systemName: "paintbrush")
                                        .foregroundColor(Color(hex: "1A1A1A"))
                                        .font(.title3)
                                    Text("근무요소 수정")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.charcoalBlack)
                                }
                                
                                // 근무 유형별 카드 (현재 패턴에 해당하는 것만)
                                ForEach(shiftManager.getShiftTypesForCurrentPattern(), id: \.self) { shiftType in
                                    Button(action: {
                                        selectedShiftType = shiftType
                                        showingColorPicker = true
                                    }) {
                    HStack {
                                            Circle()
                                                .fill(shiftManager.getColor(for: shiftType))
                                                .frame(width: 24, height: 24)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white, lineWidth: 2)
                                                )
                                                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                                            
                                            Text(shiftManager.getShiftName(for: shiftType))
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.charcoalBlack)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(.charcoalBlack.opacity(0.5))
                                        }
                                        .padding(20)
                                        .background(Color.white)
                                        .cornerRadius(16)
                                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                        // 급여 정보 섹션
                        VStack(alignment: .leading, spacing: 8) {
                            // 섹션 헤더
                            HStack {
                                Image(systemName: "dollarsign.circle")
                                    .foregroundColor(Color(hex: "1A1A1A"))
                                    .font(.title3)
                                Text("급여 정보")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.charcoalBlack)
                            }
                            
                            // 급여 정보 카드
                            VStack(spacing: 8) {
                                SalaryInfoRow(
                                    icon: "creditcard",
                                    title: "기본급",
                                    value: shiftManager.settings.baseSalary > 0 ? "\(Int(shiftManager.settings.baseSalary))원" : "설정 안됨",
                                    isHighlighted: false
                                )
                                
                                SalaryInfoRow(
                                    icon: "moon",
                                    title: "야간 근무 수당",
                                    value: "\(String(format: "%.1f", shiftManager.settings.nightShiftRate))배",
                                    isHighlighted: true
                                )
                                
                                SalaryInfoRow(
                                    icon: "moon.stars",
                                    title: "심야 근무 수당",
                                    value: "\(String(format: "%.1f", shiftManager.settings.deepNightShiftRate))배",
                                    isHighlighted: true
                                )
                                
                                SalaryInfoRow(
                                    icon: "clock.arrow.circlepath",
                                    title: "초과근무 배율",
                                    value: "\(String(format: "%.1f", shiftManager.settings.overtimeRate))배",
                                    isHighlighted: false
                                )
                                
                                SalaryInfoRow(
                                    icon: "calendar.badge.plus",
                                    title: "휴일 근무 수당",
                                    value: "\(String(format: "%.1f", shiftManager.settings.holidayWorkRate))배",
                                    isHighlighted: false
                                )
                                
                                SalaryInfoRow(
                                    icon: "airplane",
                                    title: "연간 휴가 일수",
                                    value: "\(shiftManager.settings.annualVacationDays)일",
                                    isHighlighted: false
                                )
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            
                            // 급여 정보 수정 버튼
                            Button(action: { showingSalarySetup = true }) {
                                HStack {
                                    Image(systemName: "pencil.circle")
                                        .foregroundColor(Color(hex: "1A1A1A"))
                                        .font(.title3)
                                        .frame(width: 24)
                                    
                                    Text("급여 정보 수정")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(Color(hex: "1A1A1A"))
                                    
                                    Spacer()
                                }
                                .padding(20)
                                .background(Color(hex: "C7D6DB"))
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // 기타 섹션
                        VStack(alignment: .leading, spacing: 8) {
                            // 섹션 헤더
                            HStack {
                                Image(systemName: "ellipsis.circle")
                                    .foregroundColor(Color(hex: "1A1A1A"))
                                    .font(.title3)
                                Text("기타")
                                    .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoalBlack)
                            }
                            

                            
                            // 근무표 공유하기 카드
                            Button(action: { shareSchedule() }) {
                        HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .foregroundColor(Color(hex: "1A1A1A"))
                                        .font(.title3)
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("근무표 공유하기")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.charcoalBlack)
                                        Text("근무표를 링크로 공유")
                                    .font(.caption)
                                    .foregroundColor(.charcoalBlack.opacity(0.7))
                            }
                            
                            Spacer()
                            
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.charcoalBlack.opacity(0.5))
                                }
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    .buttonStyle(PlainButtonStyle())
                            
                            // 위젯 새로고침 카드
                            Button(action: {
                                print("🔄 Widget refresh button tapped")
                                
                                // 데이터 강제 저장
                                shiftManager.saveData()
                                print("✅ Data saved via widget refresh button")
                                
                                // App Group UserDefaults 동기화 강제
                                let appGroupDefaults = UserDefaults(suiteName: "group.com.chaeeun.ShiftCalendarApp")!
                                appGroupDefaults.synchronize()
                                
                                // 일반 UserDefaults 동기화 강제
                                UserDefaults.standard.synchronize()
                                
                                // 위젯 타임라인 새로고침 (여러 번 호출)
                                WidgetCenter.shared.reloadAllTimelines()
                                print("✅ WidgetCenter.reloadAllTimelines() called")
                                
                                // 지연 후 다시 새로고침
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    WidgetCenter.shared.reloadAllTimelines()
                                    print("✅ Delayed widget refresh completed")
                                }
                                
                                // 추가로 백그라운드에서도 새로고침
                                DispatchQueue.global(qos: .background).async {
                                    WidgetCenter.shared.reloadAllTimelines()
                                    print("✅ Background widget refresh completed")
                                    
                                    // 백그라운드에서도 지연 후 다시 시도
                                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1.0) {
                                        WidgetCenter.shared.reloadAllTimelines()
                                        print("✅ Background delayed widget refresh completed")
                                    }
                                }
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise.circle")
                                        .foregroundColor(Color(hex: "1A1A1A"))
                                        .font(.title3)
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("위젯 새로고침")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                    .foregroundColor(.charcoalBlack)
                                        Text("위젯 업데이트")
                                            .font(.caption)
                                            .foregroundColor(.charcoalBlack.opacity(0.7))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.charcoalBlack.opacity(0.5))
                                }
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            
                            
                            // 데이터 초기화 카드
                            Button(action: { showingDataReset = true }) {
                HStack {
                                    Image(systemName: "trash.circle")
                                        .foregroundColor(.red)
                            .font(.title3)
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("데이터 초기화")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.charcoalBlack)
                                        Text("모든 데이터 삭제")
                            .font(.caption)
                            .foregroundColor(.charcoalBlack.opacity(0.7))
                    }
                    
                    Spacer()
                    
                                    Image(systemName: "chevron.right")
                        .font(.caption)
                                        .foregroundColor(.charcoalBlack.opacity(0.5))
                                }
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .padding(.bottom, 80) // 네비게이션 바 높이만큼 여백
                }
            }
            .background(Color(hex: "EFF0F2"))
            .navigationBarHidden(true)
        }
                    .sheet(isPresented: $showingPatternSelection) {
                ShiftPatternSelectionSheet(shiftManager: shiftManager, showingCustomPatternEdit: $showingCustomPatternEdit)
            }
        .sheet(isPresented: $showingTeamSelection) {
            TeamSelectionSheet()
        }
        .sheet(isPresented: $showingSalarySetup) {
            SalarySetupView()
        }
        .sheet(isPresented: $showingColorPicker) {
            if let shiftType = selectedShiftType {
                ColorPickerView(shiftType: shiftType, shiftManager: shiftManager)
            }
        }
        .sheet(isPresented: $showingCustomPatternEdit) {
            CustomPatternEditView()
        }
        .sheet(isPresented: $showingDataExport) {
            DataExportView()
        }
        .sheet(isPresented: $showingDataReset) {
            DataResetView()
        }
        .sheet(isPresented: $showingCustomPatternView) {
            CustomPatternEditView()
        }


    }
    
    // MARK: - Share Schedule Function
    private func shareSchedule() {
        // 근무표 데이터를 딥링크 URL로 인코딩
        let scheduleData = createScheduleShareData()
        
        // 딥링크 URL 생성
        let deepLinkURL = "letsshift://schedule?data=\(scheduleData)"
        
        // 공유할 텍스트 생성
        let shareText = """
        📅 Shift Calendar App - 근무표 공유
        
        내 근무표를 확인해보세요!
        
        \(deepLinkURL)
        
        앱이 설치되어 있지 않다면 App Store에서 다운로드하세요.
        """
        
        // UIActivityViewController를 통해 공유
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        // iPad에서 팝오버로 표시하기 위한 설정
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
        }
        
        // 현재 뷰에서 공유 시트 표시
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
    
    private func createScheduleShareData() -> String {
        // 핵심 설정만 공유 (스케줄 제외)
        var shareData: [String: Any] = [
            "patternType": shiftManager.settings.shiftPatternType.rawValue,
            "team": shiftManager.settings.team
        ]
        
        // 커스텀 패턴이 있는 경우만 추가
        if let customPattern = shiftManager.settings.customPattern {
            shareData["customPattern"] = customPattern.toDictionary()
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: shareData)
            return jsonData.base64EncodedString()
        } catch {
            print("Error encoding schedule data: \(error)")
            return ""
        }
    }
}

// MARK: - Salary Info Row
struct SalaryInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let isHighlighted: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isHighlighted ? .pointColor : .mainColor)
                .font(.title3)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                    .foregroundColor(.charcoalBlack)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isHighlighted ? .pointColor : .charcoalBlack)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isHighlighted ? Color.pointColor.opacity(0.1) : Color.mainColor.opacity(0.1))
                .cornerRadius(6)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

// MARK: - Shift Pattern Selection Sheet
struct ShiftPatternSelectionSheet: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedPattern: ShiftPatternType
    @State private var selectedTeam: String
    @State private var currentStep: SelectionStep = .pattern
    @Binding var showingCustomPatternEdit: Bool
    
    enum SelectionStep {
        case pattern
        case team
    }
    
    init(shiftManager: ShiftManager, showingCustomPatternEdit: Binding<Bool>) {
        _selectedPattern = State(initialValue: shiftManager.settings.shiftPatternType)
        _selectedTeam = State(initialValue: shiftManager.settings.team)
        _showingCustomPatternEdit = showingCustomPatternEdit
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 15) {
                    Text(currentStep == .pattern ? "근무 패턴 선택" : "소속 팀 선택")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoalBlack)
                    
                    Text(currentStep == .pattern ? "적용할 근무 패턴을 선택하세요" : "소속 팀을 선택하세요")
                        .font(.subheadline)
                        .foregroundColor(.charcoalBlack.opacity(0.7))
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                if currentStep == .pattern {
                    // Pattern options
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(ShiftPatternType.allCases.filter { $0 != .none }, id: \.self) { pattern in
                                PatternOptionCard(
                                    pattern: pattern,
                                    isSelected: selectedPattern == pattern
                                ) {
                                    selectedPattern = pattern
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    // Next button
                    Button(action: nextToTeamSelection) {
                        Text("다음")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.charcoalBlack)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                } else {
                    // Team selection
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(1...getTeamCount(), id: \.self) { teamNumber in
                                TeamOptionCard(
                                    teamNumber: teamNumber,
                                    isSelected: selectedTeam == "\(teamNumber)조"
                                ) {
                                    selectedTeam = "\(teamNumber)조"
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: applySettings) {
                            Text("적용")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.charcoalBlack)
                                .cornerRadius(12)
                        }
                        
                        Button(action: backToPatternSelection) {
                            Text("이전")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.charcoalBlack)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.charcoalBlack, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .background(Color(hex: "EFF0F2"))
            .navigationBarHidden(true)
        }
    }
    
    private func getTeamCount() -> Int {
        switch selectedPattern {
        case .none: return 0
        case .twoShift:
            return 2
        case .threeShift:
            return 3
        case .threeTeamTwoShift:
            return 3
        case .fourTeamTwoShift:
            return 4
        case .fourTeamThreeShift:
            return 4
        case .fiveTeamThreeShift:
            return 5
        case .irregular:
            return 6
        case .custom:
            return 4 // 기본값
        }
    }
    
    private func nextToTeamSelection() {
        if selectedPattern == .custom {
            // 커스텀 패턴인 경우 커스텀 패턴 설정 페이지로 이동
            showingCustomPatternEdit = true
            dismiss()
        } else {
        currentStep = .team
        }
    }
    
    private func backToPatternSelection() {
        currentStep = .pattern
    }
    

    
    private func applySettings() {
        shiftManager.settings.shiftPatternType = selectedPattern
        shiftManager.settings.team = selectedTeam
        shiftManager.regenerateSchedule()
        shiftManager.saveData()
        dismiss()
    }
}

// MARK: - Team Selection Sheet
struct TeamSelectionSheet: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedTeam: String
    
    init() {
        _selectedTeam = State(initialValue: ShiftManager.shared.settings.team)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 15) {
                    Text("소속 팀 선택")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoalBlack)
                    
                    Text("소속 팀을 선택하세요")
                        .font(.subheadline)
                        .foregroundColor(.charcoalBlack.opacity(0.7))
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Team options
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(1...getTeamCount(), id: \.self) { teamNumber in
                            TeamOptionCard(
                                teamNumber: teamNumber,
                                isSelected: selectedTeam == "\(teamNumber)조"
                            ) {
                                selectedTeam = "\(teamNumber)조"
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Apply button
                Button(action: applyTeam) {
                    Text("적용")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.charcoalBlack)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(hex: "EFF0F2"))
            .navigationBarHidden(true)
        }
    }
    
    private func getTeamCount() -> Int {
        switch shiftManager.settings.shiftPatternType {
        case .none: return 0
        case .twoShift:
            return 2
        case .threeShift:
            return 3
        case .threeTeamTwoShift:
            return 3
        case .fourTeamTwoShift:
            return 4
        case .fourTeamThreeShift:
            return 4
        case .fiveTeamThreeShift:
            return 5
        case .irregular:
            return 6
        case .custom:
            return 4 // 기본값
        }
    }
    
    private func applyTeam() {
        shiftManager.settings.team = selectedTeam
        shiftManager.regenerateSchedule()
        shiftManager.saveData()
        dismiss()
    }
}

// MARK: - Pattern Option Card
struct PatternOptionCard: View {
    let pattern: ShiftPatternType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pattern.displayName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.charcoalBlack)
                        
                        Text(pattern.description)
                            .font(.subheadline)
                            .foregroundColor(.charcoalBlack.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.pointColor)
                    }
                }
                
                // Pattern preview
                HStack(spacing: 8) {
                    ForEach(pattern.generatePattern(), id: \.self) { shiftType in
                        Text(shiftType.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(shiftType.color)
                            .cornerRadius(6)
                    }
                }
            }
            .padding(16)
            .background(isSelected ? Color.mainColor.opacity(0.3) : Color.backgroundWhite)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.pointColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Team Option Card
struct TeamOptionCard: View {
    let teamNumber: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(teamNumber)조")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.charcoalBlack)
                    
                    Text("소속 팀")
                        .font(.subheadline)
                        .foregroundColor(.charcoalBlack.opacity(0.7))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.pointColor)
                }
            }
            .padding(16)
            .background(isSelected ? Color.mainColor.opacity(0.3) : Color.backgroundWhite)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.pointColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Salary Setup View
struct SalarySetupView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    
    @State private var baseSalary = ""
    @State private var nightShiftRate = ""
    @State private var deepNightShiftRate = ""
    @State private var overtimeRate = ""
    @State private var holidayWorkRate = ""
    @State private var annualVacationDays = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 25) {
                        // 기본 급여 섹션
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "dollarsign.circle")
                                    .foregroundColor(Color(hex: "1A1A1A"))
                                    .font(.title3)
                                Text("기본 급여")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.charcoalBlack)
                            }
                            
                            VStack(spacing: 12) {
                                SalaryInputField(
                                    title: "기본급 (원)",
                                    value: $baseSalary,
                                    placeholder: "예: 3000000"
                                )
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                        
                        // 근무 수당 섹션
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                    .foregroundColor(Color(hex: "1A1A1A"))
                                    .font(.title3)
                                Text("근무 수당")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.charcoalBlack)
                            }
                            
                            VStack(spacing: 12) {
                                SalaryInputField(
                                    title: "야간 근무 수당 (배율)",
                                    value: $nightShiftRate,
                                    placeholder: "예: 1.5"
                                )
                                
                                SalaryInputField(
                                    title: "심야 근무 수당 (배율)",
                                    value: $deepNightShiftRate,
                                    placeholder: "예: 2.0"
                                )
                                
                                SalaryInputField(
                                    title: "초과근무 배율",
                                    value: $overtimeRate,
                                    placeholder: "예: 1.5"
                                )
                                
                                SalaryInputField(
                                    title: "휴일 근무 수당 (배율)",
                                    value: $holidayWorkRate,
                                    placeholder: "예: 1.5"
                                )
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                        
                        // 휴가 정보 섹션
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                    .foregroundColor(Color(hex: "1A1A1A"))
                                    .font(.title3)
                                Text("휴가 정보")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.charcoalBlack)
                            }
                            
                            VStack(spacing: 12) {
                                SalaryInputField(
                                    title: "연간 휴가 일수",
                                    value: $annualVacationDays,
                                    placeholder: "예: 15"
                                )
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .padding(.bottom, 100)
                }
            }
            .background(Color(hex: "EFF0F2"))
            .navigationTitle("급여 정보")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveSalaryInfo()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadCurrentValues()
        }
    }
    
    private func loadCurrentValues() {
        baseSalary = shiftManager.settings.baseSalary > 0 ? "\(Int(shiftManager.settings.baseSalary))" : ""
        nightShiftRate = "\(shiftManager.settings.nightShiftRate)"
        deepNightShiftRate = "\(shiftManager.settings.deepNightShiftRate)"
        overtimeRate = "\(shiftManager.settings.overtimeRate)"
        holidayWorkRate = "\(shiftManager.settings.holidayWorkRate)"
        annualVacationDays = "\(shiftManager.settings.annualVacationDays)"
    }
    
    private func saveSalaryInfo() {
        shiftManager.settings.baseSalary = Double(baseSalary) ?? 0
        shiftManager.settings.nightShiftRate = Double(nightShiftRate) ?? 1.5
        shiftManager.settings.deepNightShiftRate = Double(deepNightShiftRate) ?? 2.0
        shiftManager.settings.overtimeRate = Double(overtimeRate) ?? 1.5
        shiftManager.settings.holidayWorkRate = Double(holidayWorkRate) ?? 1.5
        shiftManager.settings.annualVacationDays = Int(annualVacationDays) ?? 15
        shiftManager.saveData()
    }
}

// MARK: - Salary Input Field
struct SalaryInputField: View {
    let title: String
    @Binding var value: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.charcoalBlack)
            
            TextField(placeholder, text: $value)
                .font(.subheadline)
                .foregroundColor(.charcoalBlack)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(hex: "F8F9FA"))
                .cornerRadius(12)
                .keyboardType(.decimalPad)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "E9ECEF"), lineWidth: 1)
                )
        }
    }
}



// MARK: - Custom Pattern Edit View
struct CustomPatternEditView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    
    @State private var cycleLength: Int = 3
    @State private var startDate = Date()
    @State private var dayShifts: [ShiftType?] = []
    @State private var showingShiftTypePicker = false
    @State private var selectedDayIndex: Int = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 25) {
                        // 반복주기 설정
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "repeat.circle")
                                    .foregroundColor(Color(hex: "1A1A1A"))
                                    .font(.title3)
                                Text("반복주기 설정")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.charcoalBlack)
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("반복주기 (일)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.charcoalBlack)
                                
                                HStack {
                                    Button(action: { if cycleLength > 2 { cycleLength -= 1 } }) {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(cycleLength > 2 ? Color(hex: "1A1A1A") : .gray)
                                    }
                                    .disabled(cycleLength <= 2)
                                    
                                    Spacer()
                                    
                                    Text("\(cycleLength)일")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.charcoalBlack)
                                        .frame(minWidth: 60)
                                    
                                    Spacer()
                                    
                                    Button(action: { if cycleLength < 7 { cycleLength += 1 } }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(cycleLength < 7 ? Color(hex: "1A1A1A") : .gray)
                                    }
                                    .disabled(cycleLength >= 7)
                                }
                                .padding(.horizontal, 20)
                                
                                Text("2일 ~ 7일 사이에서 선택하세요")
                                    .font(.caption)
                                    .foregroundColor(.charcoalBlack.opacity(0.7))
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                        
                        // 시작일 설정
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(Color(hex: "1A1A1A"))
                                    .font(.title3)
                                Text("시작일 설정")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.charcoalBlack)
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("패턴 시작일")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.charcoalBlack)
                                
                                DatePicker("시작일", selection: $startDate, displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .labelsHidden()
                                    .padding(.horizontal, 20)
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                        
                        // 일차별 근무 요소 설정
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "list.bullet")
                                    .foregroundColor(Color(hex: "1A1A1A"))
                                    .font(.title3)
                                Text("일차별 근무 요소")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.charcoalBlack)
                            }
                            
                            VStack(spacing: 12) {
                                ForEach(0..<cycleLength, id: \.self) { dayIndex in
                                    Button(action: {
                                        selectedDayIndex = dayIndex
                                        showingShiftTypePicker = true
                                    }) {
                                        HStack {
                                            Text("\(dayIndex + 1)일차")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.charcoalBlack)
                                            
                                            Spacer()
                                            
                                            if dayIndex < dayShifts.count, let shiftType = dayShifts[dayIndex] {
                                                HStack(spacing: 8) {
                                                    Circle()
                                                        .fill(shiftType.color)
                                                        .frame(width: 16, height: 16)
                                                    
                                                    Text(shiftType.rawValue)
                                                        .font(.subheadline)
                                                        .fontWeight(.medium)
                                                        .foregroundColor(.charcoalBlack)
                                                    
                                                    Image(systemName: "chevron.right")
                                                        .font(.caption)
                                                        .foregroundColor(.charcoalBlack.opacity(0.5))
                                                }
                                            } else {
                                                HStack(spacing: 8) {
                                                    Text("근무 요소를 추가해주세요")
                                                        .font(.subheadline)
                                                        .foregroundColor(.charcoalBlack.opacity(0.5))
                                                    
                                                    Image(systemName: "chevron.right")
                                                        .font(.caption)
                                                        .foregroundColor(.charcoalBlack.opacity(0.5))
                                                }
                                            }
                                        }
                                        .padding(16)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .padding(.bottom, 100)
                }
            }
            .background(Color(hex: "EFF0F2"))
            .navigationTitle("커스텀 패턴 편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveCustomPattern()
                        dismiss()
                    }
                    .disabled(!isPatternValid)
                }
            }
        }
        .sheet(isPresented: $showingShiftTypePicker) {
            ShiftTypePickerView(
                selectedShiftType: Binding(
                    get: { 
                        guard selectedDayIndex < dayShifts.count else { return nil }
                        return dayShifts[selectedDayIndex] 
                    },
                    set: { newValue in
                        guard selectedDayIndex < dayShifts.count else { return }
                        dayShifts[selectedDayIndex] = newValue
                    }
                )
            )
        }
        .onAppear {
            loadCurrentPattern()
        }
        .onChange(of: cycleLength) { _, _ in
            updateDayShiftsArray()
        }
    }
    
    private var isPatternValid: Bool {
        return dayShifts.count == cycleLength && dayShifts.allSatisfy { $0 != nil }
    }
    
    private func loadCurrentPattern() {
        if let customPattern = shiftManager.settings.customPattern {
            cycleLength = customPattern.cycleLength
            startDate = customPattern.startDate
            // 기존 dayShifts를 새로운 cycleLength에 맞게 조정
            var newDayShifts: [ShiftType?] = Array(repeating: nil, count: cycleLength)
            for (index, shiftType) in customPattern.dayShifts.enumerated() {
                if index < cycleLength {
                    newDayShifts[index] = shiftType
                }
            }
            dayShifts = newDayShifts
        } else {
            updateDayShiftsArray()
        }
    }
    
    private func updateDayShiftsArray() {
        if dayShifts.count != cycleLength {
            var newDayShifts: [ShiftType?] = Array(repeating: nil, count: cycleLength)
            // 기존 데이터를 보존하면서 배열 크기 조정
            for (index, shiftType) in dayShifts.enumerated() {
                if index < cycleLength {
                    newDayShifts[index] = shiftType
                }
            }
            dayShifts = newDayShifts
        }
    }
    
    private func saveCustomPattern() {
        // 유효성 검사
        guard cycleLength >= 2 && cycleLength <= 7 else { return }
        guard dayShifts.count == cycleLength else { return }
        
        // nil이 아닌 근무 요소들만 필터링
        let validDayShifts = dayShifts.compactMap { $0 }
        guard validDayShifts.count == cycleLength else { return }
        
        print("=== CustomPatternEditView saveCustomPattern ===")
        print("Cycle Length: \(cycleLength)")
        print("Start Date: \(startDate)")
        print("Valid Day Shifts: \(validDayShifts)")
        print("Day Shifts Count: \(validDayShifts.count)")
        
        let customPattern = CustomShiftPattern(
            cycleLength: cycleLength,
            startDate: startDate,
            dayShifts: validDayShifts
        )
        
        print("Created Custom Pattern:")
        print("- Name: \(customPattern.name)")
        print("- Start Date: \(customPattern.startDate)")
        print("- Day Shifts: \(customPattern.dayShifts)")
        print("- Cycle Length: \(customPattern.cycleLength)")
        
        shiftManager.settings.customPattern = customPattern
        shiftManager.settings.shiftPatternType = .custom
        shiftManager.settings.team = "1조" // 커스텀 패턴은 항상 1팀
        shiftManager.regenerateSchedule()
        shiftManager.saveData()
        
        // 온보딩 완료 처리
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        print("Onboarding completed - hasCompletedOnboarding set to true")
    }
}

// MARK: - Shift Type Picker View
struct ShiftTypePickerView: View {
    @Binding var selectedShiftType: ShiftType?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(ShiftType.allCases, id: \.self) { shiftType in
                        Button(action: {
                            selectedShiftType = shiftType
                            dismiss()
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
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .background(Color(hex: "EFF0F2"))
            .navigationTitle("근무 요소 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Data Export View
struct DataExportView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("데이터 내보내기")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoalBlack)
                
                Text("데이터 내보내기 기능이 여기에 구현됩니다.")
                    .font(.subheadline)
                    .foregroundColor(.charcoalBlack.opacity(0.7))
                
                Spacer()
            }
            .background(Color(hex: "EFF0F2"))
            .navigationTitle("데이터 내보내기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Data Reset View
struct DataResetView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("모든 데이터가 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.")
                    .font(.subheadline)
                    .foregroundColor(.charcoalBlack.opacity(0.7))
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 12) {
                    Button(action: {
                        shiftManager.resetAllData()
                        dismiss()
                    }) {
                        Text("초기화")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "1A1A1A"))
                            .cornerRadius(12)
                    }
                    
                    Button(action: { dismiss() }) {
                        Text("취소")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.charcoalBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.charcoalBlack, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .background(Color(hex: "EFF0F2"))
            .navigationTitle("데이터 초기화")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

