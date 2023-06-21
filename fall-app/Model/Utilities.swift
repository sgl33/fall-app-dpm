
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
    
    static func deviceId() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
}


extension Date {
    /// Returns 00:00:00 of today as a `Date` object
    /// Usage: `Date().startOfDay`
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}

extension CLLocationCoordinate2D {
    /// Returns the distance between two coordinates in meters.
    func distance(to: CLLocationCoordinate2D) -> CLLocationDistance {
        MKMapPoint(self).distance(to: MKMapPoint(to))
    }

}
