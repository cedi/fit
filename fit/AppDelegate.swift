//
//  CustomAppDelegate.swift
//  fit
//
//  Created by Cedric Kienzler on 17.01.25.
//

//  CustomAppDelegate.swift
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    // This gives us access to the methods from our main app code inside the app delegate
    var app: fitApp?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // This is where we register this device to recieve push notifications from Apple
        // All this function does is register the device with APNs, it doesn't set up push notifications by itself
        application.registerForRemoteNotifications()

        // Setting the notification delegate
        UNUserNotificationCenter.current().delegate = self

        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Once the device is registered for push notifications Apple will send the token to our app and it will be available here.
        // This is also where we will forward the token to our push server
        // If you want to see a string version of your token, you can use the following code to print it out
        let stringifiedToken = deviceToken.map {
            String(format: "%02.2hhx", $0)
        }.joined()
        print("stringifiedToken:", stringifiedToken)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // This function lets us do something when the user interacts with a notification
    // like log that they clicked it, or navigate to a specific screen
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        // Extract the title and safely extract specific values from userInfo
        let title = response.notification.request.content.title
        let userInfo = response.notification.request.content.userInfo

        // Extract specific, safe keys from userInfo
        let customKey = userInfo["customKey"] as? String ?? "No custom key"

        // Safely pass extracted data to the main actor
        await MainActor.run {
            print("Notification title: \(title)")
            print("Custom key: \(customKey)")
        }
    }

    // This function allows us to view notifications in the app even with it in the foreground
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return await MainActor.run {
            // Safely return options from the main actor
            return [.badge, .banner, .list, .sound]
        }
    }
}

