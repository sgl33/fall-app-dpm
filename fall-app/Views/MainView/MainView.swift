import SwiftUI

/// Main view of the application, with the "Start Walking" / "Stop Walking" button
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 22, 2023
///
struct MainView: View
{
    @State var isRecording: Bool = false
    @State var showPopup1: Bool = false
    @State var showPopup2: Bool = false
    @Binding var tabSelection: Int;
    @ObservedObject var cso = ConnectionStatusObject()
    @State var connectionComplete: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 8)
            
            // Logos
            GeometryReader { metrics in
                HStack(alignment: .center) {
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
//                .border(Color(.black)) // debug: border
            }
            
            // Text
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
            
            // Interact
            VStack {
                StatusItem(active: cso.conn,
                           activeText: "Sensor Connected",
                           inactiveText: "Sensor Disconnected")
                
                RecordingButton(isRecording: $isRecording,
                                showPopup: $showPopup1,
                                tabSelection: $tabSelection)
            }
            
            
            Spacer().frame(height: 60)
        }
        
        .sheet(isPresented: $showPopup1) {
            Survey1(showPopup1: $showPopup1, tabSelection: $tabSelection)
                .presentationDetents([.fraction(0.38)])
        }
        .onAppear {
            MetaWearManager.connected(cso)
            connectionComplete = true
            
            // debugging
            // shows list of font names
//            for family: String in UIFont.familyNames
//            {
//                print(family)
//                for names: String in UIFont.fontNames(forFamilyName: family)
//                {
//                    print("== \(names)")
//                }
//            }
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
