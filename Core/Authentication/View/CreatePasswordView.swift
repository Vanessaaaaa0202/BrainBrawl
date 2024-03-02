//
//  CreatePasswordView.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephan Dowless on 4/28/23.
//

import SwiftUI

struct CreatePasswordView: View {
    @EnvironmentObject var viewModel: RegistrationViewModel

    var body: some View {
        VStack(spacing: 12) {
            Text("Create a password")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("Your password must be at least 9 characters in length.")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            SecureField("Password", text: $viewModel.password)
                .modifier(TextFieldModifier())
                .padding(.top)
            
            NavigationLink {
                CompleteSignUpView()
            } label: {
                Text("Next")
                    .modifier(IGButtonModifier())
            }
            .disabled(!formIsValid)
            .opacity(formIsValid ? 1.0 : 0.5)
            
            Spacer()
        }
    }
}

// MARK: - AuthenticationFormProtocol

extension CreatePasswordView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !viewModel.password.isEmpty && viewModel.password.count > 8
    }
}

struct CreatePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePasswordView()
            .environmentObject(RegistrationViewModel())

    }
}
