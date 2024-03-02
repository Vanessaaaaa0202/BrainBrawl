//
//  LoginView.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 12/27/20.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @StateObject var viewModel = LoginViewModel()
    @EnvironmentObject var registrationViewModel: RegistrationViewModel
    
    var body: some View {
        NavigationStack{
            VStack {
                Spacer()
                
                VStack(alignment:.center){
                    Image("toggle_in_middle")
                        .scaleEffect(0.5)
                    Image("BrainBrawl").padding(.bottom)
                    
                }
                
                VStack(spacing: 8) {
                    TextField("Enter your email", text: $email)
                        .autocapitalization(.none)
                        .modifier(TextFieldModifier())
                    
                    SecureField("Password", text: $password)
                        .modifier(TextFieldModifier())
                }
                
                HStack {
                    Spacer()
                    
                    NavigationLink(
                        destination: ResetPasswordView(email: $email),
                        label: {
                            Text("Forgot Password?")
                                .font(.system(size: 13, weight: .semibold))
                                .padding(.top)
                                .padding(.trailing, 28)
                        })
                }
                
                
                Button(action: {
                    Task {await viewModel.login(withEmail: email, password: password) }
                }, label: {
                    Text("Log In")
                        .modifier(IGButtonModifier())
                })
                .alert(isPresented: $viewModel.hasLoginError) {
                           Alert(title: Text("Login Error"), message: Text("Incorrect Password, please try again"), dismissButton: .default(Text("OK")))
                       }
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                
                //MARK: 其他方式登录暂时先没有
                //VStack(spacing: 24) {
                //    HStack {
                //        Rectangle()
                //            .frame(width:( UIScreen.main.bounds.width / 2) - 40, height: 0.5)
                //            .foregroundColor(Color(.separator))
                //
                //        Text("OR")
                //            .font(.footnote)
                //            .fontWeight(.semibold)
                //            .foregroundColor(Color(.gray))
                //
                //        Rectangle()
                //            .frame(width:( UIScreen.main.bounds.width / 2) - 40, height: 0.5)
                //            .foregroundColor(Color(.separator))
                //    }
                //
                //    HStack {
                //        Image("facebook_logo")
                //            .resizable()
                //            .frame(width: 20, height: 20)
                //
                //        Text("Continue with Facebook")
                //            .font(.footnote)
                //            .fontWeight(.semibold)
                //            .foregroundColor(Color(.systemBlue))
                //    }
                //}
                //.padding(.top, 4)
                
                Spacer()
                
                Divider()
                
                NavigationLink {
                    AddEmailView()
                        .environmentObject(registrationViewModel)
                } label: {
                    HStack(spacing: 3) {
                        Text("Don't have an account?")
                            .font(.system(size: 14))
                        
                        Text("Sign Up")
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                .padding(.vertical, 16)
                
                VStack {
                    Text("By continuing, you agree to BrainBrawl’s ")
                        .font(.footnote)
                    
                    HStack{
                        NavigationLink {
                            TermofUseView()
                        } label: {
                            Text("Terms and Conditions")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                                
                        }
                        
                        
                        Text(" and ")
                            .font(.footnote)
                            .padding(.trailing, -5)
                            .padding(.leading,-8)
                        
                        NavigationLink {
                            PrivacyPolicyView()
                        } label: {
                            Text("Privacy Policy")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .multilineTextAlignment(.center)
                    .padding(.bottom)
                    //.padding(.horizontal)
            }
        }
    }
}

// MARK: - AuthenticationFormProtocol

extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(RegistrationViewModel())
    }
}
