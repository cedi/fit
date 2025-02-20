//
//  ProfileView.swift
//  fit
//
//  Created by Cedric Kienzler on 17.01.25.
//

import SwiftUI
import UserNotifications

struct SettingsRow: View {
    let icon: String
    let text: String
    var trailingText: String? = nil

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30, height: 30)
                .foregroundColor(Color.accentColor)
                .clipShape(Circle())

            Text(text)
                .font(.body)
                .foregroundColor(.primary)

            Spacer()

            if let trailingText = trailingText {
                Text(trailingText)
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
        }
    }
}

struct ProfileRow: View {
    @StateObject var profileViewModel = ProfileViewModel()

    var body: some View {
        VStack {
            if profileViewModel.user == nil {
                HStack(alignment: .center) {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle()
                        )
                        .scaleEffect(1.5)  // Adjust size if needed
                        .padding()
                    Spacer()
                }
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "person.circle.fill")  // Placeholder for profile image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .foregroundColor(Color.accentColor)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(
                            "\(profileViewModel.user?.firstName ?? "") \(profileViewModel.user?.lastName ?? "")"
                        )
                        .font(.headline)
                        .foregroundColor(.primary)
                    }

                    Spacer()
                }
            }
        }
        .onAppear {
            Task {
                await profileViewModel.fetchUser()
            }
        }
    }
}

struct SettingsView: View {
    @StateObject var viewModel = SettingsViewModel()

    private var profileViewModel: ProfileViewModel

    init(profile: ProfileViewModel) {
        self.profileViewModel = profile
    }

    var body: some View {
        List {
            // Profile Section
            Section {
                NavigationLink(
                    destination: ProfileView(profile: profileViewModel)
                ) {
                    ProfileRow()
                }
                .buttonStyle(.plain)
            }
            .listRowInsets(EdgeInsets())
            .background(
                Color(
                    UITraitCollection.current.userInterfaceStyle == .dark
                        ? UIColor.systemBackground
                        : UIColor.secondarySystemBackground
                )
            )

            // Settings Categories
            Section {
                SettingsRow(icon: "gearshape.fill", text: "General")

                NavigationLink(destination: NotificationSettingsView()) {
                    SettingsRow(icon: "bell.fill", text: "Notifications")
                }

                SettingsRow(
                    icon: "globe", text: "Language", trailingText: "English"
                )
            }

            // App Version Footer
            Section {
                Button(action: {
                    viewModel.logout()
                }) {
                    SettingsRow(
                        icon: "rectangle.portrait.and.arrow.forward",
                        text: "Logout")
                }

                HStack {
                    Spacer()
                    Text("11.6.270267 AppStore")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .navigationTitle("Settings")
        .listStyle(InsetGroupedListStyle())
    }
}

#Preview {
    NavigationView {
        SettingsView(profile: ProfileViewModel())
    }
}
