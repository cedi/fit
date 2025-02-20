//
//  Signup.swift
//  fit
//
//  Created by Cedric Kienzler on 04.02.25.
//

import CryptoKit
import FirebaseAuth
import FirebaseFirestore
import Foundation

class SignupViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var agreeToTerms: Bool = false
    @Published var emailError: String = ""
    @Published var passwordError: String = ""
    @Published var agreeToTermsError: Bool = false
    @Published var firstNameError: String = ""
    @Published var lastNameError: String = ""
    @Published var signupError: String = ""

    fileprivate var currentNonce: String?

    init() {}

    func signup() {
        guard validate() else {
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) {
            [weak self] result, error in

            guard let err = error else {
                guard let userId = result?.user.uid else {
                    return
                }

                self?.createUser(uid: userId)
                return
            }

            if err.localizedDescription.contains("already in use") {
                self?.emailError = err.localizedDescription
            } else {
                self?.signupError = err.localizedDescription
            }
        }
    }

    private func createUser(uid: String) {
        let newUser = User(
            email: email,
            isOnboarded: false
        )

        do {
            let db = Firestore.firestore()

            try db.collection("users")
                .document(uid)
                .setData(from: newUser)
        } catch {
            print(error)
        }
    }

    private func validate() -> Bool {
        emailError = ""
        passwordError = ""
        agreeToTermsError = false
        firstNameError = ""
        lastNameError = ""

        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            emailError = "Please enter your email address"
        } else if !email.contains("@") || !email.contains(".") {
            emailError = "Please enter a valid email address"
        }

        if password.trimmingCharacters(in: .whitespaces).isEmpty {
            passwordError = "Please enter your password"
        } else if password.count < 6 {
            passwordError = "Please choose a stronger password"
        }

        agreeToTermsError = !agreeToTerms

        return !agreeToTermsError && emailError.isEmpty && passwordError.isEmpty
            && firstNameError.isEmpty && lastNameError.isEmpty
    }
}
