//
//  fall_appApp.swift
//  fall-app
//
//  Created by Seung-Gu Lee on 4/6/23.
//

import SwiftUI

@main
struct fall_appApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
