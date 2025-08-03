import SwiftUI

struct ShiftTypeSelectView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    @State private var showingTeamSelection = false
    @State private var showingColorPicker = false
    @State private var selectedShiftType: ShiftType?
    @State private var editingShiftName = ""
    @State private var showingNameEdit = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Text(NSLocalizedString("shift_type_setting", comment: "Shift type setting"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoalBlack)
                    
                    Text(NSLocalizedString("shift_element_edit_description", comment: "Shift element edit description"))
                        .font(.body)
                        .foregroundColor(.charcoalBlack.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                
                // Show all shift types with edit functionality
                VStack(spacing: 15) {
                    ForEach(ShiftType.allCases, id: \.self) { shiftType in
                        ShiftTypeEditCard(
                            shiftType: shiftType,
                            shiftManager: shiftManager,
                            onColorTap: {
                                selectedShiftType = shiftType
                                showingColorPicker = true
                            },
                            onNameTap: {
                                selectedShiftType = shiftType
                                editingShiftName = shiftManager.getShiftName(for: shiftType)
                                showingNameEdit = true
                            }
                        )
                    }
                }
                
                Spacer()
                
                Button(NSLocalizedString("next", comment: "Next button")) {
                    showingTeamSelection = true
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
            .background(Color.backgroundLight)
            .navigationTitle(NSLocalizedString("shift_type", comment: "Shift type"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(.charcoalBlack)
                }
            }
            .sheet(isPresented: $showingTeamSelection) {
                TeamSelectView()
                    .environmentObject(shiftManager)
            }
            .sheet(isPresented: $showingColorPicker) {
                if let selectedType = selectedShiftType {
                    ColorPickerView(
                        shiftType: selectedType,
                        shiftManager: shiftManager
                    )
                }
            }
            .alert("근무 요소 이름 수정", isPresented: $showingNameEdit) {
                TextField("근무 요소 이름", text: $editingShiftName)
                Button("취소", role: .cancel) { }
                Button("저장") {
                    if let selectedType = selectedShiftType {
                        shiftManager.updateShiftName(editingShiftName, for: selectedType)
                    }
                }
            } message: {
                Text("근무 요소의 이름을 입력해주세요")
            }
        }
    }
}

struct ShiftTypeEditCard: View {
    let shiftType: ShiftType
    let shiftManager: ShiftManager
    let onColorTap: () -> Void
    let onNameTap: () -> Void
    
    var body: some View {
        HStack {
            // Color circle (tappable)
            Button(action: onColorTap) {
                Circle()
                    .fill(shiftManager.getColor(for: shiftType))
                    .frame(width: 30, height: 30)
                    .overlay(
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(.white)
                            .font(.caption)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Shift name (tappable)
            Button(action: onNameTap) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(shiftManager.getShiftName(for: shiftType))
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.charcoalBlack)
                    
                    Text("\(shiftType.workingHours)\(NSLocalizedString("hours_unit", comment: "Hours unit"))")
                        .font(.caption)
                        .foregroundColor(.charcoalBlack.opacity(0.7))
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Edit icon
            Image(systemName: "pencil")
                .foregroundColor(.charcoalBlack.opacity(0.5))
                .font(.caption)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(Color.backgroundWhite)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct ColorPickerView: View {
    let shiftType: ShiftType
    let shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedColor: Color
    @State private var customName: String = ""
    @State private var showingNameEditor = false
    @State private var startHour: Int
    @State private var startMinute: Int
    @State private var endHour: Int
    @State private var endMinute: Int
    
    init(shiftType: ShiftType, shiftManager: ShiftManager) {
        self.shiftType = shiftType
        self.shiftManager = shiftManager
        self._selectedColor = State(initialValue: shiftManager.getColor(for: shiftType))
        self._customName = State(initialValue: shiftManager.getShiftName(for: shiftType))
        
        let currentTime = shiftManager.getShiftTime(for: shiftType)
        self._startHour = State(initialValue: currentTime.startHour)
        self._startMinute = State(initialValue: currentTime.startMinute)
        self._endHour = State(initialValue: currentTime.endHour)
        self._endMinute = State(initialValue: currentTime.endMinute)
    }
    
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
                        Text("\(shiftManager.getShiftName(for: shiftType))")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.charcoalBlack)
                        
                        Text("근무 요소 이름 및 색상 수정")
                            .font(.caption)
                            .foregroundColor(.charcoalBlack.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        customName = shiftManager.getShiftName(for: shiftType)
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
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
                        ForEach(Array((customColors + systemColors).enumerated()), id: \.offset) { index, colorOption in
                            Circle()
                                .fill(colorOption)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == colorOption ? Color.mainColorButton : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    selectedColor = colorOption
                                }
                        }
                    }
                }
                
                // 시간 수정 섹션
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
                
                Spacer()
                
                Button("저장") {
                    shiftManager.updateColor(for: shiftType, newColor: selectedColor)
                    
                    // 시간 업데이트
                    let newShiftTime = ShiftTime(
                        startHour: startHour,
                        startMinute: startMinute,
                        endHour: endHour,
                        endMinute: endMinute
                    )
                    shiftManager.updateShiftTime(newShiftTime, for: shiftType)
                    
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
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
    
    // 근무 시간 계산 함수
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
        shiftManager.updateShiftName(customName, for: shiftType)
    }
}

struct ShiftTypeSelectView_Previews: PreviewProvider {
    static var previews: some View {
        ShiftTypeSelectView()
            .environmentObject(ShiftManager())
    }
}
