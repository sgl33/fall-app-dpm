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
            
            Text("Lorem ipsum dolor sit amet?")
            
            Button(action: {
                // TODO upload data on firebase
                showPopup2 = true
            }) {
                Image(systemName: "exclamationmark.triangle")
                    .imageScale(.medium)
                Text("Yes, lorem ipsum")
            }
            .frame(width: 280, height: 40)
            .background(.yellow)
            .foregroundColor(.black)
            .cornerRadius(12)
            
            
            Button(action: {
                // TODO upload data on firebase
                showPopup1 = false;
            }) {
                Image(systemName: "xmark")
                    .imageScale(.medium)
                Text("No, close")
            }
            .frame(width: 280, height: 40)
            .background(Color(red: 0.15, green: 0.15, blue: 0.15))
            .foregroundColor(.white)
            .cornerRadius(12)
            
            Text("Your response will be recorded. Thank you!")
                .font(.system(size: 10))
                .padding(.top, 0)
        }
        
        .sheet(isPresented: $showPopup2) {
            Survey2(showPopup1: $showPopup1, showPopup2: $showPopup2)
                .presentationDetents([.fraction(0.7)])
        }
        
    }
}

struct Survey2: View {
    @Binding var showPopup1: Bool
    @Binding var showPopup2: Bool
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    showPopup2 = false
                }) {
                    Spacer().frame(width: 15)
                    Text("Close")
                    Spacer()
                }
            }.padding(.top, 12)
            
            Spacer()
            
            Text("Report a Problem")
                .fontWeight(.bold)
                .font(.system(size: 24))
            Spacer()
                .frame(height: 4)
            
            Text("Lorem ipsum dolor sit amet:")
            
            
            
            Button(action: {
                // TODO upload data on firebase
                showPopup1 = false;
                showPopup2 = false;
                
            }) {
                Image(systemName: "paperplane.fill")
                    .imageScale(.medium)
                Text("Submit")
            }
            .frame(width: 280, height: 40)
            .background(Color(red: 0, green: 146/255, blue: 12/255))
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
}
