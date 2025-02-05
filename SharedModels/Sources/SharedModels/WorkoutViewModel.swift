////
////  WorkoutViewModel.swift
////  SharedModels
////
////  Created by Cedric Kienzler on 20.01.25.
////
//
//
//import SwiftUI
//import ActivityKit
//
//class WorkoutViewModel: ObservableObject {
//    @Published var isWorkoutComplete: Bool = false
//    @Published var activity: Activity<WorkoutActivityAttributes>?
//
//    func start(workout: Workout) async throws {
//        let attributes = WorkoutActivityAttributes(name: workout.name)
//
//        let initialContentState = WorkoutActivityAttributes.ContentState(
//            currentExercise: workout.nextExercise()?.name ?? "",
//            currentSetReps: workout.nextExercise()?.nextSet()?.reps ?? 0,
//            currentSetWeight: workout.nextExercise()?.nextSet()?.weight ?? 0
//        )
//
//        let activityContent = ActivityContent(
//            state: initialContentState,
//            staleDate: nil
//        )
//
//        let activity = try await Activity<WorkoutActivityAttributes>.request(
//            attributes: attributes,
//            content: activityContent,
//            pushType: nil
//        )
//
//        self.activity = activity
//    }
//
//    @MainActor
//    func update() {
//        guard let activity = activity else { return }
//
//        let state = WorkoutActivityAttributes.ContentState(
//            currentExercise: workout.nextExercise()?.name ?? "",
//            currentSetReps: workout.nextExercise()?.nextSet()?.reps ?? 0,
//            currentSetWeight: workout.nextExercise()?.nextSet()?.weight ?? 0
//        )
//
//        let activityContent = ActivityContent(
//            state: state,
//            staleDate: nil
//        )
//
//        Task {
//            await activity.update(activityContent)
//        }
//        print("Live Activity updated successfully!")
//    }
//
//    @MainActor
//    func end() {
//        guard let activity = activity else { return }
//
//        let finalContentState = WorkoutActivityAttributes.ContentState(
//            currentExercise: "Done",
//            currentSetReps: 0,
//            currentSetWeight: 0
//        )
//
//        let finalActivityContent = ActivityContent(
//            state: finalContentState,
//            staleDate: nil
//        )
//
//        Task {
//            await activity.end(
//                finalActivityContent, dismissalPolicy: .immediate)
//        }
//        print("Live Activity ended successfully!")
//    }
//
//    func completeWorkout() async {
//        guard let activity = activity else { return }
//
//        let finalContentState = WorkoutActivityAttributes.ContentState(
//            currentExercise: "Done",
//            currentSetReps: 0,
//            currentSetWeight: 0,
//            setsCompleted: 0,
//            totalSets: 0
//        )
//
//        let finalActivityContent = ActivityContent(
//            state: finalContentState,
//            staleDate: nil
//        )
//
//        do {
//            try await activity.end(finalActivityContent, dismissalPolicy: .immediate)
//            isWorkoutComplete = true
//            print("Workout completed!")
//        } catch {
//            print("Failed to complete the workout: \(error.localizedDescription)")
//        }
//    }
//}
