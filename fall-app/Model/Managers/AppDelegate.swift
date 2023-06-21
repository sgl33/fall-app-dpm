import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

/// Connects to Firebase on app launch
///
/// ### Usage
/// ```
/// struct YourApp: App {
///     @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
///     // stuff...
/// }
/// ```
///
/// ### Author & Version
/// Provided by Firebase, as of Apr. 14, 2023.
/// Modified by Seung-Gu Lee, last modified Jun. 1, 2023
///
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions:
                        [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
