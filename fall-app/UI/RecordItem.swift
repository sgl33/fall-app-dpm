import SwiftUI

/// Box for individual history records.
///
/// ### Usage
/// ```
/// RecordItem(record: ...)
/// ```
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Apr 15, 2023
///
struct RecordItem: View {
    
    var record: WalkingRecord
    
    var body: some View {
        HStack {
            Spacer()
                .frame(width: 24);
            
            VStack {
                Spacer()
                    .frame(height: 8);
                
                Text(record.timestampToString())
                    .frame(width: 280, alignment: .leading)
                
                let hazardsArr = record.hazardsToStringArr();
                ForEach(hazardsArr.indices) { index in
                    Text("• " + hazardsArr[index])
                        .frame(width: 280, alignment: .leading)
                }
                
                Spacer()
                    .frame(height: 8);
            }
            .frame(width: 320)
            .background(darkMode() ? Color(white: 0.12) : Color(white: 0.9))
            .cornerRadius(12)
            .padding(.bottom, 8)
            
            Spacer()
                .frame(width: 24);
        }
        
    }
    
    /// Detects if dark mode is enabled or not.
    func darkMode() -> Bool {
        return UITraitCollection.current.userInterfaceStyle == .dark
    }
}
