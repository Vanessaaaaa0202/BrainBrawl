//
//  ResetPasswordView.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 12/27/20.
//

import SwiftUI

struct ResetPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @Binding private var email: String
    
    init(email: Binding<String>) {
        self._email = email
    }

    var body: some View {
            VStack {
                VStack(alignment:.center){
                    Image("toggle_in_middle")
                        .scaleEffect(0.5)
                    Image("BrainBrawl").padding(.bottom)
                    
                }
                                    
                VStack(spacing: 20) {
                    TextField("Enter your email", text: $email)
                        .autocapitalization(.none)
                        .modifier(TextFieldModifier())
                }
                                    
                Button(action: {
                    Task {
                        try await AuthService.shared.sendResetPasswordLink(toEmail: email)
                        dismiss()
                    }
                }, label: {
                    Text("Send Reset Link")
                        .modifier(IGButtonModifier())
                })
                
                Spacer()
                
                Button(action: { dismiss() }, label: {
                    HStack {
                        Text("Already have an account?")
                            .font(.system(size: 14))
                        
                        Text("Sign In")
                            .font(.system(size: 14, weight: .semibold))
                    }
                })
            }
            .navigationBarBackButtonHidden(true)
    }
}
