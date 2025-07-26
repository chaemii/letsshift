import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @State private var currentStep = 0

    @State private var showingCustomPatternEdit = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 진행률 표시
                progressIndicator
                
                ScrollView {
                    VStack(spacing: 35) {
                        if currentStep == 0 {
                            // 첫 번째 단계: 환영 메시지 + 근무 패턴 설정
                            welcomeSection
                            shiftPatternSection
                        } else {
                            // 두 번째 단계: 소속 팀 설정
                            teamSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
                
                // 액션 버튼들
                actionButtons
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
            }
            .background(Color(hex: "EFF0F2"))
            .navigationBarHidden(true)
        }

        .sheet(isPresented: $showingCustomPatternEdit) {
            CustomPatternEditView()
        }
    }
    
    // MARK: - 진행률 표시
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<2, id: \.self) { index in
                Circle()
                    .fill(index <= currentStep ? Color.charcoalBlack : Color.charcoalBlack.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 30)
    }
    
    // MARK: - 환영 섹션
    private var welcomeSection: some View {
        VStack(spacing: 12) {
            Text("환영합니다! 👋")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.charcoalBlack)
            
            Text("근무 일정을 효율적으로 관리해보세요.\n먼저 근무 패턴을 설정해주세요.")
                .font(.subheadline)
                .foregroundColor(.charcoalBlack.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - 근무 패턴 섹션
    private var shiftPatternSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 섹션 헤더
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(Color(hex: "1A1A1A"))
                    .font(.title3)
                Text("근무 패턴 설정")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoalBlack)
            }
            
            // 근무 패턴 옵션들
            VStack(spacing: 12) {
                // 나만의 패턴 만들기
                Button(action: {
                    shiftManager.settings.shiftPatternType = .custom
                    // regenerateSchedule() 호출하지 않음
                }) {
                    HStack {
                        Text("나만의 패턴 만들기")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.charcoalBlack)
                        Spacer()
                        if shiftManager.settings.shiftPatternType == .custom {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.charcoalBlack)
                        }
                    }
                    .padding(16)
                    .background(shiftManager.settings.shiftPatternType == .custom ? Color.mainColor : Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(shiftManager.settings.shiftPatternType == .custom ? Color.charcoalBlack : Color.clear, lineWidth: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // 2교대
                Button(action: {
                    shiftManager.settings.shiftPatternType = .twoShift
                    shiftManager.regenerateSchedule()
                }) {
                    HStack {
                        Text("2교대")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.charcoalBlack)
                        Spacer()
                        if shiftManager.settings.shiftPatternType == .twoShift {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.charcoalBlack)
                        }
                    }
                    .padding(16)
                    .background(shiftManager.settings.shiftPatternType == .twoShift ? Color.mainColor : Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(shiftManager.settings.shiftPatternType == .twoShift ? Color.charcoalBlack : Color.clear, lineWidth: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // 3교대
                Button(action: {
                    shiftManager.settings.shiftPatternType = .threeShift
                    shiftManager.regenerateSchedule()
                }) {
                    HStack {
                        Text("3교대")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.charcoalBlack)
                        Spacer()
                        if shiftManager.settings.shiftPatternType == .threeShift {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.charcoalBlack)
                        }
                    }
                    .padding(16)
                    .background(shiftManager.settings.shiftPatternType == .threeShift ? Color.mainColor : Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(shiftManager.settings.shiftPatternType == .threeShift ? Color.charcoalBlack : Color.clear, lineWidth: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // 3조 2교대
                Button(action: {
                    shiftManager.settings.shiftPatternType = .threeTeamTwoShift
                    shiftManager.regenerateSchedule()
                }) {
                    HStack {
                        Text("3조 2교대")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.charcoalBlack)
                        Spacer()
                        if shiftManager.settings.shiftPatternType == .threeTeamTwoShift {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.charcoalBlack)
                        }
                    }
                    .padding(16)
                    .background(shiftManager.settings.shiftPatternType == .threeTeamTwoShift ? Color.mainColor : Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(shiftManager.settings.shiftPatternType == .threeTeamTwoShift ? Color.charcoalBlack : Color.clear, lineWidth: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // 4조 2교대
                Button(action: {
                    shiftManager.settings.shiftPatternType = .fourTeamTwoShift
                    shiftManager.regenerateSchedule()
                }) {
                    HStack {
                        Text("4조 2교대")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.charcoalBlack)
                        Spacer()
                        if shiftManager.settings.shiftPatternType == .fourTeamTwoShift {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.charcoalBlack)
                        }
                    }
                    .padding(16)
                    .background(shiftManager.settings.shiftPatternType == .fourTeamTwoShift ? Color.mainColor : Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(shiftManager.settings.shiftPatternType == .fourTeamTwoShift ? Color.charcoalBlack : Color.clear, lineWidth: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // 4조 3교대
                Button(action: {
                    shiftManager.settings.shiftPatternType = .fourTeamThreeShift
                    shiftManager.regenerateSchedule()
                }) {
                    HStack {
                        Text("4조 3교대")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.charcoalBlack)
                        Spacer()
                        if shiftManager.settings.shiftPatternType == .fourTeamThreeShift {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.charcoalBlack)
                        }
                    }
                    .padding(16)
                    .background(shiftManager.settings.shiftPatternType == .fourTeamThreeShift ? Color.mainColor : Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(shiftManager.settings.shiftPatternType == .fourTeamThreeShift ? Color.charcoalBlack : Color.clear, lineWidth: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // 5조 3교대
                Button(action: {
                    shiftManager.settings.shiftPatternType = .fiveTeamThreeShift
                    shiftManager.regenerateSchedule()
                }) {
                    HStack {
                        Text("5조 3교대")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.charcoalBlack)
                        Spacer()
                        if shiftManager.settings.shiftPatternType == .fiveTeamThreeShift {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.charcoalBlack)
                        }
                    }
                    .padding(16)
                    .background(shiftManager.settings.shiftPatternType == .fiveTeamThreeShift ? Color.mainColor : Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(shiftManager.settings.shiftPatternType == .fiveTeamThreeShift ? Color.charcoalBlack : Color.clear, lineWidth: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - 소속 팀 섹션
    private var teamSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 섹션 헤더
            HStack {
                Image(systemName: "person.3")
                    .foregroundColor(Color(hex: "1A1A1A"))
                    .font(.title3)
                Text("소속 팀 설정")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoalBlack)
            }
            
            // 팀 선택 옵션들
            VStack(spacing: 12) {
                ForEach(["1조", "2조", "3조", "4조", "5조"], id: \.self) { team in
                    Button(action: {
                        shiftManager.settings.team = team
                    }) {
                        HStack {
                            Text(team)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.charcoalBlack)
                            Spacer()
                            if shiftManager.settings.team == team {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.charcoalBlack)
                            }
                        }
                        .padding(16)
                        .background(shiftManager.settings.team == team ? Color.mainColor : Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(shiftManager.settings.team == team ? Color.charcoalBlack : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - 액션 버튼들
    private var actionButtons: some View {
        VStack(spacing: 15) {
            if currentStep == 0 {
                // 첫 번째 단계: 다음 버튼
                Button("다음") {
                    if shiftManager.settings.shiftPatternType == .custom {
                        // 커스텀 패턴인 경우 커스텀 패턴 설정 화면으로 이동
                        showingCustomPatternEdit = true
                    } else {
                        // 일반 패턴인 경우 다음 단계로 이동
                        withAnimation {
                            currentStep = 1
                        }
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(shiftManager.settings.shiftPatternType == .none)
                
                Button("나중에 설정하기") {
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                }
                .buttonStyle(SecondaryButtonStyle())
            } else {
                // 두 번째 단계: 시작하기 버튼
                Button("시작하기") {
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(shiftManager.settings.team.isEmpty)
                
                Button("이전") {
                    withAnimation {
                        currentStep = 0
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding(.top, 20)
    }
    

}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.charcoalBlack)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.backgroundWhite)
            .foregroundColor(.charcoalBlack)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(ShiftManager())
    }
}
