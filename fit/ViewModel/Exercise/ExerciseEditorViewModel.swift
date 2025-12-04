//
//  ExerciseEditorViewModel.swift
//  fit
//
//  Created by Cedric Kienzler on 23.02.25.
//

import FirebaseFirestore
import Foundation

@MainActor
class ExerciseEditorViewModel: ObservableObject {
    @Published var exercise: FirestoreExercise

    @Published var alternatives: [DocumentReference] = []

    @Published var error: String = ""

    @Published var isImagePickerPresented = false
    @Published var isVideoPickerPresented = false
    @Published var isLoading = false

    private let db = Firestore.firestore()

    init(exercise: FirestoreExercise = FirestoreExercise()) {
        self.exercise = exercise
    }

    // MARK: - User CRUD Operations

    /// Allows saving modifications made to the user object
    /// - Returns:`true` if saving the user was successfull and otherwise `false`
    /// - Note: if false is returned the published `error` var is set to allow displaying error messages in the UI
    func save() async -> Bool {
        guard validate() else {
            return false
        }

        if exercise.id != nil {
            return await updateExercise()
        }
        else {
            return await addExercise()
        }
    }

    /// Allows updating modifications made to the exercise object
    /// - Returns:`true` if saving the exercise was successfull and otherwise `false`
    /// - Note: if false is returned the published `error` var is set to allow displaying error messages in the UI
    func updateExercise() async -> Bool {
        guard validate() else {
            return false
        }

        if let id = exercise.id {
            do {
                let exerciseRef = db.collection("exercises").document(id)
                exercise.lastUpdatedAt = nil
                try exerciseRef.setData(from: exercise)


                print("Exercise successfully updated")
                return true
            } catch {
                setError("Error updating exercise: \(error.localizedDescription)")
            }
        }

        return false
    }

    /// Allows updating modifications made to the exercise object
    /// - Returns:`true` if saving the exercise was successfull and otherwise `false`
    /// - Note: if false is returned the published `error` var is set to allow displaying error messages in the UI
    func addExercise() async -> Bool {
        guard validate() else {
            return false
        }

        do {
            let collectionRef = db.collection("exercises")
            exercise.lastUpdatedAt = nil
            exercise.createdAt = nil
            try collectionRef.addDocument(from: exercise)


            print("Exercise successfully added")
            return true
        } catch {
            setError("Error adding exercise: \(error.localizedDescription)")
        }

        return false
    }

    // MARK: - Validation Functions

    /// check if the current `user` object is valid
    /// - Returns: `true` if the user is valid, otherwise `false`
    /// - Note: Sets the user error string published members
    private func validate() -> Bool {
        return true
    }

    private func setError(_ message: String) {
        DispatchQueue.main.async {
            self.error = message
        }
    }
}
