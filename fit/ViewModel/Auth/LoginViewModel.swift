//
//  Login.swift
//  fit
//
//  Created by Cedric Kienzler on 04.02.25.
//

import FirebaseAuth
import Foundation

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var emailError: String = ""
    @Published var passwordError: String = ""

    init() {

    }

    func login() {
        guard validate() else {
            return
        }

        Auth.auth().signIn(withEmail: email, password: password)
    }

    private func validate() -> Bool {
        var anyErr: Bool = false

        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            emailError = "Please enter your email address"
            anyErr = true
        }

        if password.trimmingCharacters(in: .whitespaces).isEmpty {
            passwordError = "Please enter your password"
            anyErr = true
        } else {
            passwordError = ""
        }

        if !email.trimmingCharacters(in: .whitespaces).isEmpty
            && (!email.contains("@") || !email.contains("."))
        {
            emailError = "Please enter a valid email address"
            anyErr = true
        } else {
            emailError = ""
        }

        return !anyErr
    }
}
