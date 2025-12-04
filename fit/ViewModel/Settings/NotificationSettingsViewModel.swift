//
//  NotificationSettingsViewModel.swift
//  fit
//
//  Created by Cedric Kienzler on 18.02.25.
//

import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI
import UserNotifications

@MainActor
class NotificationSettingsViewModel: NSObject, ObservableObject,
    UNUserNotificationCenterDelegate
{
    @Published var isNotificationsEnabled: Bool = true
    @Published var isLiveActivityEnabled: Bool = true

    let onSave: () async -> Void
    private let profileViewModel: ProfileViewModel

    init(onSave: @escaping () async -> Void = {}) {
        self.onSave = onSave
        self.profileViewModel = ProfileViewModel(onSave: onSave)

        super.init()
        UNUserNotificationCenter.current().delegate = self

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

    @MainActor
    func requestPushNotificationAuthorization() async {
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(
                options: [
                    .alert,
                    .sound,
                    .badge,
                    .provisional,
                ]
            )

        } catch {
            print("Failed to request notification authorization: \(error)")
        }

        let testNotificationCategory = UNNotificationCategory(
            identifier: "testNotificationCategory", actions: [],
            intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([
            testNotificationCategory
        ])
    }

    func toggleNotifications() {
        if isNotificationsEnabled {
            Task {
                await requestPushNotificationAuthorization()
            }
            //                    if let appSettings = URL(
            //                        string: UIApplication
            //                            .openNotificationSettingsURLString
            //                    ),
            //                        UIApplication.shared
            //                            .canOpenURL(appSettings)
            //                    {
            //                        UIApplication.shared.open(appSettings)
            //                    }
        }
    }

    func toggleLiveActivity() {
    }

    func save() async -> Bool {
        return await profileViewModel.changeNotificationPrefs(
            isEnabled: isNotificationsEnabled,
            isLiveActivity: isLiveActivityEnabled)
    }
}
