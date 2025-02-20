//
//  Untitled.swift
//  fit
//
//  Created by Cedric Kienzler on 18.02.25.
//

import Foundation
import SwiftUI

@MainActor
class OnboardingFlowViewModel: ObservableObject {
    @Published var selectedView = 0
    private let maxNumberOfScreens = 4
    var profileViewModel: ProfileViewModel

    init(profile: ProfileViewModel) {
        self.profileViewModel = profile
    }

    var onboardingViews: [AnyView] {
        [
            AnyView(
                ProfileView(
                    profile: profileViewModel,
                    showJoined: false,
                    onSave: nextView
                )),
            AnyView(NotificationSettingsView(onSave: nextView)),
            AnyView(HealthKitPermissionView(onSave: nextView)),
        ]
    }

    func nextView() {
        if selectedView == onboardingViews.count - 1 {
            Task {
                await profileViewModel.completeOnboarding()
            }
        } else {
            selectedView += 1
        }
    }
}
