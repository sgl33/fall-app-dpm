import SwiftUI
import MetaWear
import MetaWearCpp

/// Dummy view of the application, contains nothing but a single text
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Apr 13, 2023
///
struct DummyView: View {
    var mwm = MetaWearManager()
    
    
    var body: some View {
        VStack {
            Text("Please place the sensor within 6 inches of the device and press connect")
            HStack {
                Button(action: mwm.scanBoard) {
                    Text("Connect")
                }
                Button(action: mwm.disconnectBoard) {
                    Text("Disconnect")
                }
            }
            HStack {
                Button(action: mwm.testStart) {
                    Text("Start")
                }
                Button(action: mwm.testStop) {
                    Text("Stop")
                }
            }
            
        }
        
    }
    
    
}
