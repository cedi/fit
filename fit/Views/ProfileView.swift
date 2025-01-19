//
//  ProfileView.swift
//  fit
//
//  Created by Cedric Kienzler on 17.01.25.
//

import SwiftUI
import UserNotifications

struct ProfileView: View {
    @State private var showNotifications: Bool = false

    var body: some View {
        NavigationStack {
            List {
                // Profile Section
                Section {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "person.circle.fill")  // Placeholder for profile image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .foregroundColor(Color.accentColor)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("John Doe")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }

                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .padding(.trailing, 20)
                        }
                    }
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
                    SettingsRow(
                        icon: "gearshape.fill", text: "General",
                        showView: .constant(false))
                    SettingsRow(
                        icon: "bell.fill",
                        text: "Notifications",
                        showView: $showNotifications
                    )
                    .navigationDestination(isPresented: $showNotifications) {
                        NotificationSettingsView(
                            showView: $showNotifications
                        )
                    }
                }

                Section {
                    SettingsRow(
                        icon: "globe", text: "Language",
                        trailingText: "English", showView: .constant(false))
                }

                Section {
                    SettingsRow(
                        icon: "message.fill", text: "Ask a Question",
                        showView: .constant(false))
                }

                // App Version Footer
                Section {
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
}

struct SettingsRow: View {
    let icon: String
    let text: String
    var trailingText: String? = nil
    @Binding var showView: Bool

    var body: some View {
        Button(action: {
            showView = true
        }) {
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

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
    }
}

struct NotificationSettingsView: View {
    @Binding var showView: Bool
    @State var notificationsOn: Bool = true

    var body: some View {
        List {
            HStack {
                Text("Notification Enabled")
                    .font(.body)
                    .foregroundColor(.primary)

                Spacer()

                Toggle("", isOn: $notificationsOn)
                    .onChange(of: notificationsOn) {
                        if let appSettings = URL(
                            string: UIApplication
                                .openNotificationSettingsURLString
                        ),
                            UIApplication.shared
                                .canOpenURL(appSettings)
                        {
                            UIApplication.shared.open(appSettings)
                        }
                    }
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    ProfileView()
}
