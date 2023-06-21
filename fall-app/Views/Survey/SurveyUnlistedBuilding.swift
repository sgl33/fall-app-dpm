//
//  SurveyUnlistedBuilding.swift
//  fall-app
//
//  Created by Seung-Gu Lee on 6/21/23.
//

import SwiftUI

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


