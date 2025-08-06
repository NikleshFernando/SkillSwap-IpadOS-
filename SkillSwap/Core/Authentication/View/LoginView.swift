//
//  LoginView.swift
//  SkillSwap
//
//  Created by Niklesh Fernando on 2025-04-17.
//

import SwiftUI

struct LoginView: View {
    @State private var email=""
    @State private var password=""
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack{
            VStack{
                Text("SkillSwap")
                    .padding(.bottom,-12)
                    .font(.system(size: 30))
                
                
                Image("SkillSwap")
                    .resizable()
                    .scaledToFill()
                    .frame(width:150 ,height:150)
                    .padding(.vertical,32)
                
                VStack(spacing:24){
                    InputView(text:$email,
                              title:"Email Address",
                              placeholder: "name@example.com")
                    .autocapitalization(.none)
                    
                    InputView(text: $password,
                              title: "Password",
                              placeholder: "Enter Your Password",
                              isSecureField: true
                    )
                }
                .padding(.horizontal)
                .padding(.top,12)
                
                Button {
                    Task{
                        try await viewModel.signIn(withEmail: email, password: password)
                    }
                } label: {
                    HStack{
                        Text("SIGN IN")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(width:UIScreen.main.bounds.width - 32,height:48)
                }
                .background(Color(.systemBlue))
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                .cornerRadius(10)
                .padding(.top,24)

                Spacer()
                
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden()
                } label: {
                    HStack(spacing: 3){
                        Text("Don't Have an account?")
                        Text("Sign Up")
                            .fontWeight(.bold)
                    }.font(.system(size:14))
                }
                

            
            }
        }
    }
}

extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}

#Preview {
    LoginView()
}
