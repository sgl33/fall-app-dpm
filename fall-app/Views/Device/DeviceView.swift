import SwiftUI

/// View to connect to MetaWear devices.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 10, 2023
///
struct DeviceView: View {
    /// Connection status object
    @ObservedObject var connectionStatus: ConnectionStatusObject = ConnectionStatusObject()
    
    @ObservedObject var bso: BatteryStatusObject = BatteryStatusObject()
    
    var body: some View {
        ZStack {
            VStack {
                // Device status
                VStack {
                    // Sensor image
                    Image("metamotions")
                        .resizable()
                        .frame(width: 160, height: 160)
                        .offset(y: 75)
                        .padding(.top, -70)
                    
                    // Sensor status icon
                    Image(connectionStatus.connected() ? "checkmark_green" : "xmark_red")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.top, -30)
                        .offset(x: 35, y: 40)
                        .background(.white)
                    
                    // Gray box with text
                    VStack {
                        Spacer()
                            .frame(height: 28)
                        
                        Text("MetaWear Sensor")
                            .font(.system(size: 20, weight: .semibold))
                            .padding(.bottom, -4)
                            .foregroundColor(Color(white: 0))
                        
                        Text(connectionStatus.connected() ? "\(MetaWearManager.device.mac ?? "Connected")" : "Disconnected")
                            .font(.system(size: 11))
                            .foregroundColor(Color(white: 0.35))
                        
                        Spacer()
                            .frame(height: 8)
                        
                        HStack {
                            Image(systemName: bso.battery_icon)
                                .imageScale(.small)
                                .foregroundColor(Color(white: 0.05))
                            Text(bso.battery_percentage)
                                .font(.system(size: 13))
                                .foregroundColor(Color(white: 0.05))
                        }
                        .onAppear {
                            MetaWearManager.getBattery(bso: bso)
                        }
                    }
                    .frame(width: 320, height: 120)
                    .background(Color(white: 0.9))
                    .cornerRadius(12)
                    .zIndex(-10)
                }
                
                // Buttons
                if(connectionStatus.connected()) { // when connected
                    // Disconnect
                    Button(action: {
                        MetaWearManager.disconnectBoard(cso: connectionStatus,
                                                        bso: bso)
                    }) {
                        IconButtonInner(iconName: "xmark.square", buttonText: "Disconnect")
                    }.buttonStyle(IconButtonStyle(backgroundColor: Color(white: 0.15),
                                                  foregroundColor: .white))
                    
                    // Ping
                    Button(action: {
                        MetaWearManager.pingBoard()
                    }) {
                        IconButtonInner(iconName: "wave.3.right", buttonText: "Ping")
                    }.buttonStyle(IconButtonStyle(backgroundColor: Color(red: 69/255, green: 104/255, blue: 218/255),
                                                  foregroundColor: .white))
                    
                    // Manual
                    Link(destination: URL(string: "https://mbientlab.com/tutorials/MetaMotionS.html")!) {
                        HStack {
                            Image(systemName: "book.fill")
                                .imageScale(.medium)
                            Text("User Manual")
                        }
                    }
                    .padding(.top, 8)
                
                    Text("Please keep the sensor within 4 feet of your iPhone and do not disable Bluetooth.")
                        .font(.system(size: 12))
                        .frame(maxWidth: 300)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Utilities.isDarkMode() ? Color(white: 0.8) : Color(white: 0.2))
                        .padding(.top, 4)
                }
                else {
                    // Connect
                    Button(action: {
                        MetaWearManager.scanBoard(cso: connectionStatus)
                    }) {
                        IconButtonInner(iconName: "link", buttonText: "Connect")
                    }.buttonStyle(IconButtonStyle(backgroundColor: Color(red: 0, green: 146/255, blue: 12/255),
                                                  foregroundColor: .white))
                    
                    // Manual
                    Link(destination: URL(string: "https://mbientlab.com/tutorials/MetaMotionS.html")!) {
                        HStack {
                            Image(systemName: "book.fill")
                                .imageScale(.medium)
                            Text("User Manual")
                        }
                    }
                    .padding(.top, 8)
                    
                    Text("Bluetooth must be enabled.")
                        .font(.system(size: 12))
                        .frame(maxWidth: 300)
                        .foregroundColor(Utilities.isDarkMode() ? Color(white: 0.8) : Color(white: 0.2))
                        .padding(.top, 4)
                }
            } // VStack
            
            // Modal: scanning
            if(connectionStatus.showModal()) {
                Spacer()
                    .frame(width: .infinity, height: .infinity) // TODO FIX invalid frame dimension?
                    .background(Color(white: 0).opacity(0.65))
                
                VStack {
                    // Sensor detected
                    if(connectionStatus.getStatus() == ConnectionStatus.found) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                            Text("Detected!")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .padding(.bottom, -2)
                        
                        Text("Sensor detected. Please wait...")
                    }
                    // Still scanning...
                    else {
                        HStack {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .imageScale(.large)
                            Text("Scanning...")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .padding(.bottom, -2)
                        
                        Text("Place the IMU sensor near your iPhone.")
                            .padding(.bottom, -2)
                        
                        Button("Cancel") {
                            MetaWearManager.stopScan(cso: connectionStatus)
                        }
                        .foregroundColor(Color(white: 0.7))
                    }
                }
                .frame(width: 350, height: 112)
                .background(Color(white: 0.13).opacity(0.98))
                .foregroundColor(Color(white: 0.95))
                .cornerRadius(12)
                .onDisappear {
                    MetaWearManager.getBattery(bso: bso)
                }
            } // if (scanning)
        } // ZStack

    } // body
    
    
}

// Preview
/// Physical device required for it to actually function.
struct DeviceView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceView()
    }
}
