//
//  SettingsView.swift
//  fall-app
//
//  Created by Seung-Gu Lee on 5/31/23.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("walkingDetectionSensitivity")
    var walkingDetectionSensitivity: Int = 60
    
    @AppStorage("receiveWalkingDetectionNotifications")
    var receiveWalkingDetectionNotifications: Bool = false
    
    @AppStorage("receiveErrorNotifications")
    var receiveErrorNotifications: Bool = true

    var body: some View {
        NavigationView {
            Form {
                // Walking Detection
                Section(header: Text("Walking Detection"),
                        footer: Text("You can configure how sensitive you want the walking detection to be. More sensitive - records short walking sessions better. Less sensitive - more accurate detection (fewer false positives).")
                ) {
                    NavigationLink("Learn More") {
                        DummyView()
                    }
                    // walking sensitivity
                    Picker(selection: $walkingDetectionSensitivity,
                           label: Text("Detection Sensitivity")) {
                        Text("Testing Only (5s)").tag(5)
                        Text("Very High (15s)").tag(15)
                        Text("High (30s)").tag(30)
                        Text("Medium (60s)").tag(60)
                        Text("Low (120s)").tag(120)
                        Text("Very Low (180s)").tag(180)
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
            } // form
            .navigationTitle(Text("Settings"))
        }
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
