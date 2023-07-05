import SwiftUI
import UIKit

/// View to modify settings of the application.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Jun 21, 2023
///
struct SettingsView: View {
    
    /// Minimum time required for walking detection to trigger.
    /// For example, if this is 45, users must walk for at least 45 seconds continuously for recording to begin.
    /// Same thing for automatically ending the recording.
    @AppStorage("walkingDetectionSensitivity")
    var walkingDetectionSensitivity: Int = 45
    
    /// Receive walking detection notifications
    /// Used in`MetaWearManager`.
    @AppStorage("receiveWalkingDetectionNotifications")
    var receiveWalkingDetectionNotifications: Bool = true
    
    /// Receive error notifications such as "sensor unexpectedly disconnected".
    @AppStorage("receiveErrorNotifications")
    var receiveErrorNotifications: Bool = true
    
    /// Some variable for testing purposes.
    @State var test: String = ""
    @State var testBool: Bool = false

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
                        Text("Testing Only (5s)").tag(5)
                        Text("Very High (15s)").tag(15)
                        Text("High (30s)").tag(30)
                        Text("Medium (45s)").tag(45)
                        Text("Low (60s)").tag(60)
                        Text("Very Low (90s)").tag(90)
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
                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                Section(header: Text("App Info"),
                        footer: Text("Version " + (appVersion ?? "?"))) {
                    NavigationLink("About SafeSteps") {
                        WebView(url: URL(string: "http://\(AppConstants.serverAddress)/\(AppConstants.serverPath)/safesteps.html"))
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    NavigationLink("Help & Support") {
                        WebView(url: URL(string: "http://\(AppConstants.serverAddress)/\(AppConstants.serverPath)/guide.html"))
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    NavigationLink("Privacy Policy") {
                        WebView(url: URL(string: "http://\(AppConstants.serverAddress)/\(AppConstants.serverPath)/privacy-policy.html"))
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
                
                // Quit App
                Section(header: Text("Quit"),
                        footer: Text("This will disable walking detection and location tracking until you open the app again.")) {
                    Button("Quit App") {
                        exit(0)
                    }
                }
                
                // Test
                Section(header: Text("For Testing")) {
                    Button("Send Request") {
                        testServerCall()
                    }
                    NavigationLink(destination: OnboardingView(userOnboarded: $testBool)) {
                        Text("OnboardingView")
                    }
                }
            } // form
            .navigationTitle(Text("Settings"))
        }
    } // NavigationView
    
    /// Test server call
    func testServerCall() {
        let url = URL(string: "\(AppConstants.getUrl())/calculate/15")!

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            test = String(data: data, encoding: .utf8)!
            print(test)
        }

        task.resume()

    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
