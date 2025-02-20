//
//  ProfileViewModel.swift
//  fit
//
//  Created by Cedric Kienzler on 15.02.25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var error: String = ""
    @Published var firstNameError: String = ""
    @Published var lastNameError: String = ""
    @Published var bioError: String = ""

    let bioCharLimit = 200
    let bioLineLimit = 4
    var onSave: (() async -> Void)

    private let db = Firestore.firestore()

    init(onSave: @escaping () async -> Void = {}) {
        self.onSave = onSave

        Task {
            await fetchUser()
        }
    }

    // MARK: - User CRUD Operations

    ///fetchUser fetches the currently logged in user from FireStore
    func fetchUser() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: No valid user found to fetch")
            return
        }

        do {
            let userRef = db.collection("users").document(userId)
            let fetchedUser = try await userRef.getDocument(as: User.self)
            await MainActor.run {
                self.user = fetchedUser
            }
        } catch {
            setError(
                "Error fetching user: \(error.localizedDescription)"
            )
        }
    }

    /// Allows saving modifications made to the user object
    /// - Returns:`true` if saving the user was successfull and otherwise `false`
    /// - Note: if false is returned the published `error` var is set to allow displaying error messages in the UI
    func save() async -> Bool {
        guard validate(), var user = user else {
            return false
        }

        guard let userId = Auth.auth().currentUser?.uid else {
            setError("User not authenticated")
            return false
        }

        do {
            let userRef = db.collection("users").document(userId)
            user.lastUpdatedAt = nil
            try userRef.setData(from: user)
            await onSave()

            print("User successfully updated")
            return true
        } catch {
            setError("Error saving user: \(error.localizedDescription)")
        }

        return false
    }

    /// mark the user as onboarded
    /// - Returns:`true` if saving the user was successfull and otherwise `false`
    /// - SeeAlso: `isNewUser()`
    /// - SeeAlso: `save()`
    func completeOnboarding() async -> Bool {
        await fetchUser()

        guard var user = user else {
            return false
        }

        if user.isOnboarded ?? false {
            return true
        }

        user.isOnboarded = true
        self.user = user

        return await save()
    }

    /// change notification preferences for the user
    /// - Returns:`true` if saving the user was successfull and otherwise `false`
    /// - SeeAlso: `save()`
    func changeNotificationPrefs(isEnabled: Bool, isLiveActivity: Bool) async
        -> Bool
    {
        await fetchUser()

        guard var user = user else {
            return false
        }

        user.notifications = UserNotifications(
            enableNotifications: isEnabled,
            enableLiveActivities: isLiveActivity)

        self.user = user
        return await save()
    }

    // MARK: - Validation Functions

    /// check if the current `user` object is valid
    /// - Returns: `true` if the user is valid, otherwise `false`
    /// - Note: Sets the user error string published members
    private func validate() -> Bool {
        DispatchQueue.main.async {
            self.firstNameError = ""
            self.lastNameError = ""
        }

        guard let user = user else {
            setError("User information is missing")
            return false
        }

        let trimmedFirstName =
            user.firstName?.trimmingCharacters(in: .whitespaces) ?? ""
        let trimmedLastName =
            user.lastName?.trimmingCharacters(in: .whitespaces) ?? ""

        if trimmedFirstName.isEmpty {
            DispatchQueue.main.async {
                self.firstNameError = "Please enter your first name"
            }
        }

        if trimmedLastName.isEmpty {
            DispatchQueue.main.async {
                self.lastNameError = "Please enter your last name"
            }
        }

        return validateBio(user.bio ?? "") && firstNameError.isEmpty
            && lastNameError.isEmpty
    }

    /// check if the user's bio is valid
    /// - Returns: `true` if the user is valid, otherwise `false`
    /// - Note: Sets the `bioError` string published member to indicate the error to an user
    func validateBio(_ bio: String) -> Bool {
        DispatchQueue.main.async {
            self.bioError = ""
        }

        let trimmedBio = bio.trimmingCharacters(in: .whitespaces)

        let pass =
            trimmedBio.count <= bioCharLimit
            && trimmedBio.split(separator: "\n").count <= bioLineLimit

        if !pass {
            DispatchQueue.main.async {
                self.bioError =
                    "Maximum of \(self.bioCharLimit) characters, or \(self.bioLineLimit) lines"
            }
        }

        return pass
    }

    private func setError(_ message: String) {
        DispatchQueue.main.async {
            self.error = message
        }
    }
}
