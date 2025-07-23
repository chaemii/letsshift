import SwiftUI

struct ScheduleOverlayView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    
    let selectedDate: Date
    @State private var selectedShiftType: ShiftType = .휴무
    @State private var overtimeHours: String = ""
    @State private var isVacation: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                VStack(spacing: 15) {
                    Text("일정 수정")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoalBlack)
                    
                    Text(dateString)
                        .font(.headline)
                        .foregroundColor(.charcoalBlack.opacity(0.7))
                }
                
                VStack(spacing: 15) {
                    Text("근무 유형 선택")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.charcoalBlack)
                    
                    // Horizontal shift type selection - 현재 패턴의 근무 유형만 표시
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(getCurrentPatternShiftTypes(), id: \.self) { shiftType in
                                CompactShiftTypeButton(
                                    shiftType: shiftType,
                                    isSelected: selectedShiftType == shiftType
                                ) {
                                    selectedShiftType = shiftType
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                VStack(spacing: 15) {
                    Text("초과근무시간")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.charcoalBlack)
                    
                    HStack {
                        TextField("시간", text: $overtimeHours)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .background(Color.backgroundWhite)
                        
                        Text("시간")
                            .foregroundColor(.charcoalBlack.opacity(0.7))
                    }
                }
                
                VStack(spacing: 15) {
                    Text("휴가 여부")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.charcoalBlack)
                    
                    HStack {
                        Toggle("휴가로 설정", isOn: $isVacation)
                            .toggleStyle(SwitchToggleStyle(tint: .mainColor))
                        
                        Spacer()
                    }
                }
                

                
                Spacer()
                
                VStack(spacing: 15) {
                    Button("저장") {
                        saveSchedule()
                        dismiss()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Button("삭제") {
                        deleteSchedule()
                        dismiss()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
            .padding()
            .background(Color.backgroundLight)
            .navigationTitle("일정 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(.charcoalBlack)
                }
            }
            .onAppear {
                loadCurrentSchedule()
            }
        }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: selectedDate)
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
    
    private func loadCurrentSchedule() {
        if let schedule = shiftManager.schedules.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
            selectedShiftType = schedule.shiftType
            overtimeHours = String(schedule.overtimeHours)
            isVacation = schedule.isVacation
        }
    }
    
    private func saveSchedule() {
        let overtime = Int(overtimeHours) ?? 0
        
        if let index = shiftManager.schedules.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
            shiftManager.schedules[index].shiftType = selectedShiftType
            shiftManager.schedules[index].overtimeHours = overtime
            shiftManager.schedules[index].isVacation = isVacation
        } else {
            let newSchedule = ShiftSchedule(
                date: selectedDate,
                shiftType: selectedShiftType,
                overtimeHours: overtime,
                isVacation: isVacation
            )
            shiftManager.schedules.append(newSchedule)
        }
        
        shiftManager.saveData()
    }
    
    private func deleteSchedule() {
        shiftManager.schedules.removeAll { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
}

struct CompactShiftTypeButton: View {
    let shiftType: ShiftType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Circle()
                    .fill(shiftType.color)
                    .frame(width: 24, height: 24)
                
                Text(shiftType.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .charcoalBlack)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 60, height: 60)
            .background(isSelected ? Color.charcoalBlack : Color.backgroundWhite)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ShiftTypeSelectionCard: View {
    let shiftType: ShiftType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Circle()
                    .fill(Color(shiftType.color))
                    .frame(width: 40, height: 40)
                
                Text(shiftType.rawValue)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .charcoalBlack)
                
                Text("\(shiftType.workingHours)시간")
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .charcoalBlack.opacity(0.7))
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.charcoalBlack : Color.backgroundLight)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
