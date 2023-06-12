import Foundation
import SwiftUI
import UIKit

/// Object used to load an image.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 22, 2023
///
class ImageLoader: ObservableObject {
    
    @Published var image: UIImage = UIImage()
    
    @Published var loading: Bool = false
}
