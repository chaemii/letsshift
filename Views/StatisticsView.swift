import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @State private var selectedTab: StatisticsTab = .monthly
    @State private var selectedMonth = Date()
    @State private var selectedYear = Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector - 로컬라이제이션 적용
                HStack(spacing: 0) {
                    TabButton(
                        title: NSLocalizedString("monthly", comment: "Monthly"),
                        isSelected: selectedTab == .monthly
                    ) {
                        selectedTab = .monthly
                    }
                    
                    TabButton(
                        title: NSLocalizedString("yearly", comment: "Yearly"),
                        isSelected: selectedTab == .yearly
                    ) {
                        selectedTab = .yearly
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Period selector
                HStack {
                    Button(action: previousPeriod) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14))
                            .foregroundColor(.charcoalBlack)
                    }
                    
                    Spacer()
                    
                    Text(periodString)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.charcoalBlack)
                    
                    Spacer()
                    
                    Button(action: nextPeriod) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.charcoalBlack)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                
                ScrollView {
                    VStack(spacing: 25) {
                        // 통합 통계 박스
                        StatisticsSummaryBox(selectedTab: selectedTab, selectedDate: selectedTab == .monthly ? selectedMonth : selectedYear)
                        
                        // 월간 탭에서만 요일별 근무 시간 그래프 표시
                        if selectedTab == .monthly {
                            WeeklyWorkHoursChart(selectedMonth: selectedMonth)
                        }
                        
                        // 연간 탭에서만 휴가 통계 표시
                        if selectedTab == .yearly {
                            VacationStatisticsCard(selectedYear: selectedYear)
                        }
                        
                        // 예상 급여 정보
                        if shiftManager.settings.baseSalary > 0 {
                            ExpectedSalaryCard(selectedTab: selectedTab, selectedDate: selectedTab == .monthly ? selectedMonth : selectedYear)
                        } else {
                            SalarySetupPrompt()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .padding(.bottom, 80) // 네비게이션 바 높이만큼 여백
                }
            }
            .background(Color(hex: "EFF0F2"))
        }
    }
    
    
    // 기간 표시를 로컬라이제이션 대응
    private var periodString: String {
        let formatter = DateFormatter()
        let language = Locale.current.language.languageCode?.identifier ?? "ko"
        
        if selectedTab == .monthly {
            if language == "en" {
                formatter.dateFormat = "yyyy. MMM"
            } else {
                formatter.dateFormat = "yyyy년 M월"
            }
        } else {
            if language == "en" {
                formatter.dateFormat = "yyyy"
            } else {
                formatter.dateFormat = "yyyy년"
            }
        }
        return formatter.string(from: selectedTab == .monthly ? selectedMonth : selectedYear)
    }
    
    private func previousPeriod() {
        if selectedTab == .monthly {
            if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) {
                selectedMonth = newDate
            }
        } else {
            if let newDate = Calendar.current.date(byAdding: .year, value: -1, to: selectedYear) {
                selectedYear = newDate
            }
        }
    }
    
    private func nextPeriod() {
        if selectedTab == .monthly {
            if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) {
                selectedMonth = newDate
            }
        } else {
            if let newDate = Calendar.current.date(byAdding: .year, value: 1, to: selectedYear) {
                selectedYear = newDate
            }
        }
    }
}

enum StatisticsTab {
    case monthly, yearly
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .white : .charcoalBlack)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? Color.charcoalBlack : Color.clear)
                .cornerRadius(8)
        }
    }
}

struct StatisticsSummaryBox: View {
    let selectedTab: StatisticsTab
    let selectedDate: Date
    @EnvironmentObject var shiftManager: ShiftManager
    
    var body: some View {
        VStack(spacing: 20) {
            // 통계 데이터
            let stats = getStatistics()
            
            VStack(spacing: 15) {
                HStack {
                    StatItem(title: "총 근무일", value: "\(stats.totalWorkDays)일", icon: "calendar")
                    Divider()
                    StatItem(title: "총 근무시간", value: "\(stats.totalWorkHours)시간", icon: "clock")
                }
                
                HStack {
                    StatItem(title: "야간 근무", value: "\(stats.nightShiftDays)일", icon: "moon")
                    Divider()
                    StatItem(title: "당직", value: "\(stats.dutyDays)일", icon: "house")
                }
                
                HStack {
                    StatItem(title: "평균 근무시간", value: "\(stats.averageWorkHours)시간", icon: "chart.bar")
                    Divider()
                    StatItem(title: "초과근무 시간", value: "\(stats.overtimeHours)시간", icon: "timer")
                }
                
                HStack {
                    StatItem(title: "근무율", value: "\(stats.workRate)%", icon: "percent")
                    Divider()
                    StatItem(title: "당직 시간", value: "\(stats.dutyHours)시간", icon: "clock.badge")
                }
            }
        }
        .padding(20)
        .background(Color.backgroundWhite)
        .cornerRadius(16)
    }
    
