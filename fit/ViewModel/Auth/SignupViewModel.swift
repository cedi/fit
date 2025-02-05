//
//  Signup.swift
//  fit
//
//  Created by Cedric Kienzler on 04.02.25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class SignupViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var agreeToTerms: Bool = false
    @Published var emailError: String = ""
    @Published var passwordError: String = ""
    @Published var agreeToTermsError: Bool = false

    init() {}

    func signup() {
        guard validate() else {
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let userId = result?.user.uid else {
                return
            }

            self?.insertUser(uid: userId)
        }
    }

    private func insertUser(uid: String) {
        let newUser = User(
            uid: uid,
            email: email,
            joined: Date().timeIntervalSince1970
        )

        let db = Firestore.firestore()

        db.collection("users")
            .document(uid)
            .setData(newUser.asDict())
    }

    private func validate() -> Bool {
        var anyErr: Bool = false;

        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            emailError = "Please enter your email address"
            anyErr = true
        }

        if password.trimmingCharacters(in: .whitespaces).isEmpty {
            emailError = "Please enter your password"
            anyErr = true
        }

        if !email.trimmingCharacters(in: .whitespaces).isEmpty && (!email.contains("@") || !email.contains(".")) {
            emailError = "Please enter a valid email address"
            anyErr = true
        } else {
            emailError = ""
        }

        if !password.trimmingCharacters(in: .whitespaces).isEmpty && password.count < 6 {
            passwordError = "Please choose a stronger password"
            anyErr = true
        } else {
            passwordError = ""
        }

        if !agreeToTerms {
            agreeToTermsError = true
            anyErr = true
        } else {
            agreeToTermsError = false
        }

        return !anyErr
    }
}
