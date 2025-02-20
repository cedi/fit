//
//  NotificationSettingsView.swift
//  fit
//
//  Created by Cedric Kienzler on 18.02.25.
//

import SwiftUI

struct NotificationSettingRow: View {
    @Binding var isOn: Bool
    let title: String
    let description: String
    let onToggle: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .onChange(of: isOn) {
                    onToggle()
                }
        }
        .padding(.vertical, 6)
    }
}

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: NotificationSettingsViewModel

    init(onSave: @escaping () async -> Void = {}) {
        _viewModel = StateObject(
            wrappedValue: NotificationSettingsViewModel(onSave: onSave))
    }

    var body: some View {
        VStack {
            Form {
                Section(
                    header: Text("Notifications").font(.subheadline)
                        .foregroundColor(.secondary)
                ) {
                    NotificationSettingRow(
                        isOn: $viewModel.isNotificationsEnabled,
                        title: "Enable Notifications",
                        description:
                            "Allow BirkenFit to send you notifications."
                    ) {
                        viewModel.toggleNotifications()
                    }
                }

                if viewModel.isNotificationsEnabled {
                    Section(
                        header: Text("Live Activities").font(.subheadline)
                            .foregroundColor(.secondary)
                    ) {
                        NotificationSettingRow(
                            isOn: $viewModel.isLiveActivityEnabled,
                            title: "Enable Live Activities",
                            description:
                                "Track and interact with your workout directly from the lock screen, helping you stay engaged without distractions."
                        ) {
                            viewModel.toggleLiveActivity()
                        }
                    }
                }
            }

            Spacer()

            Button(action: {
                Task {
                    if await viewModel.save() {
                        dismiss()
                    }
                }
            }
            ) {
                Text("Save Notification Settings")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Notification Settings")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing: HStack {
                Button(action: {
                    Task {
                        if await viewModel.save() {
                            dismiss()
                        }
                    }
                }) {
                    Text("Save")
                }
            }
        )
    }
}

#Preview {
    NavigationView {
        NotificationSettingsView()
    }
}
