import SwiftUI

/// Popup view that asks users if they experienced fall risk.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Apr 12, 2023
///
struct Survey1: View {
    
    @Binding var showPopup1: Bool
    @State var showPopup2: Bool = false
    
    var body: some View {
        
        
        VStack {
            Text("Recording Complete!")
                .fontWeight(.bold)
                .font(.system(size: 24))
                .padding(.bottom, -4)
            
            Text("Did you experience fall risk?")
            
            Button(action: {
                showPopup2 = true
            }) {
                IconButtonInner(iconName: "exclamationmark.triangle", buttonText: "Yes, report")
            }.buttonStyle(IconButtonStyle(backgroundColor: .yellow,
                                         foregroundColor: .black))
            
            Button(action: {
                // TODO upload data on firebase
                showPopup1 = false;
                Toast.showToast("Submitted. Thank you!")
            }) {
                IconButtonInner(iconName: "xmark", buttonText: "No, close")
            }.buttonStyle(IconButtonStyle(backgroundColor: Color(red: 0.2, green: 0.2, blue: 0.2),
                                         foregroundColor: .white))
            
            Text("Your response will be recorded. Thank you!")
                .font(.system(size: 10))
                .padding(.top, 0)
        }
        
        .sheet(isPresented: $showPopup2) {
            Survey2(showPopup1: $showPopup1, showPopup2: $showPopup2)
                .presentationDetents([.large])
        }
        
    }
}

/// Popup view that asks users the details about the fall risk if they responded "yes"
/// to the first view.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Apr 12, 2023
///
struct Survey2: View {
    @Binding var showPopup1: Bool
    @Binding var showPopup2: Bool
    
    @State private var intensity: Int = 1;
    
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
                Text("Report Fall Risk")
                    .fontWeight(.bold)
                    .font(.system(size: 28))
                    .padding(.top, 8)
                    .padding(.bottom, 0)
                
                Text("Lorem ipsum dolor sit amet:")
                    .padding(.bottom, 8)

                SurveyDropdown(question: "Please select the intensity:",
                               optionTexts: ["Low (1)", "Medium (2)", "High (3)"],
                               optionValues: [1, 2, 3],
                                value: $intensity)
                
                Text("This form is not monitored. If you need medical assistance,\nplease call 911 or your local healthcare provider.")
                    .font(.system(size: 10))
                    .padding(.top, 12)
                    .multilineTextAlignment(.center)
            }
            
                
            
            // Submit Button
            Button(action: {
                // TODO upload data on firebase
                showPopup1 = false;
                showPopup2 = false;
                Toast.showToast("Submitted. Thank you!")
            }) {
                IconButtonInner(iconName: "paperplane.fill", buttonText: "Submit")
            }.buttonStyle(IconButtonStyle(backgroundColor: .yellow, foregroundColor: .black))
            .padding(.top, 4)
            .padding(.bottom, 16)
        }
    }
}


