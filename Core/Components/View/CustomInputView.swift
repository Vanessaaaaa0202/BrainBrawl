//
//  CustomInputView.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 1/1/21.
//

import SwiftUI

struct CustomInputView: View {
    @Binding var inputText: String
    let placeholder: String
    let buttonTitle: String
    var action: () -> Void
    
    var body: some View {
        ZStack(alignment: .trailing) {
            TextField(placeholder, text: $inputText, axis: .vertical)
                .padding(12)
                .padding(.leading, 4)
                .padding(.trailing, 48)
                .background(Color(.systemGroupedBackground))
                .clipShape(Capsule())
                .font(.subheadline)
            
            Button(action: action) {
                Text(buttonTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.systemBlue))
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}
