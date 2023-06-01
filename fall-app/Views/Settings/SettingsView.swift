//
//  SettingsView.swift
//  fall-app
//
//  Created by Seung-Gu Lee on 5/31/23.
//

import SwiftUI
import UIKit

struct SettingsView: View {
    
    @AppStorage("walkingDetectionSensitivity")
    var walkingDetectionSensitivity: Int = 45
    
    @AppStorage("receiveWalkingDetectionNotifications")
    var receiveWalkingDetectionNotifications: Bool = true
    
    @AppStorage("receiveErrorNotifications")
    var receiveErrorNotifications: Bool = true

    var body: some View {
        NavigationView {
            Form {
                // Walking Detection
                Section(header: Text("Walking Detection"),
                        footer: Text("Higher sensitivity allows the app to record short walking sessions better, but it may be less accurate. We recommend Medium (45s).")
                ) {
                    // walking sensitivity
                    Picker(selection: $walkingDetectionSensitivity,
                           label: Text("Sensitivity")) {
                        Text("Extremely High (5s)").tag(5)
                        Text("Very High (15s)").tag(15)
                        Text("High (30s)").tag(30)
                        Text("Medium (45s)").tag(45)
                        Text("Low (60s)").tag(60)
                        Text("Very Low (90s)").tag(90)
                        Text("Extremely Low (180s)").tag(180)
                    }
                }
                
                // Notifications
                Section(header: Text("Notifications"),
                        footer: Text("Notifications are only sent when the app is in the background.")) {
                    Toggle(isOn: $receiveErrorNotifications) {
                        Text("Error Messages")
                    }
                    Toggle(isOn: $receiveWalkingDetectionNotifications) {
                        Text("Walking Detection")
                    }
                }
                
                // App Info
                Section(header: Text("App Info")) {
                    NavigationLink("About SafeSteps") {
                        DummyView()
                    }
                    NavigationLink("Help & Support") {
                        DummyView()
                    }
                    NavigationLink("Terms and Conditions") {
                        DummyView()
                    }
                    NavigationLink("Privacy Policy") {
                        DummyView()
                    }
                }
                
                // Quit App
                Section(header: Text("Quit"),
                        footer: Text("This will disable walking detection and location tracking until you open the app again.")) {
                    Button("Quit App") {
                        exit(0)
                    }
                }
            } // form
            .navigationTitle(Text("Settings"))
        }
    } // NavigationView
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
