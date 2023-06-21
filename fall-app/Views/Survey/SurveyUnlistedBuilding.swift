import SwiftUI

/// Popup view that asks users details about a building if user selected  "Building is unlisted"
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Jun 21, 2023
///
struct SurveyUnlistedBuilding: View {
    
    @Binding var showSurvey: Bool
    @Binding var tabSelection: Int
    @State var selectedFloor: String = ""
    @State var buildingName: String = ""
    
    var body: some View {
        VStack {
            Form {
                TextField("Building Name", text: $buildingName)
                TextField("Hazard Location", text: $selectedFloor)
            }
            
            NavigationLink(destination: SurveyHazardForm(showSurvey: $showSurvey,
                                                         hazards: AppConstants.hazards, hazardIcons: AppConstants.hazardIcons,
                                                         tabSelection: $tabSelection,
                                                         buildingId: "UNLISTED__\(buildingName)",
                                                         buildingFloor: selectedFloor,
                                                         buildingHazardLocation: [0, 0])) {
                IconButtonInner(iconName: "arrow.right", buttonText: "Continue")
            }.buttonStyle(IconButtonStyle(backgroundColor: .yellow,
                                         foregroundColor: .black))
            .padding(.bottom, 24)
        }
    }
}


