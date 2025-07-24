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
                    Text("근무 유형 설정")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoalBlack)
                    
                    Text("근무 요소의 이름과 색상을 수정할 수 있습니다")
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
                
                Button("다음") {
                    showingTeamSelection = true
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
            .background(Color.backgroundLight)
            .navigationTitle("근무 유형")
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
                        shiftManager.updateShiftName(for: selectedType, newName: editingShiftName)
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
                    
                    Text("\(shiftType.workingHours)시간")
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
    
    init(shiftType: ShiftType, shiftManager: ShiftManager) {
        self.shiftType = shiftType
        self.shiftManager = shiftManager
        self._selectedColor = State(initialValue: shiftManager.getColor(for: shiftType))
        self._customName = State(initialValue: shiftManager.getShiftName(for: shiftType))
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
                
                Spacer()
                
                Button("저장") {
                    shiftManager.updateColor(for: shiftType, newColor: selectedColor)
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
        shiftManager.updateShiftName(for: shiftType, newName: customName)
    }
}

struct ShiftTypeSelectView_Previews: PreviewProvider {
    static var previews: some View {
        ShiftTypeSelectView()
            .environmentObject(ShiftManager())
    }
}
