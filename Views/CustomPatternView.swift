import SwiftUI

struct CustomPatternView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    
    @State private var patternName: String = ""
    @State private var selectedShifts: [ShiftType] = []
    @State private var cycleLength: Int = 7
    @State private var description: String = ""
    @State private var showingShiftSelector = false
    @State private var currentEditingIndex: Int?
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
                            Stepper("", value: $cycleLength, in: 2...14)
                                .labelsHidden()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.backgroundWhite)
                        .cornerRadius(12)
                        .frame(height: 50)
                    }
                    
                    // 근무 요소 선택
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("근무 요소")
                                .font(.headline)
                                .foregroundColor(.charcoalBlack)
                            Spacer()
                            Button("추가") {
                                showingShiftSelector = true
                            }
                            .font(.subheadline)
                            .foregroundColor(.mainColorButton)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.mainColor)
                            .cornerRadius(8)
                        }
                        
                        if selectedShifts.isEmpty {
                            Text("근무 요소를 추가해주세요")
                                .font(.subheadline)
                                .foregroundColor(.charcoalBlack.opacity(0.6))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(Color.backgroundLight)
                                .cornerRadius(12)
                        } else {
                            LazyVStack(spacing: 8) {
                                ForEach(Array(selectedShifts.enumerated()), id: \.offset) { index, shift in
                                    ShiftElementCard(
                                        shift: shift,
                                        index: index,
                                        onDelete: {
                                            selectedShifts.remove(at: index)
                                        },
                                        onMove: { fromIndex, toIndex in
                                            let item = selectedShifts.remove(at: fromIndex)
                                            selectedShifts.insert(item, at: toIndex)
                                        }
                                    )
                                }
                            }
                        }
                    }
                    
                    // 설명 입력 (선택사항)
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
                    
                    Spacer(minLength: 30)
                    
                    // 저장 버튼
                    Button("패턴 저장") {
                        saveCustomPattern()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(patternName.isEmpty || selectedShifts.isEmpty)
                    .opacity(patternName.isEmpty || selectedShifts.isEmpty ? 0.6 : 1.0)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(hex: "EFF0F2"))
            .navigationTitle(isEditing ? "패턴 편집" : "나만의 근무 패턴")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(.charcoalBlack)
                }
                
                if isEditing {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("삭제") {
                            shiftManager.deleteCustomPattern()
                            dismiss()
                        }
                        .foregroundColor(.pointColor)
                    }
                }
            }
            .sheet(isPresented: $showingShiftSelector) {
                ShiftSelectorView(selectedShifts: $selectedShifts)
            }
            .onAppear {
                loadExistingPattern()
            }
        }
    }
    
    private func loadExistingPattern() {
        if let existingPattern = shiftManager.settings.customPattern {
            isEditing = true
            patternName = existingPattern.name
            selectedShifts = existingPattern.shifts
            cycleLength = existingPattern.cycleLength
            description = existingPattern.description
        }
    }
    
    private func saveCustomPattern() {
        print("=== CustomPatternView saveCustomPattern ===")
        print("Pattern Name: \(patternName)")
        print("Selected Shifts: \(selectedShifts)")
        print("Cycle Length: \(cycleLength)")
        print("Description: \(description)")
        print("Is Editing: \(isEditing)")
        
        if isEditing {
            let updatedPattern = CustomShiftPattern(
                name: patternName,
                shifts: selectedShifts,
                cycleLength: cycleLength,
                description: description
            )
            print("Updating custom pattern: \(updatedPattern)")
            shiftManager.updateCustomPattern(updatedPattern)
        } else {
            print("Creating new custom pattern")
            shiftManager.createCustomPattern(
                name: patternName,
                shifts: selectedShifts,
                cycleLength: cycleLength,
                description: description
            )
        }
        
        // 온보딩 완료 처리
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        print("Onboarding completed - hasCompletedOnboarding set to true")
        
        print("Dismissing view")
        dismiss()
    }
}

struct ShiftElementCard: View {
    let shift: ShiftType
    let index: Int
    let onDelete: () -> Void
    let onMove: (Int, Int) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 순서 표시
            Text("\(index + 1)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color.charcoalBlack)
                .clipShape(Circle())
            
            // 근무 타입 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(shift.rawValue)
                    .font(.headline)
                    .foregroundColor(.charcoalBlack)
                Text(shift.timeRange)
                    .font(.caption)
                    .foregroundColor(.charcoalBlack.opacity(0.7))
            }
            
            Spacer()
            
            // 색상 표시
            Circle()
                .fill(shift.color)
                .frame(width: 16, height: 16)
            
            // 삭제 버튼
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.pointColor)
                    .font(.subheadline)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.backgroundWhite)
        .cornerRadius(12)
        .onDrag {
            NSItemProvider(object: "\(index)" as NSString)
        }
        .onDrop(of: [.text], delegate: DropViewDelegate(item: index, items: [], onMove: onMove))
    }
}

struct DropViewDelegate: DropDelegate {
    let item: Int
    let items: [Int]
    let onMove: (Int, Int) -> Void
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        // 드래그 앤 드롭 로직 구현
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}

struct ShiftSelectorView: View {
    @Binding var selectedShifts: [ShiftType]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(ShiftType.allCases, id: \.self) { shift in
                        ShiftTypeCard(
                            shift: shift,
                            isSelected: selectedShifts.contains(shift)
                        ) {
                            if selectedShifts.contains(shift) {
                                selectedShifts.removeAll { $0 == shift }
                            } else {
                                selectedShifts.append(shift)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(hex: "EFF0F2"))
            .navigationTitle("근무 요소 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                    .foregroundColor(.charcoalBlack)
                }
            }
        }
    }
}

struct ShiftTypeCard: View {
    let shift: ShiftType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Circle()
                    .fill(shift.color)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: isSelected ? "checkmark" : "")
                            .foregroundColor(.white)
                            .font(.headline)
                    )
                
                VStack(spacing: 4) {
                    Text(shift.rawValue)
                        .font(.headline)
                        .foregroundColor(.charcoalBlack)
                    
                    Text(shift.timeRange)
                        .font(.caption)
                        .foregroundColor(.charcoalBlack.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.mainColor : Color.backgroundWhite)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.mainColorButton : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.charcoalBlack)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    CustomPatternView()
        .environmentObject(ShiftManager.shared)
} 