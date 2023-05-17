import SwiftUI
import MapKit

/// Shows a single walking record with a map.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 15, 2023
///
struct WalkingRecordView: View {
    
    var generalData: GeneralWalkingData
    var realtimeData: RealtimeWalkingData
    
    var body: some View {

        VStack {
            MapView(realtimeData.getEncodedPolyline(),
                    hazardEncountered: generalData.hazardEncountered(),
                    hazardLocation: realtimeData.getFinalLocation())
            
            VStack {
                Spacer()
                    .frame(height: 16)
                
                // General data
                HStack {
                    Spacer()
                        .frame(width: 16)
                    
                    Image(systemName: "figure.walk.circle")
                        .resizable()
                        .frame(width:56, height: 56)
                    
                    Spacer()
                        .frame(width: 24)
                    
                    VStack {
                        Spacer()
                            .frame(height: 10)
                        Text(generalData.getDate())
                            .frame(width: 180, alignment: .leading)
                        Text(realtimeData.getStartTime() + " - " + realtimeData.getEndTime())
                            .frame(width: 180, alignment: .leading)
                        Text(String(format: "%.2f mi", realtimeData.getDistanceTravelled()/5280))
                            .frame(width: 180, alignment: .leading)
                        Spacer()
                            .frame(height: 10)
                    }
                    
                    Spacer()
                        .frame(width: 16)
                }
                .background(DarkMode.isDarkMode() ? Color(white: 0.1) : Color(white: 0.9))
                .cornerRadius(12)
                
                Spacer()
                    .frame(height: 20)
                
                Text("Reported Hazards")
                    .font(.system(size: 16))
                
                ScrollView(.vertical) {
                    let hazardsArr = generalData.hazardsToStringArr()
                    ForEach(hazardsArr.indices) { index in
                        Text("• " + hazardsArr[index])
                            .frame(width: 240, alignment: .leading)
                    }
                }
                .frame(height: 160)
            }
            .frame(height: 300, alignment: .center)
            
                
        }
        
        
//        ForEach(realtimeData.data.indices) { index in
//            Text(String(realtimeData.data[index].timestamp))
//        }
    }
}


