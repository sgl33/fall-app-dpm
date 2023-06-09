import SwiftUI

/// Box for individual history records.
///
/// ### Usage
/// ```
/// RecordItem(generalData: ...)
/// ```
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 15, 2023
///
struct RecordItem: View {
    
    var generalData: GeneralWalkingData

    
    var body: some View {
        NavigationLink(destination: WalkingRecordView(generalData: generalData)) {
            HStack {
                Spacer()
                    .frame(width: 24);
                
                HStack {
                    // Text
                    VStack {
                        Spacer()
                            .frame(height: 8);
                        
                        Text(generalData.timestampToString())
                            .frame(width: 285, alignment: .leading)
                        
                        let hazardsArr = generalData.hazardsToStringArr();
                        ForEach(hazardsArr.indices) { index in
                            Text("• " + hazardsArr[index])
                                .frame(width: 285, alignment: .leading)
                        }
                        
                        Spacer()
                            .frame(height: 8);
                    }
                    
                    // > symbol
                    Image(systemName: "greaterthan")
                        .resizable()
                        .frame(width: 6, height: 12)
                        .foregroundColor(Color(white: 0.5))
                }
                .frame(width: 340)
                .background(darkMode() ? Color(white: 0.1) : Color(white: 0.9))
                .cornerRadius(12)
                .padding(.bottom, 8)
                
                Spacer()
                    .frame(width: 24);
            }
            
        }
        .foregroundColor(darkMode() ? .white : .black)
        
        
    }
    
    /// Detects if dark mode is enabled or not.
    func darkMode() -> Bool {
        return UITraitCollection.current.userInterfaceStyle == .dark
    }
}