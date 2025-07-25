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
                
                // 초과근무시간 섹션 - 절대 고정 위치
                VStack(spacing: 15) {
                    Text("초과근무시간")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.charcoalBlack)
                    
                    HStack {
                        TextField("시간", text: $overtimeHours)
                            .keyboardType(.numberPad)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.backgroundWhite)
                            .cornerRadius(12)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .frame(width: UIScreen.main.bounds.width * 0.7)
                        
                        Text("시간")
                            .foregroundColor(.charcoalBlack.opacity(0.7))
                        
                        Spacer()
                    }
                }
                .frame(height: 100) // 고정 높이 설정
                
                // 고정된 공간 - 휴가 설정 섹션의 최대 높이만큼 항상 확보
                VStack(spacing: 15) {
                    Text("휴가 설정")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.charcoalBlack)
                    
                    HStack {
                        Toggle("휴가로 설정", isOn: $isVacation)
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
                    Text("자원 근무 설정")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.charcoalBlack)
                    
                    HStack {
                        Toggle("자원 근무로 설정", isOn: $isVolunteerWork)
                            .toggleStyle(SwitchToggleStyle(tint: .mainColor))
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                

                
                Spacer()
                
                VStack(spacing: 15) {
                    Button("저장") {
                        saveSchedule()
                        dismiss()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button("삭제") {
                        deleteSchedule()
                        dismiss()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
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
        return shiftManager.getShiftTypesForCurrentPattern()
    }
    
    private func loadCurrentSchedule() {
        let currentTeam = shiftManager.getCurrentTeamNumber()
        
        // 팀 근무표에서 현재 사용자의 근무 타입 가져오기
        let teamShiftType = shiftManager.getCurrentUserShiftType(for: selectedDate)
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
        let currentTeam = shiftManager.getCurrentTeamNumber()
        
        // 팀 근무표와 연동: 현재 사용자의 팀 근무를 업데이트
        shiftManager.updateShiftForTeam(date: selectedDate, team: currentTeam, shiftType: selectedShiftType)
        
        // 추가 정보 (초과근무, 휴가 등)는 기존 방식으로 저장
        if let index = shiftManager.schedules.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
            shiftManager.schedules[index].overtimeHours = overtime
            shiftManager.schedules[index].isVacation = isVacation
            shiftManager.schedules[index].vacationType = isVacation ? selectedVacationType : nil
            shiftManager.schedules[index].isVolunteerWork = isVolunteerWork
        } else {
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
        print("Updated schedule for current user (team \(currentTeam)) on \(selectedDate): \(selectedShiftType.rawValue)")
    }
    
    private func deleteSchedule() {
        shiftManager.schedules.removeAll { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
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
