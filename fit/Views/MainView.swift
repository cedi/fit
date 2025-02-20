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
            if viewModel.isSignedIn {
                if !viewModel.isOnboarded {
                    OnboardingFlowView(profile: viewModel.profile)
                } else {
                    ContentView(profile: profileViewModel)
                }
            } else {
                NavigationView {
                    LoginView()
                }
            }
        }
        .onChange(of: viewModel.isOnboarded) {
            print("User has completed onboarding, switching to ContentView")
        }
    }
}

#Preview {
    NavigationView {
        MainView()
    }
}
