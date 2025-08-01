import SwiftUI

struct SettingsView: View {
    private func getColorKey(for shiftType: ShiftType) -> String {
        switch shiftType {
        case .야간: return "nightShift"
        case .심야: return "deepNightShift"
        case .주간: return "dayShift"
        case .오후: return "afternoonShift"
        case .당직: return "dutyShift"
        case .휴무: return "offDuty"
        case .비번: return "standby"
        }
    }
    
    private func getCurrentPatternShiftTypes() -> [ShiftType] {
        let pattern = shiftManager.settings.shiftPatternType.generatePattern()
        // 중복 제거하고 순서 유지
        var uniqueTypes: [ShiftType] = []
        for shiftType in pattern {
            if !uniqueTypes.contains(shiftType) {
                uniqueTypes.append(shiftType)
            }
        }
        return uniqueTypes
    }
    @EnvironmentObject var shiftManager: ShiftManager
    @State private var showingColorPicker = false
    @State private var selectedShiftType: ShiftType = .야간
    @State private var showingCustomShiftInput = false
    @State private var showingShiftTypeSelection = false
    @State private var showingTeamSelection = false
    @State private var currentSetupStep: SetupStep = .shiftType
    @State private var showingSalarySetup = false
    @State private var showingPatternSelection = false
    
    enum SetupStep {
        case shiftType
        case team
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "EFF0F2")
                    .ignoresSafeArea()
                
                List {
                Section(header: Text("근무 설정")) {
                    HStack {
                        Text("근무 패턴")
                        Spacer()
                        Text(shiftManager.settings.shiftPatternType.displayName)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("소속 팀")
                        Spacer()
                        Text(shiftManager.settings.team)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("근무 패턴 변경") {
                        showingPatternSelection = true
                    }
                    .foregroundColor(.blue)
                }
                
                Section(header: Text("근무요소 수정")) {
                    ForEach(getCurrentPatternShiftTypes(), id: \.self) { shiftType in
                        HStack {
                            Circle()
                                .fill(shiftManager.getColor(for: shiftType))
                                .frame(width: 20, height: 20)
                            
                            Text(shiftType.rawValue)
                            
                            Spacer()
                            
                            Button("변경") {
                                selectedShiftType = shiftType
                                showingColorPicker = true
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                
                Section(header: Text("급여 정보")) {
                    HStack {
                        Text("기본급")
                        Spacer()
                        Text(shiftManager.settings.baseSalary > 0 ? "\(Int(shiftManager.settings.baseSalary))원" : "설정 안됨")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("야간 근무 수당")
                        Spacer()
                        Text("\(String(format: "%.1f", shiftManager.settings.nightShiftRate))배")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("심야 근무 수당")
                        Spacer()
                        Text("\(String(format: "%.1f", shiftManager.settings.deepNightShiftRate))배")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("초과근무 배율")
                        Spacer()
                        Text("\(String(format: "%.1f", shiftManager.settings.overtimeRate))배")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("휴일 근무 수당")
                        Spacer()
                        Text("\(String(format: "%.1f", shiftManager.settings.holidayWorkRate))배")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("연간 휴가 일수")
                        Spacer()
                        Text("\(shiftManager.settings.annualVacationDays)일")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("급여 정보 수정") {
                        showingSalarySetup = true
                    }
                    .foregroundColor(.blue)
                }
                

                
                Section(header: Text("기타")) {
                    Button("비주기적 근무 입력") {
                        showingCustomShiftInput = true
                    }
                    .foregroundColor(.blue)
                    
                    Button("데이터 내보내기") {
                        exportData()
                    }
                    .foregroundColor(.blue)
                    
                    Button("데이터 초기화") {
                        resetData()
                    }
                    .foregroundColor(.red)
                }
                }
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
                .padding(.bottom, 80) // 네비게이션 바 높이만큼 여백
            }
            .sheet(isPresented: $showingColorPicker) {
                ColorPickerView(
                    shiftType: selectedShiftType,
                    color: Binding(
                        get: { shiftManager.getColor(for: selectedShiftType) },
                        set: { newColor in
                            shiftManager.setColor(newColor, for: selectedShiftType)
                        }
                    )
                )
                .environmentObject(shiftManager)
            }
            .sheet(isPresented: $showingCustomShiftInput) {
                CustomShiftInputView()
                    .environmentObject(shiftManager)
            }
            .sheet(isPresented: $showingShiftTypeSelection) {
                ShiftTypeSelectionSheet(
                    currentStep: $currentSetupStep,
                    showingShiftTypeSelection: $showingShiftTypeSelection,
                    showingTeamSelection: $showingTeamSelection
                )
                .environmentObject(shiftManager)
            }
            .sheet(isPresented: $showingTeamSelection) {
                TeamSelectionSheet(
                    currentStep: $currentSetupStep,
                    showingShiftTypeSelection: $showingShiftTypeSelection,
                    showingTeamSelection: $showingTeamSelection
                )
                .environmentObject(shiftManager)
            }
            .sheet(isPresented: $showingSalarySetup) {
                SalarySetupView()
                    .environmentObject(shiftManager)
            }
            .sheet(isPresented: $showingPatternSelection) {
                ShiftPatternSelectionSheet()
                    .environmentObject(shiftManager)
            }

        }
    }
    
    private func exportData() {
        // Export schedule data
    }
    
    private func resetData() {
        shiftManager.schedules.removeAll()
    }
}

struct ShiftTypeSelectionSheet: View {
    @Binding var currentStep: SettingsView.SetupStep
    @Binding var showingShiftTypeSelection: Bool
    @Binding var showingTeamSelection: Bool
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Text("근무 유형을 선택하세요")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoalBlack)
                    
                    Text("근무 패턴에 따라 일정이 자동으로 생성됩니다")
                        .font(.body)
                        .foregroundColor(.charcoalBlack.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 15) {
                    Button(action: {
                        shiftManager.settings.shiftPatternType = .fiveTeamThreeShift
                        currentStep = .team
                        showingShiftTypeSelection = false
                        showingTeamSelection = true
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("5조 3교대")
                                    .font(.headline)
                                    .foregroundColor(.charcoalBlack)
                                
                                Text("5개 팀이 3교대로 근무")
                                    .font(.caption)
                                    .foregroundColor(.charcoalBlack.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            if shiftManager.settings.shiftPatternType == .fiveTeamThreeShift {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.mainColorButton)
                            }
                        }
                        .padding()
                        .background(Color.backgroundWhite)
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
            }
            .padding()
            .background(Color.backgroundLight)
            .navigationTitle("근무 유형 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(.charcoalBlack)
                }
            }
        }
    }
    

}

