//
//  ExerciseEditorViewModel.swift
//  fit
//
//  Created by Cedric Kienzler on 23.02.25.
//

import FirebaseFirestore
import Foundation

@MainActor
class TrainingPlanEditorViewModel: ObservableObject {
    @Published var trainingPlan: TrainingPlan
    @Published var isEditing: Bool = false

    @Published var errorMessage: String?
    @Published var isLoading = false

    private let db = Firestore.firestore()

    init(trainingPlan: TrainingPlan = TrainingPlan()) {
        self.trainingPlan = trainingPlan
    }

    // MARK: - User CRUD Operations

    /// Allows saving modifications made to the user object
    /// - Returns:`true` if saving the user was successfull and otherwise `false`
    /// - Note: if false is returned the published `error` var is set to allow displaying error messages in the UI
    func save() async -> Bool {
        guard validate() else {
            return false
        }

        if trainingPlan.id != nil {
            return await updateTrainingPlan()
        } else {
            return await addTrainingPlan()
        }
    }

    /// Allows updating modifications made to the trainingPlan object
    /// - Returns:`true` if saving the trainingPlan was successfull and otherwise `false`
    /// - Note: if false is returned the published `error` var is set to allow displaying error messages in the UI
    func updateTrainingPlan() async -> Bool {
        guard validate() else {
            return false
        }

        if let id = trainingPlan.id {
            do {
                let trainingPlanRef = db.collection("trainingplans").document(
                    id)
                trainingPlan.lastUpdatedAt = nil
                try trainingPlanRef.setData(from: trainingPlan)

                print("Training Plan successfully updated")
                return true
            } catch {
                setError(
                    "Error updating training plan: \(error.localizedDescription)"
                )
            }
        }

        return false
    }

    /// Allows creating a new training plan
    /// - Returns:`true` if saving the training plan was successfull and otherwise `false`
    /// - Note: if false is returned the published `error` var is set to allow displaying error messages in the UI
    func addTrainingPlan() async -> Bool {
        guard validate() else {
            return false
        }

        do {
            let collectionRef = db.collection("trainingplans")
            trainingPlan.lastUpdatedAt = nil
            trainingPlan.createdAt = nil
            try collectionRef.addDocument(from: trainingPlan)

            print("Training Plan successfully added")
            return true
        } catch {
            setError(
                "Error adding Training Plan: \(error.localizedDescription)")
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
            self.errorMessage = message
        }
    }

    // MARK: - Editing

    /// Allow re-ordering of workouts within a week
    func moveWorkoutInWeek(
        in weekIndex: Int, from source: IndexSet, to destination: Int
    ) {
        guard trainingPlan.weeks?[weekIndex] != nil else { return }
        trainingPlan.weeks?[weekIndex].trainings.move(
            fromOffsets: source, toOffset: destination)
    }

    /// Add a new week to a training plan
    func addNewWeek() {
        var weeks: [TrainingPlanWeek] = []

        if trainingPlan.weeks != nil {
            weeks = trainingPlan.weeks!
        }

        let newName = "Week \(weeks.count + 1)"
        let newWeek = TrainingPlanWeek(
            id: UUID().uuidString,
            name: newName,
            repeatCount: 0,
            trainings: []
        )
        weeks.append(newWeek)

        trainingPlan.weeks = weeks
    }

    /// Add a new workout to a week
    func addNewWorkout(weekIndex: Int) {
        var weeks: [TrainingPlanWeek] = []

        if trainingPlan.weeks != nil {
            weeks = trainingPlan.weeks!
        }

        var workouts = weeks[weekIndex].trainings

        let newTraining = Training(
            id: UUID().uuidString,
            name: "New workout",
            exercises: []
        )
        workouts.append(newTraining)

        weeks[weekIndex].trainings = workouts
        trainingPlan.weeks = weeks
    }
}
