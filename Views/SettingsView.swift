import SwiftUI
import WidgetKit

struct SettingsView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @State private var showingPatternSelection = false
    @State private var showingTeamSelection = false
    @State private var showingSalarySetup = false
    @State private var showingColorPicker = false
    @State private var selectedShiftType: ShiftType?
    @State private var colorPickerItem: ShiftType?
    @State private var showingCustomPatternEdit = false
    @State private var showingDataExport = false
    @State private var showingDataReset = false
    @State private var showingCustomPatternView = false
    @State private var isWidgetRefreshing = false

    
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
                                Text(NSLocalizedString("work_settings", comment: "Work settings"))
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
                        Text(NSLocalizedString("work_pattern", comment: "Work pattern"))
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
                                        Text(NSLocalizedString("team", comment: "Team"))
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
                                        
                                        Text(NSLocalizedString("custom_pattern_edit", comment: "Edit custom pattern"))
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
                                    Text(NSLocalizedString("edit_shifts", comment: "Edit shifts"))
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.charcoalBlack)
                                }
                                
                                // 근무 유형별 카드 (현재 패턴에 해당하는 것만)
                                ForEach(shiftManager.getShiftTypesForCurrentPattern(), id: \.self) { shiftType in
                                    Button(action: {
                                        print("🔧 SettingsView: Button tapped for shiftType: \(shiftType)")
                                        colorPickerItem = shiftType
                                        print("🔧 SettingsView: colorPickerItem set to: \(colorPickerItem?.rawValue ?? "nil")")
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
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(shiftManager.getShiftName(for: shiftType))
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.charcoalBlack)
                                                
                                                Text(shiftManager.getShiftTimeRange(for: shiftType))
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
                        }
                        
                        // 급여 정보 섹션
                        VStack(alignment: .leading, spacing: 8) {
                            // 섹션 헤더
                            HStack {
                                Image(systemName: "dollarsign.circle")
                                    .foregroundColor(Color(hex: "1A1A1A"))
                                    .font(.title3)
                                Text(NSLocalizedString("salary_info", comment: "Salary info"))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.charcoalBlack)
                            }
                            
                            // 급여 정보 카드
                            VStack(spacing: 8) {
                                SalaryInfoRow(
                                    icon: "creditcard",
                                    title: NSLocalizedString("base_salary", comment: "Base salary"),
                                    value: shiftManager.settings.baseSalary > 0 ? "\(Int(shiftManager.settings.baseSalary))\(NSLocalizedString("won_currency", comment: "Won currency"))" : NSLocalizedString("not_set", comment: "Not set"),
                                    isHighlighted: false
                                )
                                
                                SalaryInfoRow(
                                    icon: "moon",
                                    title: NSLocalizedString("night_allowance", comment: "Night allowance"),
                                    value: "\(String(format: "%.1f", shiftManager.settings.nightShiftRate))x",
                                    isHighlighted: true
                                )
                                
                                SalaryInfoRow(
                                    icon: "moon.stars",
                                    title: NSLocalizedString("deep_night_allowance", comment: "Deep night allowance"),
                                    value: "\(String(format: "%.1f", shiftManager.settings.deepNightShiftRate))x",
                                    isHighlighted: true
                                )
                                
                                SalaryInfoRow(
                                    icon: "clock.arrow.circlepath",
                                    title: NSLocalizedString("overtime_rate", comment: "Overtime rate"),
                                    value: "\(String(format: "%.1f", shiftManager.settings.overtimeRate))x",
                                    isHighlighted: false
                                )
                                
                                SalaryInfoRow(
                                    icon: "calendar.badge.plus",
                                    title: NSLocalizedString("holiday_allowance", comment: "Holiday allowance"),
                                    value: "\(String(format: "%.1f", shiftManager.settings.holidayWorkRate))x",
                                    isHighlighted: false
                                )
                                
                                SalaryInfoRow(
                                    icon: "airplane",
                                    title: NSLocalizedString("annual_leave_days", comment: "Annual leave days"),
                                    value: "\(shiftManager.settings.annualVacationDays)D",
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
                                    
                                    Text(NSLocalizedString("edit_salary_info", comment: "Edit salary info"))
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
                                Text(NSLocalizedString("other", comment: "Other"))
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
                                        Text(NSLocalizedString("share_schedule", comment: "Share schedule"))
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.charcoalBlack)
                                        Text(NSLocalizedString("share_schedule_description", comment: "Share schedule description"))
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
                                
                                // 새로고침 상태 시작
                                isWidgetRefreshing = true
                                
                                // 데이터 강제 저장
                                shiftManager.saveData()
                                print("✅ Data saved via widget refresh button")
                                
                                // App Group UserDefaults 동기화 강제
                                let appGroupDefaults = UserDefaults(suiteName: "group.com.chaeeun.gyodaehaja")!
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
                                
                                // 5초 후 상태 초기화
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                    isWidgetRefreshing = false
                                }
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise.circle")
                                        .foregroundColor(Color(hex: "1A1A1A"))
                                        .font(.title3)
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(NSLocalizedString("widget_refresh", comment: "Widget refresh"))
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                    .foregroundColor(.charcoalBlack)
                                        Text(NSLocalizedString("widget_refresh_description", comment: "Widget refresh description"))
                                            .font(.caption)
                                            .foregroundColor(.charcoalBlack.opacity(0.7))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: isWidgetRefreshing ? "checkmark.circle.fill" : "chevron.right")
                                        .font(isWidgetRefreshing ? .title : .caption)
                                        .foregroundColor(isWidgetRefreshing ? .green : .charcoalBlack.opacity(0.5))
                                        .animation(.easeInOut(duration: 0.3), value: isWidgetRefreshing)
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
                                        Text(NSLocalizedString("data_reset", comment: "Data reset"))
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.charcoalBlack)
                                        Text(NSLocalizedString("data_reset_description", comment: "Data reset description"))
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
        .sheet(item: $colorPickerItem) { shiftType in
            ColorPickerView(shiftType: shiftType, shiftManager: shiftManager)
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
                        Text(NSLocalizedString("next", comment: "Next"))
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
                            Text(NSLocalizedString("apply", comment: "Apply"))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.charcoalBlack)
                                .cornerRadius(12)
                        }
                        
                        Button(action: backToPatternSelection) {
                            Text(NSLocalizedString("previous", comment: "Previous"))
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
                    Text(NSLocalizedString("team_selection", comment: "Team selection"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoalBlack)
                    
                    Text(NSLocalizedString("team_selection_description", comment: "Team selection description"))
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
                    Text(NSLocalizedString("apply", comment: "Apply"))
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
                        Text(shiftType.displayName)
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
                    Text(NSLocalizedString("team_\(teamNumber)", comment: "Team name"))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.charcoalBlack)
                    
                    Text(NSLocalizedString("team", comment: "Team"))
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
                                Text(NSLocalizedString("basic_salary", comment: "Basic salary"))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.charcoalBlack)
                            }
                            
                            VStack(spacing: 12) {
                                SalaryInputField(
                                    title: NSLocalizedString("base_salary_input", comment: "Base salary input"),
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
                                Text(NSLocalizedString("work_allowances", comment: "Work allowances"))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.charcoalBlack)
                            }
                            
                            VStack(spacing: 12) {
                                SalaryInputField(
                                    title: NSLocalizedString("night_allowance_input", comment: "Night allowance input"),
                                    value: $nightShiftRate,
                                    placeholder: "예: 1.5"
                                )
                                
                                SalaryInputField(
                                    title: NSLocalizedString("deep_night_allowance_input", comment: "Deep night allowance input"),
                                    value: $deepNightShiftRate,
                                    placeholder: "예: 2.0"
                                )
                                
                                SalaryInputField(
                                    title: NSLocalizedString("overtime_rate_input", comment: "Overtime rate input"),
                                    value: $overtimeRate,
                                    placeholder: "예: 1.5"
                                )
                                
                                SalaryInputField(
                                    title: NSLocalizedString("holiday_allowance_input", comment: "Holiday allowance input"),
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
                                Text(NSLocalizedString("vacation_info", comment: "Vacation info"))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.charcoalBlack)
                            }
                            
                            VStack(spacing: 12) {
                                SalaryInputField(
                                    title: NSLocalizedString("annual_leave_days_input", comment: "Annual leave days input"),
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
    @State private var customDayShifts: [CustomShiftType?] = []
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
                                Text(NSLocalizedString("cycle_length_days", comment: "Cycle length days"))
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
                                    
                                    Text("\(cycleLength)\(NSLocalizedString("days_suffix", comment: "Days suffix"))")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.charcoalBlack)
                                        .frame(minWidth: 60)
                                    
                                    Spacer()
                                    
                                    Button(action: { if cycleLength < 15 { cycleLength += 1 } }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(cycleLength < 15 ? Color(hex: "1A1A1A") : .gray)
                                    }
                                    .disabled(cycleLength >= 15)
                                }
                                .padding(.horizontal, 20)
                                
                                Text(NSLocalizedString("cycle_range_hint", comment: "Cycle range hint"))
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
                                Text(NSLocalizedString("start_date_setting", comment: "Start date setting"))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.charcoalBlack)
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text(NSLocalizedString("pattern_start_date", comment: "Pattern start date"))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.charcoalBlack)
                                
                                DatePicker(NSLocalizedString("start_date", comment: "Start date"), selection: $startDate, displayedComponents: .date)
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
                                Text(NSLocalizedString("daily_shift_elements", comment: "Daily shift elements"))
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
                                            Text(String(format: NSLocalizedString("day_format", comment: "Day format"), dayIndex + 1))
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.charcoalBlack)
                                            
                                            Spacer()
                                            
                                            if dayIndex < dayShifts.count, let shiftType = dayShifts[dayIndex] {
                                                HStack(spacing: 8) {
                                                    Circle()
                                                        .fill(shiftType.color)
                                                        .frame(width: 16, height: 16)
                                                    
                                                    Text(shiftType.displayName)
                                                        .font(.subheadline)
                                                        .fontWeight(.medium)
                                                        .foregroundColor(.charcoalBlack)
                                                    
                                                    Image(systemName: "chevron.right")
                                                        .font(.caption)
                                                        .foregroundColor(.charcoalBlack.opacity(0.5))
                                                }
                                            } else if dayIndex < customDayShifts.count, let customShiftType = customDayShifts[dayIndex] {
                                                HStack(spacing: 8) {
                                                    Circle()
                                                        .fill(customShiftType.displayColor)
                                                        .frame(width: 16, height: 16)
                                                    
                                                    Text(customShiftType.name)
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
                        // 기본 근무 요소가 선택되면 커스텀 근무 요소는 제거
                        if newValue != nil {
                            customDayShifts[selectedDayIndex] = nil
                        }
                    }
                ),
                selectedCustomShiftType: Binding(
                    get: { 
                        guard selectedDayIndex < customDayShifts.count else { return nil }
                        return customDayShifts[selectedDayIndex] 
                    },
                    set: { newValue in
                        guard selectedDayIndex < customDayShifts.count else { return }
                        customDayShifts[selectedDayIndex] = newValue
                        // 커스텀 근무 요소가 선택되면 기본 근무 요소는 제거
                        if newValue != nil {
                            dayShifts[selectedDayIndex] = nil
                        }
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
        return dayShifts.count == cycleLength && customDayShifts.count == cycleLength &&
               (0..<cycleLength).allSatisfy { index in
                   dayShifts[index] != nil || customDayShifts[index] != nil
               }
    }
    
    private func loadCurrentPattern() {
        if let customPattern = shiftManager.settings.customPattern {
            cycleLength = customPattern.cycleLength
            startDate = customPattern.startDate
            
            // 기본 근무 요소 로드
            var newDayShifts: [ShiftType?] = Array(repeating: nil, count: cycleLength)
            for (index, shiftType) in customPattern.dayShifts.enumerated() {
                if index < cycleLength {
                    newDayShifts[index] = shiftType
                }
            }
            dayShifts = newDayShifts
            
            // 커스텀 근무 요소 로드
            var newCustomDayShifts: [CustomShiftType?] = Array(repeating: nil, count: cycleLength)
            for (index, customShiftType) in customPattern.customDayShifts.enumerated() {
                if index < cycleLength {
                    newCustomDayShifts[index] = customShiftType
                }
            }
            customDayShifts = newCustomDayShifts
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
        
        if customDayShifts.count != cycleLength {
            var newCustomDayShifts: [CustomShiftType?] = Array(repeating: nil, count: cycleLength)
            // 기존 데이터를 보존하면서 배열 크기 조정
            for (index, customShiftType) in customDayShifts.enumerated() {
                if index < cycleLength {
                    newCustomDayShifts[index] = customShiftType
                }
            }
            customDayShifts = newCustomDayShifts
        }
    }
    
    private func saveCustomPattern() {
        // 유효성 검사
        guard cycleLength >= 2 && cycleLength <= 15 else { return }
        guard dayShifts.count == cycleLength && customDayShifts.count == cycleLength else { return }
        
        // nil이 아닌 근무 요소들만 필터링
        let validDayShifts = dayShifts.compactMap { $0 }
        let validCustomDayShifts = customDayShifts.compactMap { $0 }
        
        // 각 일차에 기본 근무 요소 또는 커스텀 근무 요소가 하나씩 있어야 함
        let totalValidShifts = validDayShifts.count + validCustomDayShifts.count
        guard totalValidShifts == cycleLength else { return }
        
        print("=== CustomPatternEditView saveCustomPattern ===")
        print("Cycle Length: \(cycleLength)")
        print("Start Date: \(startDate)")
        print("Valid Day Shifts: \(validDayShifts)")
        print("Valid Custom Day Shifts: \(validCustomDayShifts)")
        print("Total Valid Shifts: \(totalValidShifts)")
        
        let customPattern = CustomShiftPattern(
            cycleLength: cycleLength,
            startDate: startDate,
            dayShifts: validDayShifts,
            customDayShifts: validCustomDayShifts
        )
        
        print("Created Custom Pattern:")
        print("- Name: \(customPattern.name)")
        print("- Start Date: \(customPattern.startDate)")
        print("- Day Shifts: \(customPattern.dayShifts)")
        print("- Custom Day Shifts: \(customPattern.customDayShifts)")
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
    @Binding var selectedCustomShiftType: CustomShiftType?
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    
    @State private var showingCustomShiftInput = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 기본 근무 요소들
                VStack(alignment: .leading, spacing: 12) {
                    Text("기본 근무 요소")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoalBlack)
                        .padding(.horizontal, 20)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        ForEach(ShiftType.allCases, id: \.self) { shiftType in
                            Button(action: {
                                selectedShiftType = shiftType
                                selectedCustomShiftType = nil
                                dismiss()
                            }) {
                                HStack {
                                    Circle()
                                        .fill(shiftType.color)
                                        .frame(width: 20, height: 20)
                                    
                                    Text(shiftType.displayName)
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
                }
                
                // 커스텀 근무 요소들
                if !shiftManager.getAllCustomShiftTypes().isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("커스텀 근무 요소")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.charcoalBlack)
                            .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            ForEach(shiftManager.getAllCustomShiftTypes(), id: \.id) { customShiftType in
                                Button(action: {
                                    selectedShiftType = nil
                                    selectedCustomShiftType = customShiftType
                                    dismiss()
                                }) {
                                    HStack {
                                        Circle()
                                            .fill(customShiftType.displayColor)
                                            .frame(width: 20, height: 20)
                                        
                                        Text(customShiftType.name)
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
                                            .stroke(selectedCustomShiftType?.id == customShiftType.id ? Color(hex: "1A1A1A") : Color.clear, lineWidth: 2)
                                    )
                                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // 커스텀 근무 요소 추가 버튼
                Button(action: {
                    showingCustomShiftInput = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.mainColorButton)
                            .font(.title3)
                        
                        Text("커스텀 근무 요소 추가")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.mainColorButton)
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.mainColorButton, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
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
        .sheet(isPresented: $showingCustomShiftInput) {
            CustomShiftTypeInputView()
        }
    }
}

// MARK: - Custom Shift Type Input View
struct CustomShiftTypeInputView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    
    @State private var shiftName: String = ""
    @State private var selectedColor: String = "77BBFB"
    @State private var startHour: Int = 9
    @State private var startMinute: Int = 0
    @State private var endHour: Int = 18
    @State private var endMinute: Int = 0
    
    private let availableColors = [
        "77BBFB", "7E85F9", "92E3A9", "F47F4C", "FFA8D2", 
        "C39DF4", "B9D831", "439897", "4B4B4B", "2C3E50",
        "FF5D73", "CDB5EB", "C7E89C", "A0B2B6", "D5E7EB"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ScrollView {
                    VStack(spacing: 25) {
                        // 근무 요소 이름 입력
                        VStack(alignment: .leading, spacing: 12) {
                            Text("근무 요소 이름")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.charcoalBlack)
                            
                            TextField("근무 요소 이름을 입력하세요", text: $shiftName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        
                        // 색상 선택
                        VStack(alignment: .leading, spacing: 12) {
                            Text("색상 선택")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.charcoalBlack)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                                ForEach(availableColors, id: \.self) { colorHex in
                                    Button(action: {
                                        selectedColor = colorHex
                                    }) {
                                        Circle()
                                            .fill(Color(hex: colorHex))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Circle()
                                                    .stroke(selectedColor == colorHex ? Color.charcoalBlack : Color.clear, lineWidth: 3)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // 근무 시간 설정
                        VStack(spacing: 12) {
                            Text("근무 시간")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.charcoalBlack)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // 시작-종료 시간 설정 (한 줄에 배치)
                            HStack(spacing: 20) {
                                // 시작 시간
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "sunrise")
                                            .foregroundColor(.orange)
                                            .font(.caption)
                                        Text("시작")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.charcoalBlack)
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Picker("시작 시간", selection: $startHour) {
                                            ForEach(0..<24, id: \.self) { hour in
                                                Text("\(hour)").tag(hour)
                                            }
                                        }
                                        .pickerStyle(WheelPickerStyle())
                                        .frame(width: 50, height: 80)
                                        .clipped()
                                        
                                        Text(":")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.charcoalBlack)
                                        
                                        Picker("시작 분", selection: $startMinute) {
                                            ForEach([0, 15, 30, 45], id: \.self) { minute in
                                                Text(String(format: "%02d", minute)).tag(minute)
                                            }
                                        }
                                        .pickerStyle(WheelPickerStyle())
                                        .frame(width: 50, height: 80)
                                        .clipped()
                                    }
                                }
                                
                                // 구분선
                                Rectangle()
                                    .fill(Color.charcoalBlack.opacity(0.2))
                                    .frame(width: 1, height: 60)
                                
                                // 종료 시간
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "sunset")
                                            .foregroundColor(.purple)
                                            .font(.caption)
                                        Text("종료")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.charcoalBlack)
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Picker("종료 시간", selection: $endHour) {
                                            ForEach(0..<24, id: \.self) { hour in
                                                Text("\(hour)").tag(hour)
                                            }
                                        }
                                        .pickerStyle(WheelPickerStyle())
                                        .frame(width: 50, height: 80)
                                        .clipped()
                                        
                                        Text(":")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.charcoalBlack)
                                        
                                        Picker("종료 분", selection: $endMinute) {
                                            ForEach([0, 15, 30, 45], id: \.self) { minute in
                                                Text(String(format: "%02d", minute)).tag(minute)
                                            }
                                        }
                                        .pickerStyle(WheelPickerStyle())
                                        .frame(width: 50, height: 80)
                                        .clipped()
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            
                            // 시간 미리보기
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("설정된 시간")
                                        .font(.subheadline)
                                        .foregroundColor(.charcoalBlack.opacity(0.7))
                                    
                                    Text("\(String(format: "%02d:%02d", startHour, startMinute)) ~ \(String(format: "%02d:%02d", endHour, endMinute))")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.charcoalBlack)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("근무 시간")
                                        .font(.subheadline)
                                        .foregroundColor(.charcoalBlack.opacity(0.7))
                                    
                                    Text("\(String(format: "%.1f", calculateWorkingHours()))시간")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.charcoalBlack)
                                }
                            }
                            .padding(12)
                            .background(Color(hex: "F8F9FA"))
                            .cornerRadius(8)
                        }
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .background(Color(hex: "EFF0F2"))
            .navigationTitle("커스텀 근무 요소 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveCustomShiftType()
                        dismiss()
                    }
                    .disabled(shiftName.isEmpty)
                }
            }
        }
    }
    
    private func calculateWorkingHours() -> Double {
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute
        
        var totalMinutes: Int
        if endMinutes > startMinutes {
            totalMinutes = endMinutes - startMinutes
        } else {
            // 자정을 넘어가는 경우
            totalMinutes = (24 * 60 - startMinutes) + endMinutes
        }
        
        return Double(totalMinutes) / 60.0
    }
    
    private func saveCustomShiftType() {
        let workingHours = ShiftTime(
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute
        )
        
        let customShiftType = CustomShiftType(
            name: shiftName,
            color: selectedColor,
            workingHours: workingHours
        )
        
        shiftManager.addCustomShiftType(customShiftType)
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
                Text(NSLocalizedString("data_reset_warning", comment: "Data reset warning"))
                    .font(.subheadline)
                    .foregroundColor(.charcoalBlack.opacity(0.7))
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 12) {
                    Button(action: {
                        shiftManager.resetAllData()
                        dismiss()
                    }) {
                        Text(NSLocalizedString("reset", comment: "Reset button"))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "1A1A1A"))
                            .cornerRadius(12)
                    }
                    
                    Button(action: { dismiss() }) {
                        Text(NSLocalizedString("cancel", comment: "Cancel button"))
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
            .navigationTitle(NSLocalizedString("data_reset_title", comment: "Data reset title"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

