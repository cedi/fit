//
//  HomeView.swift
//  fit
//
//  Created by Cedric Kienzler on 09.12.24.
//

import Combine
import SwiftUI
import UserNotifications
import ActivityKit

struct HomeView: View {
    @StateObject var notificationService = NotificationService()

    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome to Notifications Demo")
                .font(.headline)

            Button("Request Permission") {

                Task {
                    await notificationService
                        .requestPushNotificationAuthorization()
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()

            Button("Start Live Activity") {
                //createActivity()
            }

            Stepper(
                "Badge Number \(notificationService.badgeNumber != 0 ? notificationService.badgeNumber.description : "")",
                value: $notificationService.badgeNumber, in: 0...Int.max
            )

            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .fullScreenCover(
            isPresented: $notificationService.showSettingsPage,
            content: {
                // your settings page here
                VStack {
                    Text("Settings Page").font(.title)
                    Text("All your settings here").font(.subheadline)
                    Button("Dismiss") {
                        notificationService.showSettingsPage = false
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                }
            }
        )
        .padding()
    }
}


final class NotificationService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var showSettingsPage = false
    @Published var badgeNumber = 0
    var cancellables = Set<AnyCancellable>()

    @MainActor
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self

        $badgeNumber
            .drop(while: { $0 < 1 })
            .sink { badgeNumber in
                UIApplication.shared.applicationIconBadgeNumber = badgeNumber
            }.store(in: &cancellables)
    }

    @MainActor
    func requestPushNotificationAuthorization() async {
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(
                options: [
                    .alert,
                    .sound,
                    .badge,
                    .carPlay,
                    .provisional,
                    .criticalAlert,
                    .providesAppNotificationSettings,
                ]
            )


        } catch {
            print("Failed to request notification authorization: \(error)")
        }

        let testNotificationCategory = UNNotificationCategory(identifier: "testNotificationCategory", actions: [], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([testNotificationCategory])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        openSettingsFor notification: UNNotification?
    ) {
        showSettingsPage = true
    }

    func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            didReceive response: UNNotificationResponse
        ) async {
            if response.actionIdentifier == "TICK_OFF_SET" {
                // Logic to handle ticking off the set
                print("Set ticked off!")

                // Notify about rest timer
                scheduleRestTimerNotification(restTime: 3)
            } else if response.actionIdentifier == "START_REST_TIMER" {
                // Logic to start the rest timer
                print("Rest timer started!")
            }
        }

    func scheduleRestTimerNotification(restTime: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Rest Timer"
        content.body = "Your \(restTime)-minute rest timer has started."
        content.sound = .default

        // Trigger after the rest period
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(restTime * 60), repeats: false)

        let request = UNNotificationRequest(
            identifier: "REST_TIMER_NOTIFICATION",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}


#Preview {
    HomeView()
}
