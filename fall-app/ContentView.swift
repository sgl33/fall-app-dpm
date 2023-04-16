
import SwiftUI


/// Main content view for the application.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Apr 13, 2023
///
struct ContentView: View {
    
    var body: some View {
        
        TabView {
            MainView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            HistoryView()
                .tabItem {
                    Image(systemName: "scroll")
                    Text("History")
                }
            DummyView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .background(Color(UIColor.systemBackground))
                
        }
    }
    
    init() {
        // Initializes UI tab bar appearance
        let appearance: UITabBarAppearance = UITabBarAppearance()
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
