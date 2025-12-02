//
//  LoginViewModel.swift
//  LocalGrounds
//
//  Created by Carly Jazwin on 11/05/25.
//


import Foundation
import FirebaseAuth
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    init() { //waits for login/signup aka auth change
        listenForAuthChanges()
    }

    private func listenForAuthChanges() { //updates whenever user logs in so auth state is changed
        Auth.auth().addStateDidChangeListener { _, user in
            Task { @MainActor in
                self.user = user
            }
        }
    }

    func signUp(email: String, password: String) async { //creates new user acct with email password using firebase auth, if sign up succeeds it auto logs user in
        errorMessage = nil
        isLoading = true
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = result.user
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    //logs in w existing acct for a user, calls auth.sign in to work w firebase auth
    //catches w error msg
    func signIn(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = result.user
        } catch {
            errorMessage = error.localizedDescription //errors if wrong pass user dne or other issues
        }
        isLoading = false
    }

    //sign out makes the user var nil and calls .signout on firebase auth
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
