//
//  NotificationSettingsViewModel.swift
//  fit
//
//  Created by Cedric Kienzler on 18.02.25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI

@MainActor
class NotificationSettingsViewModel: ObservableObject {
    @Published var isNotificationsEnabled: Bool = true
    @Published var isLiveActivityEnabled: Bool = true

    let onSave: () async -> Void
    private let profileViewModel: ProfileViewModel

    init(onSave: @escaping () async -> Void = {}) {
        self.onSave = onSave
        self.profileViewModel = ProfileViewModel(onSave: onSave)

        // Observe profileViewModel.user changes
        Task {
            for await user in profileViewModel.$user.values {
                if let user = user {
                    self.isNotificationsEnabled =
                        user.notifications?.enableNotifications ?? true
                    self.isLiveActivityEnabled =
                        user.notifications?.enableLiveActivities ?? true
                }
            }
        }
    }

    func toggleNotifications() {
        //        if isNotificationsEnabled {
        //            if let appSettings = URL(
        //                string: UIApplication
        //                    .openNotificationSettingsURLString
        //            ),
        //                UIApplication.shared
        //                    .canOpenURL(appSettings)
        //            {
        //                UIApplication.shared.open(appSettings)
        //            }
        //        }
    }

    func toggleLiveActivity() {
    }

    func save() async -> Bool {
        return await profileViewModel.changeNotificationPrefs(
            isEnabled: isNotificationsEnabled,
            isLiveActivity: isLiveActivityEnabled)
    }
}
