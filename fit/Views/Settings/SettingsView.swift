//
//  ProfileView.swift
//  fit
//
//  Created by Cedric Kienzler on 17.01.25.
//

import SwiftUI
import UserNotifications

struct ProfileRow: View {
    @StateObject var viewModel: ProfileViewModel

    init(profile: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: profile)
    }

    var body: some View {
        VStack {
            if viewModel.user == nil {
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
                            "\(viewModel.user?.firstName ?? "") \(viewModel.user?.lastName ?? "")"
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
                await viewModel.fetchUser()
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
        VStack {
            List {
                // Profile Section
                Section {
                    NavigationLink(
                        destination: ProfileView(profile: profileViewModel)
                    ) {
                        ProfileRow(profile: profileViewModel)
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
                    NavigationLink(destination: NotificationSettingsView()) {
                        ListViewIconRow(
                            text: "Notifications", icon: "bell.fill")
                    }

                    ListViewIconRow(
                        text: "Language", icon: "globe", trailingText: "English"
                    )
                }

                Section("Exercises") {
                    NavigationLink(
                        destination: ExerciseListView(
                            viewModel: createExerciseListMockVM())
                    ) {
                        ListViewIconRow(
                            text: "Exercises",
                            icon: "figure.strengthtraining.traditional")
                    }
                }

                #if DEBUG
                    Section("Debug Settings") {
                        NavigationLink(
                            destination: DebugView(profile: profileViewModel)
                        ) {
                            ListViewIconRow(
                                text: "Debug Settings", icon: "ladybug.fill")
                        }
                    }
                #endif
            }

            Spacer()

            // App Version Footer
            VStack(alignment: .center, spacing: 10) {
                Button(action: {
                    viewModel.logout()
                }) {
                    HStack {
                        Image(
                            systemName: "rectangle.portrait.and.arrow.forward"
                        )
                        .foregroundColor(.red)

                        Text("Logout")
                            .foregroundColor(.red)
                            .fontWeight(.bold)
                    }
                }

                Text("Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown Version") (Build \(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown build"))")
                    .font(.footnote)
                    .foregroundColor(.secondary)

            }
            .padding(.vertical, 10)
            .padding(.horizontal)
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
