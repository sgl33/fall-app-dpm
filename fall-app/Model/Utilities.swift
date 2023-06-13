
import Foundation
import SwiftUI

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
    
    static func deviceId() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}
