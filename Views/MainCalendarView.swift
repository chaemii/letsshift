import SwiftUI

struct MainCalendarView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @State private var selectedDate = Date()
    @State private var showingOverlay = false
    
    private let calendar = Calendar.current
    private let daysInWeek = ["일", "월", "화", "수", "목", "금", "토"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                // Calendar container with white background
                VStack(spacing: 0) {
                    // Month selector - 캘린더 바로 위로 이동
                    HStack {
                        Button(action: previousMonth) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14))
                                .foregroundColor(.charcoalBlack)
                        }
                        
                        Spacer()
                        
                        Text(monthYearString)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.charcoalBlack)
                        
                        Spacer()
                        
                        Button(action: nextMonth) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(.charcoalBlack)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    
                    // Day headers - 영어 대응
                    HStack(spacing: 0) {
                        ForEach(Array(daysInWeek.enumerated()), id: \.offset) { index, day in
                            Text(NSLocalizedString("day_\(getDayKey(day))", comment: "Day of week"))
                                .frame(maxWidth: .infinity)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(index == 0 ? .pointColor : index == 6 ? .mainColorDark : .charcoalBlack.opacity(0.6))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    
                    // Calendar grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                        ForEach(daysInMonth, id: \.self) { date in
                            if let date = date {
                                CalendarDayView(
                                    date: date,
                                    shiftType: getShiftType(for: date),
                                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                    isToday: calendar.isDateInToday(date),
                                    overtimeHours: getOvertimeHours(for: date),
                                    isVacation: getIsVacation(for: date),
                                    isVolunteerWork: getIsVolunteerWork(for: date)
                                ) {
                                    selectedDate = date
                                    showingOverlay = true
                                }
                            } else {
                                Color.clear
                                    .aspectRatio(1, contentMode: .fill)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 25)
                }
                .background(Color.backgroundWhite)
                .cornerRadius(16)
                .padding(.horizontal, 20)
                .padding(.top, 15)
                
                // Monthly Statistics - 영어 대응
                VStack(spacing: 20) {
                    Text(NSLocalizedString("this_month_stats", comment: "This month stats"))
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.charcoalBlack)
                    
                    HStack(spacing: 25) {
                        StatItem(
                            title: NSLocalizedString("total_work_days", comment: "Total work days"), 
                            value: "\(monthlyWorkDays)\(NSLocalizedString("days_suffix", comment: "Days suffix"))", 
                            icon: "calendar"
                        )
                        StatItem(
                            title: NSLocalizedString("total_work_hours", comment: "Total work hours"), 
                            value: "\(monthlyWorkHours)\(NSLocalizedString("hours_suffix", comment: "Hours suffix"))", 
                            icon: "clock"
                        )
                        StatItem(
                            title: getLocalizedText("야간 근무", englishText: "Night Shifts"), 
                            value: "\(monthlyNightShifts)\(getLocalizedText("일", englishText: "D"))", 
                            icon: "moon"
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
                .background(Color.backgroundWhite)
                .cornerRadius(16)
                .padding(.horizontal, 20)
                .padding(.top, 25)
                .padding(.bottom, 80) // 네비게이션 바 높이만큼 여백
                
                Spacer()
            }
            }
            .background(Color(hex: "EFF0F2"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("add_schedule", comment: "Add schedule")) {
                        showingOverlay = true
                    }
                    .foregroundColor(.charcoalBlack)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.mainColor)
                    .cornerRadius(20)
                    .font(.system(size: 12, weight: .medium))
                }
            }
        }
        .sheet(isPresented: $showingOverlay) {
            ScheduleOverlayView(selectedDate: selectedDate)
        }
    }
    
    // 요일 키 변환 함수
    private func getDayKey(_ koreanDay: String) -> String {
        switch koreanDay {
        case "일": return "sun"
        case "월": return "mon"
        case "화": return "tue"
        case "수": return "wed"
        case "목": return "thu"
        case "금": return "fri"
        case "토": return "sat"
        default: return "sun"
        }
    }
    
    // 월/년 표시를 로컬라이제이션 대응
    private var monthYearString: String {
        let formatter = DateFormatter()
        let language = Locale.current.language.languageCode?.identifier ?? "ko"
        
        if language == "en" {
            formatter.dateFormat = "yyyy. MMM"
        } else {
            formatter.dateFormat = "yyyy년 M월"
        }
        return formatter.string(from: selectedDate)
    }
    
    private var daysInMonth: [Date?] {
        let startOfMonth = calendar.startOfMonth(for: selectedDate)
        
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 0
        
        var days: [Date?] = []
        
        // Add empty cells for days before the first day of the month
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add all days in the month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func getShiftType(for date: Date) -> ShiftType {
        return shiftManager.getCurrentUserShiftType(for: date, shiftOffset: shiftManager.shiftOffset)
    }
    
    private func getOvertimeHours(for date: Date) -> Int {
        return shiftManager.schedules.first { calendar.isDate($0.date, inSameDayAs: date) }?.overtimeHours ?? 0
    }
    
    private func getIsVacation(for date: Date) -> Bool {
        return shiftManager.schedules.first { calendar.isDate($0.date, inSameDayAs: date) }?.isVacation ?? false
    }
    
    private func getIsVolunteerWork(for date: Date) -> Bool {
        return shiftManager.schedules.first { calendar.isDate($0.date, inSameDayAs: date) }?.isVolunteerWork ?? false
    }
    
    // Monthly statistics
    private var monthlyWorkDays: Int {
        let startOfMonth = calendar.startOfMonth(for: selectedDate)
        let endOfMonth = calendar.endOfMonth(for: selectedDate)
        
        return shiftManager.schedules.filter { schedule in
            let scheduleDate = schedule.date
            return scheduleDate >= startOfMonth && scheduleDate <= endOfMonth && 
                   schedule.shiftType != .휴무 && schedule.shiftType != .비번
        }.count
    }
    
    private var monthlyWorkHours: Int {
        let startOfMonth = calendar.startOfMonth(for: selectedDate)
        let endOfMonth = calendar.endOfMonth(for: selectedDate)
        
        return shiftManager.schedules.filter { schedule in
            let scheduleDate = schedule.date
            return scheduleDate >= startOfMonth && scheduleDate <= endOfMonth
        }.reduce(0) { $0 + $1.shiftType.workingHours + $1.overtimeHours }
    }
    
    private var monthlyNightShifts: Int {
        let startOfMonth = calendar.startOfMonth(for: selectedDate)
        let endOfMonth = calendar.endOfMonth(for: selectedDate)
        
        return shiftManager.schedules.filter { schedule in
            let scheduleDate = schedule.date
            return scheduleDate >= startOfMonth && scheduleDate <= endOfMonth && 
                   (schedule.shiftType == .야간 || schedule.shiftType == .심야)
        }.count
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

struct CalendarDayView: View {
    let date: Date
    let shiftType: ShiftType
    let isSelected: Bool
    let isToday: Bool
    let overtimeHours: Int
    let isVacation: Bool
    let isVolunteerWork: Bool
    let action: () -> Void
    @EnvironmentObject var shiftManager: ShiftManager
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // Date number - 고정 높이 설정
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 14, weight: isToday ? .semibold : .regular))
                    .foregroundColor(textColor)
                    .frame(height: 20)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                // Shift type label - 고정 높이 설정
                Text(shiftType.displayName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(getShiftTypeTextColor())
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(getShiftTypeBackground())
                    .cornerRadius(4)
                    .frame(height: 18)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                // Overtime indicator - 고정 높이 설정
                if overtimeHours > 0 {
                    Text("+\(overtimeHours)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.pointColor)
                        .frame(height: 16)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    // 빈 공간으로 높이 유지
                    Color.clear
                        .frame(height: 16)
                }
                
                // Vacation indicator - 고정 높이 설정
                if isVacation {
                    Text(NSLocalizedString("vacation", comment: "Vacation"))
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.pointColor)
                        .frame(height: 14)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if isVolunteerWork {
                    Text(NSLocalizedString("volunteer_work", comment: "Volunteer work"))
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.pointColor)
                        .frame(height: 14)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    // 빈 공간으로 높이 유지
                    Color.clear
                        .frame(height: 14)
                }
                
                // 남은 공간을 채우는 Spacer
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(backgroundColor)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var backgroundColor: Color {
        if isToday {
            return .mainColor // #D5E7EB
        } else if isSelected {
            return .mainColor
        } else {
            return .backgroundWhite
        }
    }
    
    private var textColor: Color {
        if isToday {
            return .charcoalBlack
        } else if isSelected {
            return .charcoalBlack
        } else {
            return .charcoalBlack.opacity(0.7)
        }
    }
    
    private func getShiftTypeTextColor() -> Color {
        return .white
    }
    
    private func getShiftTypeBackground() -> Color {
        return shiftManager.getColor(for: shiftType)
    }
}



struct MainCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        MainCalendarView()
            .environmentObject(ShiftManager())
    }
}
