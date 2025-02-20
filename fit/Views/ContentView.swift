//
//  ContentView.swift
//  fit
//
//  Created by Cedric Kienzler on 09.12.24.
//

import SharedModels
import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    enum Tab {
        case home, session, plan, settings
    }

    private var profileViewModel: ProfileViewModel

    init(profile: ProfileViewModel = .init()) {
        self.profileViewModel = profile
    }

    var body: some View {
        TabView {
            NavigationView {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            .tag(Tab.home)

            NavigationView {
                WorkoutView(workout: deadliftWorkout)
            }
            .tabItem {
                Image(systemName: "figure.strengthtraining.traditional")
                Text("Workout")
            }
            .tag(Tab.session)

            NavigationView {
                TrainingPlanView()
            }
            .tabItem {
                Image(systemName: "list.triangle")
                Text("Trainings Plan")
            }
            .tag(Tab.plan)

            NavigationView {
                SettingsView(profile: profileViewModel)
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(Tab.settings)
        }
    }
}

#Preview {
    NavigationView {
        ContentView()
    }
}
