//
//  ProfileView.swift
//  fit
//
//  Created by Cedric Kienzler on 15.02.25.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: ProfileViewModel
    @FocusState private var focusedField: FocusedField?
    let showJoined: Bool

    init(
        profile: ProfileViewModel, showJoined: Bool = true,
        onSave: @escaping () async -> Void = {}
    ) {
        self.showJoined = showJoined
        profile.onSave = onSave
        _viewModel = StateObject(wrappedValue: profile)
    }

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 5) {
                Image(systemName: "person.circle.fill")  // Placeholder for profile image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .foregroundColor(Color.accentColor)

                Button(action: {}) {
                    Text("Set New Photo")
                }
            }

            // User fields
            VStack(alignment: .leading, spacing: 15) {
                SectionView(title: "First Name") {
                    TextField(
                        "First Name",
                        text: Binding(
                            get: { viewModel.user?.firstName ?? "" },
                            set: { viewModel.user?.firstName = $0 }
                        )
                    )
                    .keyboardType(.default)
                    .textContentType(.name)
                    .focused($focusedField, equals: .firstname)
                    .submitLabel(.next)
                    .foregroundColor(.primary)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 10)
                    .background(Color(.systemGray5).opacity(0.3))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                viewModel.firstNameError.isEmpty
                                    ? Color.accentColor : Color.red,
                                lineWidth: (viewModel.user?.firstName?.isEmpty
                                    == false) ? 1 : 0
                            )
                    )
                    .onSubmit {
                        focusedField = .lastname
                    }

                    if !viewModel.firstNameError.isEmpty {
                        Text(viewModel.firstNameError)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }

                SectionView(title: "Last Name") {
                    TextField(
                        "Last Name",
                        text: Binding(
                            get: { viewModel.user?.lastName ?? "" },
                            set: { viewModel.user?.lastName = $0 }
                        )
                    )
                    .keyboardType(.default)
                    .textContentType(.name)
                    .focused($focusedField, equals: .lastname)
                    .submitLabel(.next)
                    .foregroundColor(.primary)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 10)
                    .background(Color(.systemGray5).opacity(0.3))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                viewModel.lastNameError.isEmpty
                                    ? Color.accentColor : Color.red,
                                lineWidth: (viewModel.user?.lastName?.isEmpty
                                    == false) ? 1 : 0
                            )
                    )
                    .onSubmit {
                        focusedField = .bio
                    }

                    if !viewModel.lastNameError.isEmpty {
                        Text(viewModel.lastNameError)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }

                SectionView(title: "Bio") {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray5).opacity(0.3))
                            .frame(height: 172)

                        TextEditor(
                            text: Binding(
                                get: { viewModel.user?.bio ?? "" },
                                set: {
                                    viewModel.user?.bio = $0
                                    _ = viewModel.validateBio($0)
                                }
                            )
                        )
                        .frame(height: 150)
                        .autocapitalization(.sentences)
                        .multilineTextAlignment(.leading)
                        .keyboardType(.default)
                        .font(.body)
                        .foregroundColor(.primary)
                        .focused($focusedField, equals: .bio)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 10)
                        .cornerRadius(10)
                        .background(Color.clear)
                        .scrollContentBackground(.hidden)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                viewModel.bioError.isEmpty
                                    ? Color.accentColor : Color.red,
                                lineWidth: (viewModel.user?.bio?.isEmpty
                                    == false) ? 1 : 0
                            )
                    )

                    if !viewModel.bioError.isEmpty {
                        Text(viewModel.bioError)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }

            Spacer()

            if viewModel.user != nil && showJoined {
                VStack {
                    if viewModel.user?.createdAt != nil {
                        Text(
                            "Joined: \(viewModel.user?.formatJoinedDate() ?? "")"
                        )

                    }
                    if viewModel.user?.lastUpdatedAt != nil {
                        Text(
                            "Last modified: \(viewModel.user?.formatUpdatedDate() ?? "")"
                        )
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }

            Button(action: {
                Task {
                    if await viewModel.save() {
                        dismiss()
                    }
                }
            }
            ) {
                Text("Save Profile")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }

            if !viewModel.error.isEmpty {
                Text(viewModel.error)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
        }
        .padding()
        .navigationTitle("Profile")
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
        ProfileView(profile: ProfileViewModel())
    }
}
