import SwiftUI

/// Main view of the application, with the "Start Walking" / "Stop Walking" button
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 31, 2023
///
struct MainView: View
{
    @State var isRecording: Bool = false
    @State var showPopup1: Bool = false
    @State var showPopup2: Bool = false
    @Binding var tabSelection: Int;
    @ObservedObject var cso = ConnectionStatusObject()
    @State var connectionComplete: Bool = false
    
    @State var animationBool: Bool = false
    
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect() // refresh every second
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 8)
            
            // Logos
            MainView_Logos()
            
            // Info text
            VStack {
                Text("SafeSteps")
                    .font(.system(size: 32, weight: .bold))
                Text("Report environmental slip, trip, and fall hazards and stay informed!")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 350)
            }
            
            // Graphic
            GeometryReader { metrics in
                Image("main_graphic")
                    .resizable()
                    .frame(width: metrics.size.width, height: metrics.size.width * 800 / 1280,
                           alignment: .center)
            }
            
            Spacer()
                .frame(height: 160)

            StatusItem(active: $cso.conn,
                       activeText: "Sensor Connected",
                       inactiveText: "Sensor Disconnected")
            
            
            // Interact
            VStack {
                Spacer()
                    .frame(height: 12)
                
                // walking indicator
                HStack {
                    let circleSize: CGFloat = 16
                    let circleLineWidth: CGFloat = 3
                    
                    ZStack {
                        let wheelColor = Utilities.isDarkMode() ? Color(white: 0.3) : Color(white: 0.7)
                        Circle()
                            .stroke(wheelColor, lineWidth: circleLineWidth)
                            .frame(width: circleSize, height: circleSize)
                        
                        if isRecording {
                            Circle() // animation
                                .trim(from: 0, to: 0.25)
                                .stroke(.cyan, lineWidth: circleLineWidth)
                                .frame(width: circleSize, height: circleSize)
                                .rotationEffect(Angle(degrees: animationBool ? 360 : 0))
                                .animation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false))
                                .onAppear {
                                    animationBool = true
                                }
                                .onChange(of: isRecording) { _ in
                                    animationBool = false
                                    animationBool = true
                                }
                        }
                        
                        
                    }
                    .frame(width: circleSize, height: circleSize)
                    
                    Text(isRecording ? "Recording" : "Not Recording")
                        .padding(.leading, 4)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                // text or button
                if !cso.conn { // sensor disconnected
                    Text("Please connect the sensor to enable walking detection.")
                        .font(.system(size: 14))
                        .frame(maxWidth: 330)
                        .multilineTextAlignment(.center)
                }
                else if !isRecording { // not recording
                    Text("Start walking to automatically start recording.\nFeel free to leave the app.")
                        .font(.system(size: 14))
                        .frame(maxWidth: 330)
                        .multilineTextAlignment(.center)
                }
                else { // recording
                    Button(action: {
                        showPopup2 = true
                        MetaWearManager().stopRecording()
                        isRecording = false
                        animationBool = false
                    }) {
                        IconButtonInner(iconName: "exclamationmark.triangle", buttonText: "Report Hazard")
                    }
                    .buttonStyle(IconButtonStyle(backgroundColor: .yellow,
                                                 foregroundColor: .black))
                }
                
                Spacer()
                    .frame(height: 12)
            }
            .frame(width: 350)
            .background(Utilities.isDarkMode() ? Color(white: 0.1) : Color(white: 0.9))
            .cornerRadius(12)
            .padding(.bottom, 4).padding(.top, -2)
            
            Spacer().frame(height: 56)
        }
        
        .sheet(isPresented: $showPopup1) {
            Survey1(showPopup1: $showPopup1, tabSelection: $tabSelection)
                .presentationDetents([.fraction(0.38)])
        }
        .sheet(isPresented: $showPopup2) {
            Survey2(showPopup1: $showPopup1, showPopup2: $showPopup2,
                    hazards: AppConstants.hazards, hazardIcons: AppConstants.hazardIcons,
                    tabSelection: $tabSelection)
                .presentationDetents([.large])
        }
        .onAppear {
            MetaWearManager.connected(cso)
            connectionComplete = true
            
            WalkingDetectionManager.initialize()
            NotificationManager.requestPermissions()
            
            /// DEBUG - shows list of font names
//            for family: String in UIFont.familyNames
//            {
//                print(family)
//                for names: String in UIFont.fontNames(forFamilyName: family)
//                {
//                    print("== \(names)")
//                }
//            }
        }
        .onReceive(timer) { _ in
            isRecording = MetaWearManager.recording
            MetaWearManager.connected(cso)
        }
        .onChange(of: isRecording) { _ in
            if isRecording == false {
                animationBool = false
            }
        }
        
    }
}

/// Logos used in `MainView`
struct MainView_Logos: View {
    var body: some View {
        GeometryReader { metrics in
            HStack(alignment: .center) {
                // DPM
                HStack {
                    Image("block_m_logo")
                        .resizable()
                        .frame(width: metrics.size.width * 0.12,
                               height: metrics.size.width * 0.12 * 830 / 1162,
                               alignment: .center)
                        .padding(.trailing, -4)
                    VStack {
                        Text("DYNAMIC")
                            .frame(width: metrics.size.width * 0.22,
                                   alignment: .leading)
                            .font(Font.custom("NunitoSans-12ptExtraLight_Regular", size: 11))
                            .padding(.bottom, -10)
                        Text("PROJECT")
                            .frame(width: metrics.size.width * 0.22,
                                   alignment: .leading)
                            .font(Font.custom("NunitoSans-12ptExtraLight_Regular", size: 11))
                            .padding(.bottom, -10)
                        Text("MANAGEMENT")
                            .frame(width: metrics.size.width * 0.22,
                                   alignment: .leading)
                            .font(Font.custom("NunitoSans-12ptExtraLight_Regular", size: 11))
                    }
                    .frame(width: metrics.size.width * 0.25)
                }
                // Liberty Mutual
                VStack {
                    Image("liberty_mutual_logo_tb")
                        .resizable()
                        .frame(width: metrics.size.width * 0.45,
                               height: metrics.size.width * 0.45 * 317 / 1140,
                               alignment: .center)
                    Spacer()
                        .frame(height: 8)
                }
                .background(.white)
                .cornerRadius(8)
                
            }
            .frame(width: metrics.size.width)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView_Preview()
    }
}

/// For preview
struct MainView_Preview: View {
    @State var tabSelection: Int = 0
    
    var body: some View {
        MainView(tabSelection: $tabSelection)
    }
}