    private func getStatistics() -> (totalWorkDays: Int, totalWorkHours: Int, nightShiftDays: Int, averageWorkHours: Int, overtimeHours: Int, workRate: Int, dutyDays: Int, dutyHours: Int) {
        let schedules = getSchedulesForPeriod()
        
        let totalWorkDays = schedules.filter { $0.shiftType != .휴무 && $0.shiftType != .비번 }.count
        let totalWorkHours = schedules.reduce(0) { $0 + Int(shiftManager.getShiftWorkingHours(for: $1.shiftType)) + $1.overtimeHours }
        let nightShiftDays = schedules.filter { $0.shiftType == .야간 || $0.shiftType == .심야 }.count
        let overtimeHours = schedules.reduce(0) { $0 + $1.overtimeHours }
        
        // 당직 통계 추가
        let dutyDays = schedules.filter { $0.shiftType == .당직 }.count
        let dutyHours = schedules.filter { $0.shiftType == .당직 }.reduce(0) { $0 + Int(shiftManager.getShiftWorkingHours(for: $1.shiftType)) + $1.overtimeHours }
        
        let averageWorkHours = totalWorkDays > 0 ? totalWorkHours / totalWorkDays : 0
        
        // 근무율 계산 (전체 일수 대비 근무일 비율)
        let totalDays = selectedTab == .monthly ? 
            Calendar.current.range(of: .day, in: .month, for: selectedDate)?.count ?? 30 :
            365
        let workRate = totalDays > 0 ? Int((Double(totalWorkDays) / Double(totalDays)) * 100) : 0
        
        return (totalWorkDays, totalWorkHours, nightShiftDays, averageWorkHours, overtimeHours, workRate, dutyDays, dutyHours)
    }
    
    private func getSchedulesForPeriod() -> [ShiftSchedule] {
        let calendar = Calendar.current
        
        if selectedTab == .monthly {
            let startOfMonth = calendar.startOfMonth(for: selectedDate)
            let endOfMonth = calendar.endOfMonth(for: selectedDate)
            return shiftManager.schedules.filter { $0.date >= startOfMonth && $0.date <= endOfMonth }
        } else {
            let startOfYear = calendar.dateInterval(of: .year, for: selectedDate)?.start ?? selectedDate
            let endOfYear = calendar.dateInterval(of: .year, for: selectedDate)?.end ?? selectedDate
            return shiftManager.schedules.filter { $0.date >= startOfYear && $0.date < endOfYear }
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.mainColorButton)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.charcoalBlack)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.charcoalBlack.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

struct WeeklyWorkHoursChart: View {
    let selectedMonth: Date
    @EnvironmentObject var shiftManager: ShiftManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(NSLocalizedString("daily_work_hours", comment: "Daily work hours"))
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.charcoalBlack)
            
            VStack(spacing: 12) {
                let weeklyHours = getWeeklyHours()
                let maxHours = weeklyHours.values.max() ?? 1
                
                ForEach(Array(weeklyHours.keys.sorted()), id: \.self) { day in
                    let hours = weeklyHours[day] ?? 0
                    let percentage = maxHours > 0 ? Double(hours) / Double(maxHours) : 0
                    
                    HStack(spacing: 12) {
                        Text(day)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.charcoalBlack)
                            .frame(width: 50, alignment: .leading)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.mainColor.opacity(0.2))
                                    .frame(height: 20)
                                    .cornerRadius(10)
                                
                                Rectangle()
                                    .fill(Color.mainColorButton)
                                    .frame(width: geometry.size.width * percentage, height: 20)
                                    .cornerRadius(10)
                            }
                        }
                        .frame(height: 20)
                        
                        Text("\(hours)\(NSLocalizedString("hours_suffix", comment: "Hours suffix"))")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.charcoalBlack)
                            .frame(width: 50, alignment: .trailing)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.backgroundWhite)
        .cornerRadius(16)
    }
    
    private func getWeeklyHours() -> [String: Int] {
        var weeklyHours: [String: Int] = [:]
        let calendar = Calendar.current
        
        // 선택된 월의 모든 주에 대한 요일별 평균 계산
        let startOfMonth = calendar.startOfMonth(for: selectedMonth)
        let endOfMonth = calendar.endOfMonth(for: selectedMonth)
        
        let monthSchedules = shiftManager.schedules.filter { 
            $0.date >= startOfMonth && $0.date <= endOfMonth 
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "EEEE"
        
        for schedule in monthSchedules {
            let dayOfWeek = formatter.string(from: schedule.date)
            let totalHours = Int(shiftManager.getShiftWorkingHours(for: schedule.shiftType)) + schedule.overtimeHours
            weeklyHours[dayOfWeek, default: 0] += totalHours
        }
        
        // 주 수로 나누어 평균 계산
        let weekCount = calendar.range(of: .weekOfMonth, in: .month, for: selectedMonth)?.count ?? 4
        for key in weeklyHours.keys {
            weeklyHours[key] = weeklyHours[key]! / weekCount
        }
        
        return weeklyHours
    }
}

