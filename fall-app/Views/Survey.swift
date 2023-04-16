import SwiftUI

/// Popup view that asks users if they experienced fall risk.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Apr 15, 2023
///
struct Survey1: View {
    
    @Binding var showPopup1: Bool
    @State var showPopup2: Bool = false
    
    /// MODIFY ME!! Types of hazards to be shown
    let hazards: [String] = ["Change in Floor Levels", "Debris or Obstacles", "Poor Lighting", "Slippery", "Slope", "Uneven Surface"]
    
    /// Icons of hazards to be shown. Size must match that of `hazards`.
    let hazardIcons: [String] = ["changes_in_floor_levels", "debris_obstacles", "poor_lighting", "slippery", "slope", "uneven_surface"]
    
    /// Intensity for each hazards. Default value = 0. Size must match that of `hazards`.
    @State private var intensity: [Int] = [0, 0, 0, 0, 0, 0];
    
    
    var body: some View {
        VStack {
            // Header
            Text("Recording Complete!")
                .fontWeight(.bold)
                .font(.system(size: 24))
                .padding(.bottom, -4)
            Text("Did you experience fall risk?")
            
            // Report Hazard
            Button(action: {
                showPopup2 = true
            }) {
                IconButtonInner(iconName: "exclamationmark.triangle", buttonText: "Yes, report")
            }.buttonStyle(IconButtonStyle(backgroundColor: .yellow,
                                         foregroundColor: .black))
            
            // Don't report
            Button(action: sendReport) {
                IconButtonInner(iconName: "xmark", buttonText: "No, close")
            }.buttonStyle(IconButtonStyle(backgroundColor: Color(red: 0.2, green: 0.2, blue: 0.2),
                                         foregroundColor: .white))
            
            // Bottom
            Text("Your response will be recorded. Thank you!")
                .font(.system(size: 10))
                .padding(.top, 0)
        }
        .sheet(isPresented: $showPopup2) {
            Survey2(showPopup1: $showPopup1, showPopup2: $showPopup2,
                    hazards: hazards, hazardIcons: hazardIcons,
                    intensity: $intensity)
                .presentationDetents([.large])
        }
        
    }
    
    /// Sends hazard report (with no hazards) to Firebase and closes the popup.
    func sendReport() {
        // Firebase
        FirestoreHandler.connect()
        FirestoreHandler.addRecord(rec: WalkingRecord.toRecord(type: hazards, intensity: intensity))
        
        showPopup1 = false;
        Toast.showToast("Submitted. Thank you!")
    }
}

/// Popup view that asks users the details about the fall risk if they responded "yes"
/// to the first view.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Apr 14, 2023
///
struct Survey2: View {
    @Binding var showPopup1: Bool
    @Binding var showPopup2: Bool
 
    /// Types of hazards to be shown
    var hazards: [String]
    var hazardIcons: [String]
    
    @Binding var intensity: [Int]
    
    /// Levels of intensity
    let optionTexts: [String] = ["None (0)", "Low (1)", "Medium (2)", "High (3)"]
    let optionValues: [Int] = [0, 1, 2, 3]
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    showPopup2 = false
                }) {
                    Spacer().frame(width: 16)
                    Text("Back")
                    Spacer()
                }
            }.padding(.top, 14)
            
            
            ScrollView(.vertical, showsIndicators: false)
            {
                // Header
                Text("Report Fall Risk")
                    .fontWeight(.bold)
                    .font(.system(size: 28))
                    .padding(.top, 8)
                    .padding(.bottom, 0)
                
                HStack {
                    Spacer().frame(width: 36)
                    
                    Text("Please report all hazards you experienced and their intensities:")
                        .padding(.bottom, 20)
                        .multilineTextAlignment(.center)
                    
                    Spacer().frame(width: 36)
                }
                
                // Hazards form
                ForEach(hazards.indices) { index in
                    SurveyDropdown(label: hazards[index],
                                   icon: hazardIcons[index],
                                   optionTexts: optionTexts,
                                   optionValues: optionValues,
                                    value: $intensity[index])
                }
                
                // Disclaimer text
                Text("This form is not monitored. If you need medical assistance,\nplease call 911 or your local healthcare provider.")
                    .font(.system(size: 10))
                    .padding(.top, 12)
                    .multilineTextAlignment(.center)
            }
            
                

            // Submit Button
            Button(action: sendHazardReport) {
                IconButtonInner(iconName: "paperplane.fill", buttonText: "Submit")
            }.buttonStyle(IconButtonStyle(backgroundColor: .yellow, foregroundColor: .black))
            .padding(.top, 4)
            .padding(.bottom, 16)
        }
    }
    
    /// Sends hazard report to Firebase and closes the popup.
    func sendHazardReport() {
        FirestoreHandler.connect()
        FirestoreHandler.addRecord(rec: WalkingRecord.toRecord(type: hazards, intensity: intensity))

        showPopup1 = false;
        showPopup2 = false;
        Toast.showToast("Submitted. Thank you!")
    }
}


