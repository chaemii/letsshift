import SwiftUI

struct ScheduleOverlayView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    
    let selectedDate: Date
    @State private var selectedShiftType: ShiftType = .휴무
    @State private var overtimeHours: String = ""
    @State private var isVacation: Bool = false
    @State private var selectedVacationType: VacationType = .연차
    @State private var isVolunteerWork: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                VStack(spacing: 15) {
                    Text(dateString)
                        .font(.headline)
                        .foregroundColor(.charcoalBlack.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                VStack(spacing: 15) {
                    Text(NSLocalizedString("select_work_type", comment: "Select work type"))
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
                
                // 초과근무시간 섹션 - 절대 고정 위치
                VStack(spacing: 15) {
                    Text(NSLocalizedString("overtime_hours", comment: "Overtime hours"))
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.charcoalBlack)
                    
                    HStack {
                        TextField(NSLocalizedString("hours_suffix", comment: "Hours"), text: $overtimeHours)
                            .keyboardType(.numberPad)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.backgroundWhite)
                            .cornerRadius(12)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .frame(width: UIScreen.main.bounds.width * 0.7)
                        
                        Text(NSLocalizedString("hours_suffix", comment: "Hours"))
                            .foregroundColor(.charcoalBlack.opacity(0.7))
                        
                        Spacer()
                    }
                }
                .frame(height: 100) // 고정 높이 설정
                
                // 고정된 공간 - 휴가 설정 섹션의 최대 높이만큼 항상 확보
                VStack(spacing: 15) {
                    Text(NSLocalizedString("vacation_settings", comment: "Vacation settings"))
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.charcoalBlack)
                    
                    HStack {
                        Toggle(NSLocalizedString("set_as_vacation", comment: "Set as vacation"), isOn: $isVacation)
                            .toggleStyle(SwitchToggleStyle(tint: .mainColor))
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 휴가 설정이 활성화될 때만 연차/특별휴가 버튼 표시
                    if isVacation {
                        HStack(spacing: 12) {
                            ForEach(VacationType.allCases, id: \.self) { vacationType in
                                Button(action: {
                                    selectedVacationType = vacationType
                                }) {
                                    HStack {
                                        Circle()
                                            .fill(selectedVacationType == vacationType ? Color(hex: "#B8DBE2") : Color.clear)
                                            .frame(width: 20, height: 20)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color(hex: "#B8DBE2"), lineWidth: 2)
                                            )
                                            .overlay(
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: 8, height: 8)
                                                    .opacity(selectedVacationType == vacationType ? 1 : 0)
                                            )
                                        
                                        Text(vacationType.rawValue)
                                            .foregroundColor(.charcoalBlack)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color.backgroundWhite)
                                    .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                
                VStack(spacing: 15) {
                    Text(NSLocalizedString("volunteer_work_settings", comment: "Volunteer work settings"))
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.charcoalBlack)
                    
                    HStack {
                        Toggle(NSLocalizedString("set_as_volunteer", comment: "Set as volunteer"), isOn: $isVolunteerWork)
                            .toggleStyle(SwitchToggleStyle(tint: .mainColor))
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                

                
                Spacer()
                
                VStack(spacing: 15) {
                    Button(NSLocalizedString("save", comment: "Save")) {
                        saveSchedule()
                        dismiss()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(NSLocalizedString("delete", comment: "Delete")) {
                        deleteSchedule()
                        dismiss()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .background(Color.backgroundLight)
            .navigationTitle(NSLocalizedString("schedule_edit", comment: "Schedule edit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("cancel", comment: "Cancel")) {
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
        let language = Locale.current.language.languageCode?.identifier ?? "ko"
        
        if language == "en" {
            formatter.dateFormat = "MMM d, yyyy (E)"
            formatter.locale = Locale(identifier: "en_US")
        } else {
            formatter.dateFormat = "yyyy년 M월 d일 (E)"
            formatter.locale = Locale(identifier: "ko_KR")
        }
        return formatter.string(from: selectedDate)
    }
    
    private func getCurrentPatternShiftTypes() -> [ShiftType] {
        return shiftManager.getShiftTypesForCurrentPattern()
    }
    
    private func loadCurrentSchedule() {
        let currentTeam = shiftManager.getCurrentTeamNumber()
        
        // 팀 근무표에서 현재 사용자의 근무 타입 가져오기 (shiftOffset 포함)
        let teamShiftType = shiftManager.getCurrentUserShiftType(for: selectedDate, shiftOffset: shiftManager.shiftOffset)
        selectedShiftType = teamShiftType
        
        // 추가 정보 (초과근무, 휴가 등)는 기존 스케줄에서 가져오기
        if let schedule = shiftManager.schedules.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
            overtimeHours = String(schedule.overtimeHours)
            isVacation = schedule.isVacation
            selectedVacationType = schedule.vacationType ?? .연차
            isVolunteerWork = schedule.isVolunteerWork
        } else {
            // 새 스케줄인 경우 기본값 설정
            overtimeHours = "0"
            isVacation = false
            selectedVacationType = .연차
            isVolunteerWork = false
        }
    }
    
    private func saveSchedule() {
        let overtime = Int(overtimeHours) ?? 0
        
        // 개인 스케줄만 업데이트 (팀 근무표는 변경하지 않음)
        if let index = shiftManager.schedules.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
            // 기존 스케줄 업데이트
            shiftManager.schedules[index].shiftType = selectedShiftType
            shiftManager.schedules[index].overtimeHours = overtime
            shiftManager.schedules[index].isVacation = isVacation
            shiftManager.schedules[index].vacationType = isVacation ? selectedVacationType : nil
            shiftManager.schedules[index].isVolunteerWork = isVolunteerWork
        } else {
            // 새 스케줄 생성
            let newSchedule = ShiftSchedule(
                date: selectedDate,
                shiftType: selectedShiftType,
                overtimeHours: overtime,
                isVacation: isVacation,
                vacationType: isVacation ? selectedVacationType : nil,
                isVolunteerWork: isVolunteerWork
            )
            shiftManager.schedules.append(newSchedule)
        }
        
        shiftManager.saveData()
        // 위젯용 개인 스케줄 데이터 저장
        shiftManager.savePersonalSchedulesForWidget()
        print("📅 ScheduleOverlayView - Updated personal schedule on \(selectedDate): \(selectedShiftType.rawValue)")
    }
    
    private func deleteSchedule() {
        // 개인 스케줄만 삭제 (팀 근무표는 변경하지 않음)
        shiftManager.schedules.removeAll { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
        shiftManager.saveData()
        // 위젯용 개인 스케줄 데이터 저장
        shiftManager.savePersonalSchedulesForWidget()
        print("📅 ScheduleOverlayView - Deleted personal schedule on \(selectedDate)")
    }
}

struct CompactShiftTypeButton: View {
    let shiftType: ShiftType
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var shiftManager: ShiftManager
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Circle()
                    .fill(shiftManager.getColor(for: shiftType))
                    .frame(width: 24, height: 24)
                
                Text(shiftType.displayName)
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
                
                Text(shiftType.displayName)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .charcoalBlack)
                
                Text("\(shiftType.workingHours)\(NSLocalizedString("hours_suffix", comment: "Hours suffix"))")
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
