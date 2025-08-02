import SwiftUI

struct ContentView: View {
    @StateObject private var shiftManager = ShiftManager()
    @State private var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(shiftManager)
            } else {
                OnboardingView()
                    .environmentObject(shiftManager)
            }
        }
        .onAppear {
            checkOnboardingStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            checkOnboardingStatus()
        }
    }
    
    private func checkOnboardingStatus() {
        // UserDefaults에서 온보딩 완료 상태 확인
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
