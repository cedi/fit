//
//  OnboardingFlowView.swift
//  fit
//
//  Created by Cedric Kienzler on 17.02.25.
//

import SwiftUI

struct OnboardingFlowView: View {
    @StateObject var viewModel: OnboardingFlowViewModel

    init(profile: ProfileViewModel) {
        _viewModel = StateObject(
            wrappedValue: OnboardingFlowViewModel(profile: profile))
    }

    var body: some View {
        VStack(alignment: .center) {
            Spacer()

            // Render the current onboarding step
            viewModel.onboardingViews[viewModel.selectedView]

            Spacer()

            HStack {
                // Add a tab index indicator, similar to using a TabView().tabViewStyle(.page)
                // Each circle represents a step. The current step is filled, others are outlined.
                ForEach(0..<viewModel.onboardingViews.count, id: \.self) {
                    index in
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(
                            index == viewModel.selectedView
                                ? Color.accentColor : Color.gray.opacity(0.5))
                }
            }
        }
    }
}

#Preview {
    OnboardingFlowView(
        profile: ProfileViewModel()
    )
}
