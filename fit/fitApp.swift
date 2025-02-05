//
//  fitApp.swift
//  fit
//
//  Created by Cedric Kienzler on 09.12.24.
//

import SwiftData
import SwiftUI
import FirebaseCore

@main
struct fitApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    let center = UNUserNotificationCenter.current()

    init() {
        //registerForNotification()
        let healthManager = HealthManager()

        healthManager.requestAuthorization { success, error in
            if !success {
                if let error = error {
                    print("HealthKit authorization failed: \(error.localizedDescription)")
                }
            }
        }
    }

    func registerForNotification() {
        UIApplication.shared.registerForRemoteNotifications()
        let center: UNUserNotificationCenter =
            UNUserNotificationCenter.current()

        center.requestAuthorization(
            options: [.sound, .alert, .badge],
            completionHandler: { (granted, error) in
                if error != nil {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            })
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                MainView()
                    .dynamicTypeSize(.xSmall ... .xxxLarge)
                    .onAppear(perform: {
                        // this makes sure that we are setting the app to the app delegate as soon as the main view appears
                        appDelegate.app = self
                    })
            }
        }
    }
}

struct WorkoutActivityBundle: WidgetBundle {
    var body: some Widget {
        WorkoutActivity()
    }
}
