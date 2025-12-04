//
//  DebugViewModel.swift
//  fit
//
//  Created by Cedric Kienzler on 21.02.25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

@MainActor
class DebugViewModel: ObservableObject {
    @Published var profile: ProfileViewModel
    @Published var isOnboarded: Bool = false

    init(profile: ProfileViewModel) {
        self.profile = profile

        self.profile.$user
            .compactMap { $0?.isOnboarded }
            .assign(to: &$isOnboarded)
    }

    func toggleUserOnboarding() async -> Bool {
        guard var user = profile.user else { return false }

        user.isOnboarded = isOnboarded
        profile.user = user
        return await profile.save()
    }
}
