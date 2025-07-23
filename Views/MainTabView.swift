import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    
    var body: some View {
        TabView {
            MainCalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("근무")
                }
            
            ShiftTableView()
                .tabItem {
                    Image(systemName: "tablecells")
                    Text("표")
                }
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("통계")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("설정")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(ShiftManager())
    }
}