struct ExpectedSalaryCard: View {
    let selectedTab: StatisticsTab
    let selectedDate: Date
    @EnvironmentObject var shiftManager: ShiftManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title2)
                    .foregroundColor(.pointColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(NSLocalizedString("estimated_salary", comment: "Estimated salary"))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoalBlack)
                    
                    Text(NSLocalizedString("salary_disclaimer", comment: "Salary disclaimer"))
                        .font(.caption2)
                        .foregroundColor(.charcoalBlack.opacity(0.5))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.charcoalBlack.opacity(0.5))
            }
            
            let salaryDetails = getSalaryDetails()
            
            HStack {
                Text("\(formatCurrency(salaryDetails.totalSalary))")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoalBlack)
                
                Spacer()
                
                Text(selectedTab == .monthly ? "월 급여" : "연 급여")
                    .font(.caption)
                    .foregroundColor(.charcoalBlack.opacity(0.7))
            }
            
            // 상세 계산 항목
            VStack(spacing: 8) {
                SalaryDetailRow(title: "기본 급여", amount: salaryDetails.baseSalary)
                SalaryDetailRow(title: "야간 근무 수당", amount: salaryDetails.nightShiftBonus)
                SalaryDetailRow(title: "심야 근무 수당", amount: salaryDetails.deepNightShiftBonus)
                SalaryDetailRow(title: "초과근무 수당", amount: salaryDetails.overtimeBonus)
                
                Divider()
                
                SalaryDetailRow(title: "총 급여", amount: salaryDetails.totalSalary, isTotal: true)
            }
        }
        .padding(20)
        .background(Color.backgroundWhite)
        .cornerRadius(16)
    }
    
    private func getSalaryDetails() -> (baseSalary: Double, nightShiftBonus: Double, deepNightShiftBonus: Double, overtimeBonus: Double, totalSalary: Double) {
        let schedules = getSchedulesForPeriod()
        
        var baseSalary: Double = 0
        var nightShiftBonus: Double = 0
        var deepNightShiftBonus: Double = 0
        var overtimeBonus: Double = 0
        
        // 시급 계산 (기본급 ÷ 209)
        let hourlyWage = shiftManager.settings.baseSalary / 209.0
        
        for schedule in schedules {
            let overtimeHours = Double(schedule.overtimeHours)
            
            switch schedule.shiftType {
            case .주간:
                // 주간근무: 09:00~18:00 (9시간) - 1.0배
                baseSalary += 9.0 * hourlyWage * 1.0
                
            case .야간:
                // 야간근무: 18:00~23:00 (5시간) - 1.5배
                baseSalary += 5.0 * hourlyWage * 1.0
                nightShiftBonus += 5.0 * hourlyWage * (shiftManager.settings.nightShiftRate - 1.0)
                
            case .심야:
                // 심야근무: 23:00~익일 07:00 (8시간) - 2.0배
                baseSalary += 8.0 * hourlyWage * 1.0
                deepNightShiftBonus += 8.0 * hourlyWage * (shiftManager.settings.deepNightShiftRate - 1.0)
                
            case .당직:
                // 당직근무: 24시간 대기 (4시간 실제근무 가정) - 1.0배
                baseSalary += 4.0 * hourlyWage * 1.0
                
            case .오후:
                // 오후근무: 주간과 동일하게 처리
                baseSalary += 9.0 * hourlyWage * 1.0
                
            case .휴무, .비번:
                // 휴무, 비번: 무급
                break
            }
            
            // 초과근무 수당
            if overtimeHours > 0 {
                overtimeBonus += overtimeHours * hourlyWage * (shiftManager.settings.overtimeRate - 1.0)
            }
        }
        
        let totalSalary = baseSalary + nightShiftBonus + deepNightShiftBonus + overtimeBonus
        
        return (baseSalary, nightShiftBonus, deepNightShiftBonus, overtimeBonus, totalSalary)
    }
    
    private func getSchedulesForPeriod() -> [ShiftSchedule] {
        let calendar = Calendar.current
        
        if selectedTab == .monthly {
            let startOfMonth = calendar.startOfMonth(for: selectedDate)
            let endOfMonth = calendar.endOfMonth(for: selectedDate)
            return shiftManager.schedules.filter { $0.date >= startOfMonth && $0.date <= endOfMonth }
        } else {
            let startOfYear = calendar.dateInterval(of: .year, for: selectedDate)?.start ?? selectedDate
            let endOfYear = calendar.dateInterval(of: .year, for: selectedDate)?.end ?? selectedDate
            return shiftManager.schedules.filter { $0.date >= startOfYear && $0.date < endOfYear }
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "KRW"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "₩0"
    }
}