struct TeamSelectionSheet: View {
    @Binding var currentStep: SettingsView.SetupStep
    @Binding var showingShiftTypeSelection: Bool
    @Binding var showingTeamSelection: Bool
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Text("소속 팀을 선택하세요")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoalBlack)
                    
                    Text("팀 번호에 따라 근무 일정이 조정됩니다")
                        .font(.body)
                        .foregroundColor(.charcoalBlack.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                    ForEach(1...5, id: \.self) { teamNumber in
                        TeamCard(
                            teamNumber: teamNumber,
                            isSelected: shiftManager.settings.team == "\(teamNumber)조"
                        ) {
                            shiftManager.settings.team = "\(teamNumber)조"
                            dismiss()
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color.backgroundLight)
            .navigationTitle("팀 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("뒤로") {
                        currentStep = .shiftType
                        showingTeamSelection = false
                        showingShiftTypeSelection = true
                    }
                    .foregroundColor(.charcoalBlack)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(.charcoalBlack)
                }
            }
        }
    }
}

struct ColorPickerView: View {
    let shiftType: ShiftType
    @Binding var color: Color
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var shiftManager: ShiftManager
    @State private var customName: String = ""
    @State private var showingNameEditor = false
    
    private let customColors: [Color] = [
        .mainColor, .mainColorButton, .mainColorDark, .pointColor, .subColor1, .subColor2,
        .backgroundLight, .nightShift, .deepNightShift, .dayShift, .offDuty, .standby,
        Color(hex: "439897"), Color(hex: "4B4B4B"), Color(hex: "F47F4C"), Color(hex: "2C3E50"), Color(hex: "77BBFB"),
        Color(hex: "7E85F9"), Color(hex: "FFA8D2"), Color(hex: "C39DF4"), Color(hex: "92E3A9"), Color(hex: "B9D831")
    ]
    
    private let systemColors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink,
        .gray, .brown, .cyan, .mint, .indigo, .teal, .charcoalBlack
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(shiftType.rawValue)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.charcoalBlack)
                        
                        Text("근무 요소 이름 및 색상 수정")
                            .font(.caption)
                            .foregroundColor(.charcoalBlack.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        customName = shiftType.rawValue
                        showingNameEditor = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                            Text("이름 수정")
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
                
                VStack(spacing: 12) {
                    Text("색상 선택")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.charcoalBlack)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                        ForEach(Array((customColors + systemColors).enumerated()), id: \.offset) { index, colorOption in
                            Circle()
                                .fill(colorOption)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .stroke(color == colorOption ? Color.mainColorButton : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    color = colorOption
                                }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color.backgroundLight)
            .navigationTitle("근무요소 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                    .foregroundColor(.charcoalBlack)
                }
            }
            .sheet(isPresented: $showingNameEditor) {
                NameEditSheet(
                    shiftType: shiftType,
                    customName: $customName,
                    shiftManager: shiftManager
                )
            }
        }
    }
}

struct NameEditSheet: View {
    let shiftType: ShiftType
    @Binding var customName: String
    let shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                Text("근무 요소 이름 수정")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoalBlack)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("이름")
                        .font(.headline)
                        .foregroundColor(.charcoalBlack)
                    TextField("근무 요소 이름을 입력하세요", text: $customName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button("저장") {
                    saveCustomName()
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 20)
            .background(Color.backgroundLight)
            .navigationTitle("이름 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(.charcoalBlack)
                }
            }
        }
    }
    
    private func saveCustomName() {
        // ShiftManager에 커스텀 이름 저장 로직 추가 필요
        // 현재는 기본 구현만 제공
    }
}

