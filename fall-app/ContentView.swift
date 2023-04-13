//
//  ContentView.swift
//  fall-app
//
//  Created by Seung-Gu Lee on 4/6/23.
//

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
        }
    }
    
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
