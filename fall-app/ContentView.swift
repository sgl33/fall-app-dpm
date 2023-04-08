//
//  ContentView.swift
//  fall-app
//
//  Created by Seung-Gu Lee on 4/6/23.
//

import SwiftUI


/// Default View for the application.
///
/// ### Elements
/// - Recording Button (`RecordingButton`)
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Apr 7, 2023
///
struct ContentView: View {
    @State var isRecording: Bool = false
    @State var showPopup1: Bool = false
    @State var showPopup2: Bool = false
    
    var body: some View {
        VStack {
            RecordingButton(isRecording: $isRecording,
                            showPopup: $showPopup1)
        }
        .padding()
        
        .sheet(isPresented: $showPopup1) {
            Survey1(showPopup1: $showPopup1)
                .presentationDetents([.fraction(0.35)])
        }
        
        
    }
    
    
}

struct RecordingButton: View
{
    @Binding var isRecording: Bool
    @Binding var showPopup: Bool
    
    var body: some View {
        Button(action: {
            if(isRecording) {
                showPopup = true;
            }
            isRecording.toggle();
            
        }) {
            Image(systemName: isRecording ? "stop.circle" : "record.circle")
                .imageScale(.large)
            Text(isRecording ? "Stop Recording" : "Start Recording")
        }
        .frame(width: 280, height: 50)
        .foregroundColor(isRecording ? .yellow : .white)
        .background(Color(red: 0.2, green: 0.2, blue: 0.2))
        .cornerRadius(16)
    }
    
    
}

/**
 Shows survey on a new content view
 */
func showSurvey()
{
    guard let url = URL(string: "https://google.com") else { return }
    UIApplication.shared.canOpenURL(url)
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
    print("Survey shown");
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