struct SalarySetupView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    @State private var baseSalary: String = ""
    @State private var nightShiftRate: String = ""
    @State private var deepNightShiftRate: String = ""
    @State private var overtimeRate: String = ""
    @State private var holidayWorkRate: String = ""
    @State private var annualVacationDays: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                                    VStack(spacing: 15) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("기본급 (월급)")
                                .font(.headline)
                                .foregroundColor(.charcoalBlack)
                            TextField("기본급을 입력하세요", text: $baseSalary)
                                .keyboardType(.numberPad)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.backgroundWhite)
                                .cornerRadius(12)
                                .frame(height: 50)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("야간 근무 수당 배율")
                                .font(.headline)
                                .foregroundColor(.charcoalBlack)
                            TextField("야간 근무 수당 배율을 입력하세요 (기본: 1.5)", text: $nightShiftRate)
                                .keyboardType(.decimalPad)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.backgroundWhite)
                                .cornerRadius(12)
                                .frame(height: 50)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("심야 근무 수당 배율")
                                .font(.headline)
                                .foregroundColor(.charcoalBlack)
                            TextField("심야 근무 수당 배율을 입력하세요 (기본: 2.0)", text: $deepNightShiftRate)
                                .keyboardType(.decimalPad)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.backgroundWhite)
                                .cornerRadius(12)
                                .frame(height: 50)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("초과근무 배율")
                                .font(.headline)
                                .foregroundColor(.charcoalBlack)
                            TextField("초과근무 배율을 입력하세요 (기본: 1.5)", text: $overtimeRate)
                                .keyboardType(.decimalPad)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.backgroundWhite)
                                .cornerRadius(12)
                                .frame(height: 50)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("휴일 근무 수당 배율")
                                .font(.headline)
                                .foregroundColor(.charcoalBlack)
                            TextField("휴일 근무 수당 배율을 입력하세요 (기본: 1.5)", text: $holidayWorkRate)
                                .keyboardType(.decimalPad)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.backgroundWhite)
                                .cornerRadius(12)
                                .frame(height: 50)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("연간 휴가 일수")
                                .font(.headline)
                                .foregroundColor(.charcoalBlack)
                            TextField("연간 휴가 일수를 입력하세요", text: $annualVacationDays)
                                .keyboardType(.numberPad)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.backgroundWhite)
                                .cornerRadius(12)
                                .frame(height: 50)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 30)
                    
                    Button("저장") {
                        saveSalaryInfo()
                        dismiss()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
            }
            .background(Color(hex: "EFF0F2"))
            .navigationTitle("급여 정보")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(.charcoalBlack)
                }
            }
            .onAppear {
                loadCurrentValues()
            }
        }
    }
    
    private func loadCurrentValues() {
        baseSalary = shiftManager.settings.baseSalary > 0 ? "\(Int(shiftManager.settings.baseSalary))" : ""
        nightShiftRate = shiftManager.settings.nightShiftRate > 0 ? "\(shiftManager.settings.nightShiftRate)" : ""
        deepNightShiftRate = shiftManager.settings.deepNightShiftRate > 0 ? "\(shiftManager.settings.deepNightShiftRate)" : ""
        overtimeRate = shiftManager.settings.overtimeRate > 0 ? "\(shiftManager.settings.overtimeRate)" : ""
        holidayWorkRate = shiftManager.settings.holidayWorkRate > 0 ? "\(shiftManager.settings.holidayWorkRate)" : ""
        annualVacationDays = shiftManager.settings.annualVacationDays > 0 ? "\(shiftManager.settings.annualVacationDays)" : ""
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

struct ShiftPatternSelectionSheet: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedPattern: ShiftPatternType
    @State private var selectedTeam: String
    @State private var currentStep: SelectionStep = .pattern
    
    enum SelectionStep {
        case pattern
        case team
    }
    
    init() {
        _selectedPattern = State(initialValue: ShiftManager.shared.settings.shiftPatternType)
        _selectedTeam = State(initialValue: ShiftManager.shared.settings.team)
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
                            ForEach(ShiftPatternType.allCases, id: \.self) { pattern in
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
                        
                        Button(action: goBackToPattern) {
                            Text("이전")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.charcoalBlack)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.backgroundLight)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .background(Color.backgroundLight)
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(.charcoalBlack)
                }
            }
        }
    }
    
    private func getTeamCount() -> Int {
        switch selectedPattern {
        case .twoShift: return 2
        case .threeShift: return 3
        case .threeTeamTwoShift: return 3
        case .fourTeamTwoShift: return 4
        case .fourTeamThreeShift: return 4
        case .fiveTeamThreeShift: return 5
        case .irregular: return 6
        }
    }
    
    private func nextToTeamSelection() {
        currentStep = .team
    }
    
    private func goBackToPattern() {
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