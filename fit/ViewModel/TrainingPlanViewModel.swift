//
//  TrainingPlanViewModel.swift
//  fit
//
//  Created by Cedric Kienzler on 16.02.25.
//

import SharedModels
import SwiftUI

@MainActor
class TrainingPlanViewModel: ObservableObject {
    @Published var trainingPlan: [WorkoutWeek] = [
        WorkoutWeek(
            number: 1,
            workouts: [deadliftWorkout, deadliftWorkout, deadliftWorkout],
            repeatCount: 1),
        WorkoutWeek(
            number: 2, workouts: [deadliftWorkout, deadliftWorkout],
            repeatCount: 1),
    ]

    @Published var isEditing = false
    @Published var editMode: EditMode = .inactive

    func addWeek() {
        let newWeek = WorkoutWeek(
            number: trainingPlan.count + 1, workouts: [], repeatCount: 1)
        trainingPlan.append(newWeek)
    }

    @MainActor
    func addWorkout(to weekIndex: Int) {
        trainingPlan[weekIndex].workouts.append(deadliftWorkout)
    }

    func deleteWorkout(from weekIndex: Int, workout: Workout) {
        if let index = trainingPlan[weekIndex].workouts.firstIndex(of: workout)
        {
            trainingPlan[weekIndex].workouts.remove(at: index)
        }
    }

    func moveWorkout(from source: IndexSet, to destination: Int, weekIndex: Int)
    {
        guard let fromIndex = source.first else { return }
        let movedWorkout = trainingPlan[weekIndex].workouts.remove(
            at: fromIndex)

        if destination < trainingPlan[weekIndex].workouts.count {
            trainingPlan[weekIndex].workouts.insert(
                movedWorkout, at: destination)
        } else {
            moveWorkoutToAnotherWeek(movedWorkout, fromWeek: weekIndex)
        }
    }

    private func moveWorkoutToAnotherWeek(_ workout: Workout, fromWeek: Int) {
        guard trainingPlan.count > 1 else { return }
        let nextWeekIndex = (fromWeek + 1) % trainingPlan.count
        trainingPlan[nextWeekIndex].workouts.append(workout)
    }
}
