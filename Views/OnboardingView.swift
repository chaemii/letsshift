import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @State private var currentStep = 0
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 80))
                    .foregroundColor(.mainColorButton)
                
                Text("교대근무 캘린더")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoalBlack)
                
                Text("근무 일정을 쉽게 관리하세요")
                    .font(.title3)
                    .foregroundColor(.charcoalBlack.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                Button("근무 유형 선택하기") {
                    currentStep = 1
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("나중에 설정하기") {
                    // Skip onboarding
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            
            Spacer()
        }
        .padding()
        .background(Color.backgroundLight)
        .sheet(isPresented: .constant(currentStep == 1)) {
            ShiftTypeSelectView()
                .environmentObject(shiftManager)
        }
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
