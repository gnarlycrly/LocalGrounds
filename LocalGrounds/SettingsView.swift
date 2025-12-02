//
//  SettingsView.swift
//  LocalGrounds
//
//  Created by Carly Jazwin on 11/14/25.
//

//this is the page for settings, super minimal, just a separate page for user to sign out using firebase auth
//may expand later just primitive for now
import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var loginVM: LoginViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image("localgroundslogo") //put the logo at the top to match my ui
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220)
                    .padding(.top, 8)

                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .padding(.top, 40)

                if let user = loginVM.user { //call login vm user to know who is acc logged in
                    Text(user.email ?? "Logged in")
                        .font(.headline)
                }

                Button(role: .destructive) {
                    loginVM.signOut()
                } label: {
                    Text("Log Out") //logout button matching theme
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("LocalBrown"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Spacer()
            }
        }
    }
}
