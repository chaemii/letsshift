import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // 전체 배경색
            Color(hex: "EFF0F2")
                .ignoresSafeArea()
            
            // Main content
            TabView(selection: $selectedTab) {
                MainCalendarView()
                    .tag(0)
                
                ShiftTableView()
                    .tag(1)
                
                StatisticsView()
                    .tag(2)
                
                SettingsView()
                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Custom navigation bar
            VStack {
                Spacer()
                
                // Custom navigation bar
                HStack(spacing: 0) {
                    ForEach(0..<4, id: \.self) { index in
                        Button(action: {
                            selectedTab = index
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: getIconName(for: index))
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(selectedTab == index ? .white : .charcoalBlack)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle()
                                            .fill(selectedTab == index ? Color.charcoalBlack : Color.clear)
                                    )
                                
                                Text(getTabTitle(for: index))
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(selectedTab == index ? .charcoalBlack : .charcoalBlack.opacity(0.6))
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 100)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal, 16)
                .padding(.bottom, -20)
            }
        }
    }
    
    private func getIconName(for index: Int) -> String {
        switch index {
        case 0: return "checkmark.circle"
        case 1: return "doc.text"
        case 2: return "bell"
        case 3: return "gearshape"
        default: return "circle"
        }
    }
    
    private func getTabTitle(for index: Int) -> String {
        switch index {
        case 0: return "내스케줄"
        case 1: return "팀근무표"
        case 2: return "통계"
        case 3: return "근무설정"
        default: return ""
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(ShiftManager())
    }
}
