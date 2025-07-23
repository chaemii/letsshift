import SwiftUI

struct CustomShiftInputView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedDate = Date()
    @State private var selectedShiftType: ShiftType = .주간
    @State private var customSchedules: [ShiftSchedule] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 15) {
                    Text("비주기적 근무 입력")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("원하는 날짜에 근무 일정을 직접 입력하세요")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 15) {
                    DatePicker("날짜 선택", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                    
                    Picker("근무 유형", selection: $selectedShiftType) {
                        ForEach(ShiftType.allCases, id: \.self) { shiftType in
                            HStack {
                                Circle()
                                    .fill(Color(shiftType.color))
                                    .frame(width: 12, height: 12)
                                Text(shiftType.rawValue)
                            }
                            .tag(shiftType)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Button("일정 추가") {
                        addSchedule()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("추가된 일정")
                        .font(.headline)
                    
                    if customSchedules.isEmpty {
                        Text("아직 추가된 일정이 없습니다")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(customSchedules) { schedule in
                                    CustomScheduleRow(schedule: schedule) {
                                        removeSchedule(schedule)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                }
                
                Spacer()
                
                Button("저장") {
                    saveCustomSchedules()
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(customSchedules.isEmpty)
            }
            .padding()
            .navigationTitle("비주기적 근무")
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
    
    private func addSchedule() {
        let newSchedule = ShiftSchedule(
            date: selectedDate,
            shiftType: selectedShiftType
        )
        
        if !customSchedules.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
            customSchedules.append(newSchedule)
        }
    }
    
    private func removeSchedule(_ schedule: ShiftSchedule) {
        customSchedules.removeAll { $0.id == schedule.id }
    }
    
    private func saveCustomSchedules() {
        for schedule in customSchedules {
            if let index = shiftManager.schedules.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: schedule.date) }) {
                shiftManager.schedules[index] = schedule
            } else {
                shiftManager.schedules.append(schedule)
            }
        }
    }
}

struct CustomScheduleRow: View {
    let schedule: ShiftSchedule
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(dateString)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(schedule.shiftType.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Circle()
                .fill(Color(schedule.shiftType.color))
                .frame(width: 20, height: 20)
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: schedule.date)
    }
}
