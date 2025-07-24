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
    @State private var showingShiftTypeSelection = false
    @State private var showingTeamSelection = false
    @State private var currentSetupStep: SetupStep = .shiftType
    @State private var showingSalarySetup = false
    @State private var showingPatternSelection = false
    @State private var showingCustomPattern = false
    
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
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(shiftManager.settings.shiftPatternType.displayName)
                                .foregroundColor(.secondary)
                            if shiftManager.settings.shiftPatternType == .custom,
                               let customPattern = shiftManager.settings.customPattern {
                                Text(customPattern.name)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
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
                    
                    if shiftManager.settings.shiftPatternType == .custom {
                        if let _ = shiftManager.settings.customPattern {
                            Button("커스텀 패턴 편집") {
                                showingCustomPattern = true
                            }
                            .foregroundColor(.blue)
                        }
                    }
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
            }
            .listStyle(InsetGroupedListStyle())
            .scrollContentBackground(.hidden)
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
            .sheet(isPresented: $showingCustomPattern) {
                CustomPatternViewInline()
                    .environmentObject(shiftManager)
            }

            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowCustomPattern"))) { _ in
                showingCustomPattern = true
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
                                    if pattern == .custom {
                                        // 커스텀 패턴 선택 시 CustomPatternView로 이동
                                        dismiss()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            NotificationCenter.default.post(name: NSNotification.Name("ShowCustomPattern"), object: nil)
                                        }
                                    } else {
                                        selectedPattern = pattern
                                    }
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
        case .custom:
            return shiftManager.settings.customPattern?.shifts.count ?? 0
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
    @EnvironmentObject var shiftManager: ShiftManager
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
                    if pattern == .custom {
                        if let customPattern = shiftManager.settings.customPattern {
                            ForEach(customPattern.shifts, id: \.self) { shiftType in
                                Text(shiftType.rawValue)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(shiftType.color)
                                    .cornerRadius(6)
                            }
                        } else {
                            Text("패턴 생성 필요")
                                .font(.caption)
                                .foregroundColor(.charcoalBlack.opacity(0.6))
                        }
                    } else {
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

// MARK: - Custom Pattern View Inline
struct CustomPatternViewInline: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    
    @State private var patternName: String = ""
    @State private var dayShifts: [ShiftType] = [.주간, .야간, .휴무] // Non-optional로 변경
    @State private var cycleLength: Int = 3
    @State private var startDate: Date = Date()
    @State private var description: String = ""
    @State private var showingShiftSelector = false
    @State private var currentEditingDay: Int? // 현재 편집 중인 일차
    @State private var isEditing: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 기존 패턴 정보 표시 (편집 모드일 때)
                    if isEditing, let existingPattern = shiftManager.settings.customPattern {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("현재 패턴")
                                .font(.headline)
                                .foregroundColor(.charcoalBlack)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(existingPattern.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(existingPattern.description)
                                    .font(.caption)
                                    .foregroundColor(.charcoalBlack.opacity(0.7))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.mainColor)
                            .cornerRadius(12)
                        }
                    }
                    
                    // 패턴 이름 입력
                    VStack(alignment: .leading, spacing: 8) {
                        Text("패턴 이름")
                            .font(.headline)
                            .foregroundColor(.charcoalBlack)
                        TextField("근무 패턴의 이름을 입력하세요", text: $patternName)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.backgroundWhite)
                            .cornerRadius(12)
                            .frame(height: 50)
                    }
                    
                    // 주기 설정
                    VStack(alignment: .leading, spacing: 8) {
                        Text("반복 주기")
                            .font(.headline)
                            .foregroundColor(.charcoalBlack)
                        HStack {
                            Text("\(cycleLength)일")
                                .font(.subheadline)
                                .foregroundColor(.charcoalBlack)
                            Spacer()
                            Stepper("", value: $cycleLength, in: 2...7)
                                .labelsHidden()
                                .onChange(of: cycleLength) { _, newValue in
                                    updateDayShiftsArray(newLength: newValue)
                                }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.backgroundWhite)
                        .cornerRadius(12)
                        .frame(height: 50)
                    }
                    
                    // 시작일 설정
                    VStack(alignment: .leading, spacing: 8) {
                        Text("패턴 시작일")
                            .font(.headline)
                            .foregroundColor(.charcoalBlack)
                        DatePicker("", selection: $startDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.backgroundWhite)
                            .cornerRadius(12)
                            .frame(height: 50)
                    }
                    
                    // 일차별 근무 요소 선택
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("일차별 근무 요소")
                                .font(.headline)
                                .foregroundColor(.charcoalBlack)
                            Spacer()
                            Text("\(cycleLength)일 주기")
                                .font(.caption)
                                .foregroundColor(.charcoalBlack.opacity(0.7))
                        }
                        
                        VStack(spacing: 8) {
                            ForEach(0..<cycleLength, id: \.self) { dayIndex in
                                DayShiftCard(
                                    dayNumber: dayIndex + 1,
                                    shiftType: dayIndex < dayShifts.count ? dayShifts[dayIndex] : .주간,
                                    onTap: {
                                        currentEditingDay = dayIndex
                                        showingShiftSelector = true
                                    }
                                )
                            }
                        }
                    }
                    
                    // 설명 입력
                    VStack(alignment: .leading, spacing: 8) {
                        Text("설명 (선택사항)")
                            .font(.headline)
                            .foregroundColor(.charcoalBlack)
                        TextField("패턴에 대한 설명을 입력하세요", text: $description, axis: .vertical)
                            .lineLimit(3...6)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.backgroundWhite)
                            .cornerRadius(12)
                    }
                    
                    // 저장 버튼
                    Button(action: savePattern) {
                        Text(isEditing ? "패턴 수정" : "패턴 저장")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canSave ? Color.charcoalBlack : Color.charcoalBlack.opacity(0.5))
                            .cornerRadius(12)
                    }
                    .disabled(!canSave)
                    .padding(.top, 20)
                    
                    // 삭제 버튼 (편집 모드일 때만)
                    if isEditing {
                        Button(action: deletePattern) {
                            Text("패턴 삭제")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(20)
            }
            .background(Color.backgroundLight)
            .navigationTitle("커스텀 패턴")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(.charcoalBlack)
                }
            }
            .sheet(isPresented: $showingShiftSelector) {
                ShiftSelectorViewInline(
                    selectedShift: getSelectedShift(),
                    onSelect: handleShiftSelection
                )
            }
            .onAppear {
                loadExistingPattern()
            }
        }
    }
    
    private var canSave: Bool {
        !patternName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
        dayShifts.count == cycleLength // Non-optional이므로 nil 체크 불필요
    }
    
    private func loadExistingPattern() {
        if let existingPattern = shiftManager.settings.customPattern {
            isEditing = true
            patternName = existingPattern.name
            // ShiftType 배열을 그대로 사용 (이제 Non-optional)
            dayShifts = existingPattern.dayShifts
            cycleLength = existingPattern.cycleLength
            startDate = existingPattern.startDate
            description = existingPattern.description
        }
    }
    
    private func savePattern() {
        let trimmedName = patternName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("=== Custom Pattern Save Debug ===")
        print("Pattern Name: '\(trimmedName)'")
        print("Cycle Length: \(cycleLength)")
        print("Day Shifts Count: \(dayShifts.count)")
        print("Day Shifts: \(dayShifts)")
        print("Can Save: \(canSave)")
        
        // 1차 검증: 기본 조건 확인
        guard !trimmedName.isEmpty else {
            print("Error: Pattern name cannot be empty")
            return
        }
        
        guard cycleLength > 0 else {
            print("Error: Cycle length must be greater than 0")
            return
        }
        
        guard dayShifts.count == cycleLength else {
            print("Error: Day shifts count doesn't match cycle length. Expected: \(cycleLength), Got: \(dayShifts.count)")
            return
        }
        
        // 2차 검증: dayShifts가 비어있지 않은지 확인
        guard !dayShifts.isEmpty else {
            print("Error: Day shifts cannot be empty")
            return
        }
        
        // 3차 검증: 모든 dayShifts가 유효한 값인지 확인
        let validShifts = dayShifts.filter { shiftType in
            switch shiftType {
            case .주간, .야간, .심야, .오후, .당직, .휴무, .비번:
                return true
            }
        }
        
        guard validShifts.count == dayShifts.count else {
            print("Error: Some day shifts are invalid")
            return
        }
        
        print("All validations passed. Creating/Updating custom pattern...")
        
        if isEditing {
            shiftManager.updateCustomPattern(CustomShiftPattern(
                name: trimmedName,
                dayShifts: dayShifts,
                cycleLength: cycleLength,
                startDate: startDate,
                description: trimmedDescription
            ))
        } else {
            shiftManager.createCustomPattern(
                name: trimmedName,
                dayShifts: dayShifts,
                cycleLength: cycleLength,
                startDate: startDate,
                description: trimmedDescription
            )
        }
        
        print("Custom pattern saved successfully!")
        dismiss()
    }
    
    private func deletePattern() {
        shiftManager.deleteCustomPattern()
        dismiss()
    }
    
    private func getSelectedShift() -> ShiftType? {
        guard let day = currentEditingDay, day < dayShifts.count else { return nil }
        return dayShifts[day] // 이제 Non-optional이므로 그대로 반환
    }
    
    private func handleShiftSelection(_ shift: ShiftType) {
        if let day = currentEditingDay {
            if day < dayShifts.count {
                dayShifts[day] = shift
            } else {
                // 배열 크기를 늘려서 해당 일차까지 확장 (기본값으로 주간 근무)
                while dayShifts.count <= day {
                    dayShifts.append(.주간)
                }
                dayShifts[day] = shift
            }
            currentEditingDay = nil
        }
        showingShiftSelector = false
    }
    
    private func updateDayShiftsArray(newLength: Int) {
        if newLength > dayShifts.count {
            // 주기가 늘어나면 기본값으로 슬롯 추가
            while dayShifts.count < newLength {
                dayShifts.append(.주간)
            }
        } else if newLength < dayShifts.count {
            // 주기가 줄어들면 초과하는 요소 제거
            dayShifts = Array(dayShifts.prefix(newLength))
        }
    }
}

