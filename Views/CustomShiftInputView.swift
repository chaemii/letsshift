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
                    Text(NSLocalizedString("custom_shift_input", comment: "Custom shift input"))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(NSLocalizedString("custom_shift_input_description", comment: "Custom shift input description"))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 15) {
                    DatePicker(NSLocalizedString("select_date", comment: "Select date"), selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                    
                    Picker(NSLocalizedString("work_type", comment: "Work type"), selection: $selectedShiftType) {
                        ForEach(ShiftType.allCases, id: \.self) { shiftType in
                            HStack {
                                Circle()
                                    .fill(Color(shiftType.color))
                                    .frame(width: 12, height: 12)
                                Text(shiftType.displayName)
                            }
                            .tag(shiftType)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Button(NSLocalizedString("add_schedule", comment: "Add schedule")) {
                        addSchedule()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(NSLocalizedString("added_schedules", comment: "Added schedules"))
                        .font(.headline)
                    
                    if customSchedules.isEmpty {
                        Text(NSLocalizedString("no_schedules_added", comment: "No schedules added"))
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
                
                Button(NSLocalizedString("save", comment: "Save")) {
                    saveCustomSchedules()
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(customSchedules.isEmpty)
            }
            .padding()
            .navigationTitle(NSLocalizedString("custom_shift_work", comment: "Custom shift work"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("cancel", comment: "Cancel")) {
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
                
                Text(schedule.shiftType.displayName)
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
        let language = Locale.current.language.languageCode?.identifier ?? "ko"
        
        if language == "en" {
            formatter.dateFormat = "MMM d (E)"
            formatter.locale = Locale(identifier: "en_US")
        } else {
            formatter.dateFormat = "M월 d일 (E)"
            formatter.locale = Locale(identifier: "ko_KR")
        }
        return formatter.string(from: schedule.date)
    }
}