struct SalaryDetailRow: View {
    let title: String
    let amount: Double
    let isTotal: Bool
    
    init(title: String, amount: Double, isTotal: Bool = false) {
        self.title = title
        self.amount = amount
        self.isTotal = isTotal
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: isTotal ? .bold : .medium))
                .foregroundColor(.charcoalBlack)
            
            Spacer()
            
            Text(formatCurrency(amount))
                .font(.system(size: 14, weight: isTotal ? .bold : .medium))
                .foregroundColor(.charcoalBlack)
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "KRW"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "₩0"
    }
}

struct VacationStatisticsCard: View {
    let selectedYear: Date
    @EnvironmentObject var shiftManager: ShiftManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(NSLocalizedString("annual_vacation_status", comment: "Annual vacation status"))
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.charcoalBlack)
            
            let year = Calendar.current.component(.year, from: selectedYear)
            let totalVacationDays = shiftManager.settings.annualVacationDays
            let usedVacationDays = shiftManager.getUsedVacationDays(for: year)
            let remainingVacationDays = shiftManager.getRemainingVacationDays(for: year)
            
            VStack(spacing: 15) {
                VacationStatRow(title: NSLocalizedString("total_annual_leave", comment: "Total annual leave"), value: "\(totalVacationDays)\(NSLocalizedString("days_suffix", comment: "Days suffix"))", icon: "calendar.badge.plus")
                VacationStatRow(title: NSLocalizedString("used_annual_leave", comment: "Used annual leave"), value: "\(usedVacationDays)\(NSLocalizedString("days_suffix", comment: "Days suffix"))", icon: "calendar.badge.checkmark")
                VacationStatRow(title: NSLocalizedString("remaining_annual_leave", comment: "Remaining annual leave"), value: "\(remainingVacationDays)\(NSLocalizedString("days_suffix", comment: "Days suffix"))", icon: "calendar.badge.clock")
            }
            
            // 월별 휴가 사용 현황
            VStack(alignment: .leading, spacing: 15) {
                Text(NSLocalizedString("monthly_vacation_usage", comment: "Monthly vacation usage"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.charcoalBlack)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                    ForEach(1...12, id: \.self) { month in
                        let monthlyVacations = shiftManager.getVacationDaysByMonth(for: year)[month] ?? 0
                        if monthlyVacations > 0 {
                            VStack(spacing: 5) {
                                Text("\(month)\(NSLocalizedString("month_suffix", comment: "Month suffix"))")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.charcoalBlack.opacity(0.7))
                                
                                Text("\(monthlyVacations)\(NSLocalizedString("days_suffix", comment: "Days suffix"))")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.pointColor)
                            }
                            .padding(8)
                            .background(Color.backgroundWhite)
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.backgroundWhite)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct VacationStatRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.mainColorButton)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.charcoalBlack)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.charcoalBlack)
        }
    }
}

struct SalarySetupPrompt: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 40))
                .foregroundColor(.charcoalBlack.opacity(0.5))
            
            Text(NSLocalizedString("setup_salary_info", comment: "Setup salary info"))
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.charcoalBlack)
            
            Text(NSLocalizedString("setup_salary_description", comment: "Setup salary description"))
                .font(.caption)
                .foregroundColor(.charcoalBlack.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(30)
        .background(Color.backgroundWhite)
        .cornerRadius(16)
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
            .environmentObject(ShiftManager())
    }
}