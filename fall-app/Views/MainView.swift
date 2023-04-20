import SwiftUI

/// Main view of the application, with the "Start Walking" / "Stop Walking" button
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Apr 13, 2023
///
struct MainView: View
{
    @State var isRecording: Bool = false
    @State var showPopup1: Bool = false
    @State var showPopup2: Bool = false
    @Binding var tabSelection: Int;
    
    var body: some View {
        VStack {
            // Image
            GeometryReader { metrics in
                Image("umich-logo")
                    .resizable()
                    .frame(width: metrics.size.width, height: metrics.size.width * 671 / 800,
                           alignment: .center)
            }
            
            RecordingButton(isRecording: $isRecording,
                            showPopup: $showPopup1)
//            Text("00 hr 00 min 00 sec")
            
            Spacer().frame(height: 80)
        }
        .background(Color(red: 0, green: 39/255, blue: 76/255))
        
        .sheet(isPresented: $showPopup1) {
            Survey1(showPopup1: $showPopup1, tabSelection: $tabSelection)
                .presentationDetents([.fraction(0.38)])
        }
        
    }
    
}

/// The "Start Walking" / "Stop Walking" button
///
/// /// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Apr 12, 2023
///
struct RecordingButton: View
{
    @Binding var isRecording: Bool
    @Binding var showPopup: Bool
    
    let width: CGFloat = 280
    let height: CGFloat = 50
    
    var body: some View {
        Button(action: {
            if(isRecording) {
                showPopup = true;
            }
            isRecording.toggle();
            
        }) {
            HStack
            {
                Image(systemName: isRecording ? "hand.raised.fill" : "figure.walk")
                    .imageScale(.large)
                Text(isRecording ? "Stop Walking" : "Start Walking")
            }
            .frame(width: width, height: height)
        }
        .frame(width: width, height: height)
        .foregroundColor(isRecording ? Color(red: 218/255, green: 33/255, blue: 2/255) : .black)
        .background(Color(white: 0.95))
        .cornerRadius(16)
    }
    
    
}
