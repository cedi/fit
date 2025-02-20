//
//  ProfileViewModel.swift
//  fit
//
//  Created by Cedric Kienzler on 05.02.25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class SettingsViewModel: ObservableObject {
    @Published var user: User? = nil

    init() {}

    //    func fetchUser() {
    //        guard let userId = Auth.auth().currentUser?.uid else {
    //            return
    //        }
    //
    //        let db = Firestore.firestore()
    //        db.collection("users").document(userId) {
    //            [weak self]
    //            snapshot,
    //            error in
    //            guard let data = snapshot?.data(),
    //                err == nil
    //            else {
    //                return
    //            }
    //
    //            DispatchQueue.main.async {
    //                self?.user = User(
    //                    uid: data["id"] as? String ?? "",
    //                    email: data["email"] as? String ?? "",
    //                    joined: data["joined"] as? TimeInterval ?? 0
    //                )
    //            }
    //        }
    //    }

    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
}
