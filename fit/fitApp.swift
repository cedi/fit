//
//  fitApp.swift
//  fit
//
//  Created by Cedric Kienzler on 09.12.24.
//

import FirebaseCore
import SwiftData
import SwiftUI

@main
struct fitApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    let center = UNUserNotificationCenter.current()

    init() {
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .dynamicTypeSize(.xSmall ... .xxxLarge)
                .onAppear(perform: {
                    // this makes sure that we are setting the app to the app delegate as soon as the main view appears
                    appDelegate.app = self
                })
        }
    }
}

struct WorkoutActivityBundle: WidgetBundle {
    var body: some Widget {
        WorkoutActivity()
    }
}
