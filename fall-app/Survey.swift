//
//  Survey.swift
//  fall-app
//
//  Created by Seung-Gu Lee on 4/6/23.
//

import SwiftUI

/**
 Survey view
 Use this in a sheet of 35% height.
 */
struct Survey1: View {
    
    @Binding var showPopup1: Bool
    @State var showPopup2: Bool = false
    
    var body: some View {
        
        
        VStack {
            Text("Recording Complete!")
                .fontWeight(.bold)
                .font(.system(size: 24))
                .padding(.bottom, -4)
            
            Text("Did you witness or experience a fall risk?")
            
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
            // Color(red: 0, green: 146/255, blue: 12/255)
            
            Text("Your response will be recorded onto the database. Thank you!")
                .font(.system(size: 10))
                .padding(.top, 0)
        }
        
        .sheet(isPresented: $showPopup2) {
            Survey2(showPopup1: $showPopup1, showPopup2: $showPopup2)
                .presentationDetents([.fraction(0.55)])
        }
        
    }
}

struct Survey2: View {
    @Binding var showPopup1: Bool
    @Binding var showPopup2: Bool
    
    @State private var question1: String = ""
    @State private var question2: String = ""
    @State private var question3: Int = 1
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    showPopup2 = false
                }) {
                    Spacer().frame(width: 18)
                    Text("Back")
                    Spacer()
                }
            }.padding(.top, 14)
            
            Spacer()
            
            Text("Report a Fall Risk")
                .fontWeight(.bold)
                .font(.system(size: 24))
                .padding(.bottom, 0)
            
            Text("Lorem ipsum dolor sit amet:")
                .padding(.bottom, 8)
            
            SurveyTextField(question: "Question 1: please enter a string (text) input",
                            placeholder: "Type here...",
                            value: $question1)
            
            SurveyNumberField(question: "Question 2: please enter a number (integer) input",
                            placeholder: "#",
                            value: $question2)
            
            SurveyDropdown(question: "Question 3: please select one item",
                           optionTexts: ["Strongly disagree (1)", "Disagree (2)", "Neutral (3)", "Agree (4)", "Strongly agree (5)"],
                            value: $question3)
            
            
            Text("This form is not monitored. If you need medical assistance,\nplease call 911 or your local healthcare provider.")
                .font(.system(size: 10))
                .padding(.top, 12)
                .padding(.bottom, -2)
                .multilineTextAlignment(.center)
            
            // Submit Button
            Button(action: {
                // TODO upload data on firebase
                showPopup1 = false;
                showPopup2 = false;
                Toast.showToast("Submitted. Thank you!")
            }) {
                IconButtonInner(iconName: "paperplane.fill", buttonText: "Submit")
            }.buttonStyle(IconButtonStyle(backgroundColor: .yellow, foregroundColor: .black))
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
    }
}


