import SwiftUI

struct ContentView: View {
    @StateObject private var shiftManager = ShiftManager()
    
    var body: some View {
        MainTabView()
            .environmentObject(shiftManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
