import SwiftUI

/// Shows status
///
/// ### Usage
/// ```
/// StatusItem(active: true, activeText: "Sensor Connected", inactiveText: "Sensor Disconnected")
/// ```
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 10, 2023
///
struct StatusItem: View {
    
    var active: Bool = false
    var activeText: String
    var inactiveText: String
    
    var body: some View {
        
        HStack {
            Image(active ? "checkmark_green" : "xmark_red")
                .resizable()
                .frame(width: 14, height: 14)
            Text(active ? activeText : inactiveText)
                .foregroundColor(Color(white: 0.8))
                .font(.system(size: 14))
        }
    }
}

