//
//  MainViewModel.swift
//  fit
//
//  Created by Cedric Kienzler on 05.02.25.
//

import FirebaseAuth
import Foundation

class MainViewViewModel: ObservableObject {
    @Published var currentUid: String = ""
    private var handler: AuthStateDidChangeListenerHandle?

    @MainActor
    init() {
        self.handler = Auth.auth().addStateDidChangeListener {
            [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUid = user?.uid ?? ""
            }
        }
    }

    public var isSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }
}
