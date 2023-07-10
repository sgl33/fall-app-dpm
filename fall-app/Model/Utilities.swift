import Foundation
import SwiftUI
import CoreLocation
import MapKit

/// Contains useful general functions for the app
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 31, 2023
///
class Utilities {
    /// Detects if dark mode is enabled or not.
    static func isDarkMode() -> Bool {
        return UITraitCollection.current.userInterfaceStyle == .dark
    }
    
    /// Returns device ID string
    static func deviceId() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
}


