import SwiftUI

/// The "Start Walking" / "Stop Walking" button
///
/// /// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 10, 2023
///
struct RecordingButton: View
{
    @Binding var isRecording: Bool
    @Binding var showPopup: Bool
    @Binding var tabSelection: Int
    @State var showAlert1: Bool = false
    @State var showAlert2: Bool = false
    
    let width: CGFloat = 280
    let height: CGFloat = 50
    
    var body: some View {
        // Button
        Button(action: {
            if(isRecording) {
                showPopup = true;
                MetaWearManager().stopRecording()
            }
            else {
                if(!MetaWearManager.connected()) {
                    showAlert1 = true
                    return
                }
                if(LocationManager.locationDisabled()) {
                    showAlert2 = true
                    return
                }
                MetaWearManager().startRecording()
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
        .foregroundColor(isRecording ? .black : .black)
        .background(Color(white: 0.95))
        .cornerRadius(16)
        .onAppear {
            MetaWearManager.locationManager.checkPermissions()
        }
                    
        // Alert: sensor not found
        .alert("Sensor Not Found", isPresented: $showAlert1, actions: {
            Button("Close",  role: .cancel, action: {
                showAlert1 = false;
                tabSelection = 3;
            })
        }, message: {
            Text("Please connect the IMU sensor and try again.")
        })
        
        // Alert: sensor not found
        .alert("Location Disabled", isPresented: $showAlert2, actions: {
            Button("OK",  role: nil, action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
                showAlert2 = false;
            })
            Button("Cancel",  role: .cancel, action: {
                showAlert2 = false;
            })
        }, message: {
            Text("To continue, please set location access to 'While Using the App' or 'Always', and enable Precise Location.")
        })
    }
    
    
}