// MARK: - Day Shift Card
struct DayShiftCard: View {
    let dayNumber: Int
    let shiftType: ShiftType // Non-optional로 변경
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text("\(dayNumber)일차")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.charcoalBlack)
                
                Spacer()
                
                Text(shiftType.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(shiftType.color)
                    .cornerRadius(6)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.charcoalBlack.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.backgroundWhite)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.mainColor, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Shift Selector View Inline
struct ShiftSelectorViewInline: View {
    let selectedShift: ShiftType? // 여전히 optional (선택되지 않은 상태일 수 있음)
    let onSelect: (ShiftType) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(ShiftType.allCases, id: \.self) { shiftType in
                        ShiftTypeCardInline(
                            shiftType: shiftType,
                            isSelected: selectedShift == shiftType
                        ) {
                            onSelect(shiftType)
                        }
                    }
                }
                .padding(20)
            }
            .background(Color.backgroundLight)
            .navigationTitle("근무 요소 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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

// MARK: - Shift Type Card Inline
struct ShiftTypeCardInline: View {
    let shiftType: ShiftType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(shiftType.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(shiftType.color)
                    .cornerRadius(12)
                
                Text(shiftType.rawValue)
                    .font(.caption)
                    .foregroundColor(.charcoalBlack)
                    .multilineTextAlignment(.center)
            }
            .padding(12)
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

// MARK: - Shift List View
struct ShiftListView: View {
    @Binding var shifts: [ShiftType]
    @Binding var currentEditingIndex: Int?
    @Binding var showingShiftSelector: Bool
    
    var body: some View {
        List {
            ForEach(Array(shifts.enumerated()), id: \.offset) { index, shift in
                ShiftElementCardInline(
                    shift: shift,
                    index: index,
                    onDelete: {
                        shifts.remove(at: index)
                    },
                    onEdit: {
                        currentEditingIndex = index
                        showingShiftSelector = true
                    }
                )
            }
            .onMove { from, to in
                shifts.move(fromOffsets: from, toOffset: to)
            }
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - Shift Element Card Inline
struct ShiftElementCardInline: View {
    let shift: ShiftType
    let index: Int
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack {
            Text("\(index + 1)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.charcoalBlack)
                .clipShape(Circle())
            
            Text(shift.rawValue)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(shift.color)
                .cornerRadius(8)
            
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.caption)
                    .foregroundColor(.charcoalBlack)
            }
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.backgroundWhite)
        .cornerRadius(8)
    }
}

// MARK: - Team Schedule View Inline
struct TeamScheduleViewInline: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let customPattern = shiftManager.settings.customPattern {
                        // 패턴 정보
                        VStack(alignment: .leading, spacing: 12) {
                            Text("패턴 정보")
                                .font(.headline)
                                .foregroundColor(.charcoalBlack)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("패턴명:")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(customPattern.name)
                                        .font(.subheadline)
                                        .foregroundColor(.charcoalBlack.opacity(0.8))
                                }
                                
                                HStack {
                                    Text("반복주기:")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text("\(customPattern.cycleLength)일")
                                        .font(.subheadline)
                                        .foregroundColor(.charcoalBlack.opacity(0.8))
                                }
                                
                                HStack {
                                    Text("시작일:")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(formatDate(customPattern.startDate))
                                        .font(.subheadline)
                                        .foregroundColor(.charcoalBlack.opacity(0.8))
                                }
                                
                                HStack {
                                    Text("소속팀:")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(shiftManager.settings.team)
                                        .font(.subheadline)
                                        .foregroundColor(.charcoalBlack.opacity(0.8))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.mainColor)
                            .cornerRadius(12)
                        }
                        
                        // 팀별 근무표
                        VStack(alignment: .leading, spacing: 12) {
                            Text("팀별 근무표")
                                .font(.headline)
                                .foregroundColor(.charcoalBlack)
                            
                            VStack(spacing: 8) {
                                ForEach(1...customPattern.cycleLength, id: \.self) { teamNumber in
                                    TeamScheduleCardInline(
                                        teamNumber: teamNumber,
                                        shifts: customPattern.dayShifts,
                                        isUserTeam: teamNumber == 1
                                    )
                                }
                            }
                        }
                    } else {
                        VStack(spacing: 16) {
                            Text("커스텀 패턴이 설정되지 않았습니다.")
                                .font(.subheadline)
                                .foregroundColor(.charcoalBlack.opacity(0.6))
                                .frame(maxWidth: .infinity)
                            
                            // 디버깅 정보 추가
                            VStack(alignment: .leading, spacing: 8) {
                                Text("현재 패턴 유형: \(shiftManager.settings.shiftPatternType.displayName)")
                                    .font(.caption)
                                    .foregroundColor(.charcoalBlack.opacity(0.5))
                                
                                Text("커스텀 패턴 존재: \(shiftManager.settings.customPattern != nil ? "예" : "아니오")")
                                    .font(.caption)
                                    .foregroundColor(.charcoalBlack.opacity(0.5))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.backgroundWhite)
                            .cornerRadius(8)
                        }
                        .padding(.vertical, 40)
                    }
                }
                .padding(20)
            }
            .background(Color.backgroundLight)
            .navigationTitle("팀근무표")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                    .foregroundColor(.charcoalBlack)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

struct TeamScheduleCardInline: View {
    let teamNumber: Int
    let shifts: [ShiftType]
    let isUserTeam: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(teamNumber)조")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.charcoalBlack)
                
                if isUserTeam {
                    Text("(내 팀)")
                        .font(.caption)
                        .foregroundColor(.pointColor)
                        .fontWeight(.medium)
                }
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(Array(shifts.enumerated()), id: \.offset) { index, shiftType in
                    VStack(spacing: 4) {
                        Text("\(index + 1)일차")
                            .font(.caption2)
                            .foregroundColor(.charcoalBlack.opacity(0.7))
                        
                        Text(shiftType.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(shiftType.color)
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(isUserTeam ? Color.pointColor.opacity(0.1) : Color.backgroundWhite)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isUserTeam ? Color.pointColor : Color.mainColor, lineWidth: isUserTeam ? 2 : 1)
        )
    }
}
