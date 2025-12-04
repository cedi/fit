//
//  MainViewModel.swift
//  fit
//
//  Created by Cedric Kienzler on 05.02.25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

@MainActor
class MainViewViewModel: ObservableObject {
    @Published var isSignedIn: Bool = Auth.auth().currentUser != nil
    @Published var profile: ProfileViewModel
    @Published var isOnboarded: Bool = false
    @Published var isLoaded: Bool = false

    private var authListener: AuthStateDidChangeListenerHandle?

    init(profile: ProfileViewModel) {
        self.profile = profile

        self.profile.$user
            .compactMap { $0?.isOnboarded }
            .assign(to: &$isOnboarded)

        self.authListener = Auth.auth().addStateDidChangeListener {
            [weak self] _, user in
            Task {
                guard let strongSelf = self else {
                    return
                }

                if user == nil {
                    strongSelf.isSignedIn = false
                    strongSelf.isLoaded = true
                    return
                }

                strongSelf.isSignedIn = true
                await strongSelf.profile.fetchUser()
                strongSelf.isLoaded = true
            }
        }
    }
}
