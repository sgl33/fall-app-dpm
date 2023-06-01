import Foundation

/// Class that stores global variables of the app as static variables, used in multiple files.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 31, 2023
///
class AppConstants {
    /// Types of hazards to be shown
    static let hazards: [String] = ["Change in Floor Levels", "Uneven Surface", "Debris or Obstacles", "Slippery", "Slope", "Poor Lighting"]
    
    /// Icons of hazards to be shown. Size must match that of `hazards`.
    static let hazardIcons: [String] = ["changes_in_floor_levels", "uneven_surface", "debris_obstacles", "slippery", "slope", "poor_lighting"]
    
    static let defaultHazardIntensity: [Int] = [0, 0, 0, 0, 0, 0]
    
    /// Hazard intensity options.
    static let optionTexts: [String] = ["None (0)", "Low (1)", "Medium (2)", "High (3)"]
    
    /// Values of hazard intensities. Size must match that of `optionTexts`.
    static let optionValues: [Int] = [0, 1, 2, 3]
}
