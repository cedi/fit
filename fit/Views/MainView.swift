//
//  MainView.swift
//  fit
//
//  Created by Cedric Kienzler on 05.02.25.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel: MainViewViewModel

    private var profileViewModel: ProfileViewModel

    init(profileViewModel: ProfileViewModel = .init()) {
        self.profileViewModel = profileViewModel
        _viewModel = StateObject(
            wrappedValue: MainViewViewModel(profile: profileViewModel)
        )
    }

    var body: some View {
        Group {
            if !viewModel.isLoaded {
                SplashScreenView()
            } else if !viewModel.isSignedIn {
                NavigationView {
                    LoginView()
                }
            } else {
                if !viewModel.isOnboarded {
                    OnboardingFlowView(profile: viewModel.profile)
                } else {
                    ContentView(profile: profileViewModel)
                }
            }
        }
        .onChange(of: viewModel.isOnboarded) {
            print("User has completed onboarding, switching to ContentView")
        }
        .onChange(of: viewModel.isLoaded) {
            print("User has loaded")
        }
        .onChange(of: viewModel.isSignedIn) {
            print("User has changed")
        }
    }
}

#Preview {
    NavigationView {
        MainView()
    }
}
