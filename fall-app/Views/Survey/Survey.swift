import SwiftUI

/// Popup view that asks users if they experienced fall risk.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 10, 2023
///
struct Survey1: View {
    
    @Binding var showPopup1: Bool
    @State var showPopup2: Bool = false
    @Binding var tabSelection: Int
    
    /// Intensity for each hazards. Default value = 0. Size must match that of `hazards`.
    @State private var intensity: [Int] = [0, 0, 0, 0, 0, 0];
    
    
    var body: some View {
        VStack {
            // Header
            Text("Recording Complete!")
                .fontWeight(.bold)
                .font(.system(size: 24))
                .padding(.bottom, -6)
            Text("Did you experience fall risk?")
                .font(.system(size: 20))
            
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
                    hazards: AppConstants.hazards, hazardIcons: AppConstants.hazardIcons,
                    tabSelection: $tabSelection)
                .presentationDetents([.large])
        }
        
    }
    
    /// Sends hazard report (with no hazards) to Firebase and closes the popup.
    func sendReport() {
        // Firebase
        MetaWearManager.sendHazardReport(hazards: AppConstants.hazards,
                                         intensity: intensity)
        showPopup1 = false;
        tabSelection = 2; // switch to HistoryView
        Toast.showToast("Submitted. Thank you!")
    }
}

/// Popup view that asks users the details about the fall risk if they responded "yes"
/// to the first view.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 10, 2023
///
struct Survey2: View {
    @Binding var showPopup1: Bool
    @Binding var showPopup2: Bool
 
    /// Types of hazards to be shown
    var hazards: [String]
    var hazardIcons: [String]
    
    @State var intensity: [Int] = [0, 0, 0, 0, 0, 0]
    
    @State var showAlert: Bool = false;
    @Binding var tabSelection: Int
    
    var body: some View {
        VStack {
            // Back button (at the top)
//            HStack {
//                Button(action: { // back
//                    showPopup2 = false;
//                    sendHazardReport(ignoreWarning: true)
//                }) {
//                    Spacer().frame(width: 16)
//                    Text("Cancel")
//                    Spacer()
//                }
//            }.padding(.top, 14)
            
            // Scroll view
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
                        .font(.system(size: 20))
                        .padding(.bottom, 20)
                        .multilineTextAlignment(.center)
                    
                    Spacer().frame(width: 36)
                }
                
                // Hazards form
                ForEach(hazards.indices) { index in
                    SurveyDropdown(label: hazards[index],
                                   icon: hazardIcons[index],
                                   optionTexts: AppConstants.optionTexts,
                                   optionValues: AppConstants.optionValues,
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
            
            // Alert
            .alert("No Hazard Selected", isPresented: $showAlert, actions: {
                Button("Close",  role: .cancel, action: { showAlert = false; })
            }, message: {
                Text("You have not selected any hazards to report. Please press \"Cancel\" if you have none to report.")
            })
        }
    }
                      
    
    /// Sends hazard report to Firebase and closes the survey.
    func sendHazardReport() {
        // Hazard not selected?
//        if(noHazardSelected()) {
//            showAlert = true;
//            return;
//        }
        
        MetaWearManager.sendHazardReport(hazards: hazards,
                                         intensity: intensity)
        showPopup1 = false;
        showPopup2 = false;
        Toast.showToast("Submitted. Thank you!")
        tabSelection = 2; // switch to HistoryView
        
    }
    
    func sendHazardReport(ignoreWarning: Bool) {
        if ignoreWarning {
            MetaWearManager.sendHazardReport(hazards: hazards,
                                             intensity: intensity)
            showPopup1 = false;
            showPopup2 = false;
            Toast.showToast("Submitted. Thank you!")
            tabSelection = 2;
        }
        else {
            sendHazardReport()
        }
    }
    
    /// Returns true if user did not select any hazard to report, false otherwise.
    func noHazardSelected() -> Bool {
        for i in intensity {
            if(i != 0) {
                return false;
            }
        }
        return true;
    }
    
    /// Clears intensities to 0 when pressing "Back".
    func clearIntensities() {
        for index in intensity.indices {
            intensity[index] = 0;
        }
    }
}


