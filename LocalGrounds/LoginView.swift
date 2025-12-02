//
//  LoginView.swift
//  LocalGrounds
//
//  Created by Carly Jazwin on 11/05/25.
//


import SwiftUI

//VIEW MODEL for the login page
//all the ui for sign up/login

struct LoginView: View {
    @EnvironmentObject var loginVM: LoginViewModel //pass in auth vm for login

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoginMode: Bool = true //bool to check if is login page or not, otherwise will show signup

    var body: some View {
        VStack(spacing: 24) {
            Image("localgroundslogo")
                .resizable()
                .scaledToFit()
                .frame(width: 220)
                .padding(.top, 8)

            Picker("Mode", selection: $isLoginMode) { //picker to toggle between login/signup
                Text("Log In").tag(true)
                Text("Sign Up").tag(false)
            }
            .pickerStyle(.segmented) //picker styles
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 12) { //email textfield
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                SecureField("Password", text: $password) //password textfield
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                Text("Password must be at least 6 characters.") //error if user doesnt enter long enough pass
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            if let error = loginVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            Button {
                Task {
                    guard !email.isEmpty, !password.isEmpty else { return } //if anythings empty returns
                    if isLoginMode {
                        await loginVM.signIn(email: email, password: password)
                    } else {
                        await loginVM.signUp(email: email, password: password)
                    }
                }
            } label: {
                if loginVM.isLoading {
                    ProgressView()
                        .tint(.white)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                } else {
                    Text(isLoginMode ? "Log In" : "Create Account") //toggle buttons
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color("LocalBrown")) //button for create/login using my localbrown
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
    }
}
