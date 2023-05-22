import SwiftUI

/// A textfield that accepts numbers only with a prompt text, displayed side-by-side.
///
/// ### Example
/// ```
/// @State private var ddValue: String = ""
/// SurveyNumberField(question: "How old are you?",
///                 placeholder: "Age",
///                 value: $ddValue)
/// ```
/// Parse the value into a number as needed.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Apr 9, 2023
///
struct SurveyNumberField: View {

    /// Question text to be shown next to the textfield.
    var question: String
    
    /// String that provides a brief hint to the user as to what kind of information is expected in the field.
    /// Example: "Username", "Password", "Number"
    var placeholder: String
    
    /// Binding value: pass by reference. Value of the textfield in string.
    /// Parse into a number as needed. Error checking may be required.
    @Binding var value: String

    /// Width of the prompt text. Default: 240
    let textWidth: CGFloat = 240
    
    /// Width of the textfield. Default: 60 (allows 4-5 digits)
    let fieldWidth: CGFloat = 60
    
    /// Width of spacer between the prompt text and the textfield. Default: 20
    let spacerWidth: CGFloat = 20
    
    /// Height of the textfield. Default: 40
    let height: CGFloat = 40
    
    var body: some View {
        HStack {
            Text(question)
                .multilineTextAlignment(.leading)
                .frame(width: textWidth, alignment: .leading)
            
            Spacer()
                .frame(width: spacerWidth)
            
            TextField(placeholder, text: $value)
                .frame(width: fieldWidth, height: height)
                .background {
                    VStack {
                        Spacer()
                        Color(UIColor.systemGray4)
                            .frame(height: 2)
                    }
                }
                .foregroundColor(Color(UIColor.systemGray))
                .keyboardType(.numberPad)
        }
        .padding(.top, 4)
        .padding(.bottom, 8)
        
    }
}
