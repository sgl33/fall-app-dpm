import SwiftUI
import MapKit

/// Shows a single walking record with a map.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 15, 2023
///
struct WalkingRecordView: View {
    
    var generalData: GeneralWalkingData
    @ObservedObject var realtimeData: RealtimeWalkingDataLoader = RealtimeWalkingDataLoader()
    @State var toggleToRefresh: Bool = false
    
    var body: some View {

        ZStack {
            VStack {
                MapView(realtimeData.data.getEncodedPolyline(),
                        hazardEncountered: generalData.hazardEncountered(),
                        hazardLocation: realtimeData.data.getFinalLocation())
                
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
                            Text(realtimeData.data.getStartTime() + " - " + realtimeData.data.getEndTime())
                                .frame(width: 180, alignment: .leading)
                            Text(String(format: "%.2f mi", realtimeData.data.getDistanceTravelled()/5280))
                                .frame(width: 180, alignment: .leading)
                            Spacer()
                                .frame(height: 10)
                        }
                        
                        Spacer()
                            .frame(width: 16)
                    }
                    .background(Utilities.isDarkMode() ? Color(white: 0.1) : Color(white: 0.9))
                    .cornerRadius(12)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    Text("Reported Hazards")
                        .font(.system(size: 16))
                    
                    ScrollView(.vertical) {
                        let hazardsArr = generalData.hazardsToStringArr()
                        ForEach(hazardsArr.indices) { index in
                            Text("• " + hazardsArr[index])
                                .frame(width: 300, alignment: .leading)
                        }
                        NavigationLink(destination: EditHazardReportView(generalData: generalData,
                                                                         toggleToRefresh: $toggleToRefresh)) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit")
                            }.padding(.top, 8)
                        }
                    }
                    .frame(height: 160)
                }
                .frame(height: 300, alignment: .center)
                
                    
            }
            .onAppear {
                FirestoreHandler.loadRealtimeData(loader: realtimeData,
                                                  docNames: generalData.realtimeDocNames)
            }
            
            if realtimeData.isLoading {
                Text("Loading...")
            }
        }
        
        
        
//        ForEach(realtimeData.data.indices) { index in
//            Text(String(realtimeData.data[index].timestamp))
//        }
    }
}


