//
//  HealthKitPermissionView.swift
//  fit
//
//  Created by Cedric Kienzler on 20.02.25.
//

import SwiftUI

struct HealthKitPermissionView: View {
    @StateObject private var viewModel: HealthKitPermissionViewModel

    init(onSave: @escaping () async -> Void = {}) {
        _viewModel = StateObject(
            wrappedValue: HealthKitPermissionViewModel(onSave: onSave))
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.text.square.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.red)

            Text("Health Access Required")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text(
                "To save your workouts to Apple Health, please grant access to HealthKit."
            )
            .font(.body)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)

            Button(action: {
                viewModel.requestAuthorization()
            }) {
                Text("Enable Health Access")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
        }
        .padding()
        .alert(
            "HealthKit Access Denied",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },  // Show alert if there's an error message
                set: { if !$0 { viewModel.errorMessage = nil } }  // Dismiss alert when user presses "OK"
            )
        ) {
            Button("OK") {
                if let settingsURL = URL(
                    string: UIApplication.openSettingsURLString)
                {
                    UIApplication.shared.open(settingsURL)
                }
            }
        } message: {
            Text(
                viewModel.errorMessage
                    ?? "Please enable HealthKit access in your device settings."
            )
        }
    }
}
