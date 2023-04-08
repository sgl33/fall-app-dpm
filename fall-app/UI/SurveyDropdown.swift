import SwiftUI

/// Single-select dropdown with prompt text of width 320.
///
/// ### Example
/// ```
/// @State private var ddValue: Int = 1
/// SurveyDropdown(question: "Please select an item",
///                 optionTexts: ["No", "Yes"],
///                 value: $ddValue)
/// ```
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Apr 9, 2023
///
struct SurveyDropdown: View {

    /// Question text to be shown on top of the dropdown menu.
    var question: String
    
    /// Array of strings to be shown in the dropdown menu.
    var optionTexts: [String]
    
    /// Binding value; pass by reference. Default value must be between 1 (inclusive) and the number of items in `optionText` (inclusive).
    /// First element in optionTexts corresponds to `value = 1`, second element in `value = 2`, and so on.
    @Binding var value: Int

    /// Width of dropdown menu box. Default: 320
    let width: CGFloat = 320
    
    /// Height of dropdown menu box. Default: 36
    let height: CGFloat = 36
    
    var body: some View {
        VStack {
            HStack {
                Text(question)
                    .padding(.top, 4)
                    .frame(width: width - 25, alignment: .leading)
                Spacer()
            }
            .padding(.bottom, 0)
            
            Picker(question, selection: $value) {
                ForEach(optionTexts.indices) { index in
                    Text(optionTexts[index]).tag(index+1)
                }
            }
            .frame(width: width, height: height)
            .background(Color(white: 0.93))
            .cornerRadius(12)
            .padding(.top, -4)
        }
        .frame(width: width)
        
    }
}

