//
//  WorkoutViewModel.swift
//  fit
//
//  Created by Cedric Kienzler on 19.03.25.
//

import FirebaseFirestore
import Foundation
import ActivityKit

@MainActor
class WorkoutViewModel: ObservableObject {
    @Published var workout: Training?
    @Published var completedWorkout: CompletedTraining?
    @Published var errorMessage: String?
    @Published var workoutStarted: Bool = false

    @Published var elapsedTime: TimeInterval = 0
    @Published var timer: Timer? = nil
    @Published var workoutDone: Bool = false

    @Published var isEditing: Bool = false
    @Published var isAddWorkoutSheetPresented: Bool = false

    var elapsedTimeFormatted: String {
        let totalSeconds = Int(elapsedTime)
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60

        //        if hours > 0 || hoursOnly {
        //            return String(format: "%02d:%02d", hours, minutes)
        //        } else {
        return String(format: "%02d:%02d", minutes, seconds)
        //        }
    }

    //    @Published private var activity: Activity<WorkoutActivityAttributes>? = nil
    //@StateObject private var workoutState = WorkoutState.shared

    private let exerciseList = ExerciseListViewModel()
    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    var trainingPlanId: String
    var workoutId: String

    init(trainingPlanId: String, workoutId: String) {
        self.trainingPlanId = trainingPlanId
        self.workoutId = workoutId

        subscribe()
    }

    // MARK: - Fetch data from FireBase

    public func unsubscribe() {
        if listenerRegistration != nil {
            listenerRegistration?.remove()
            listenerRegistration = nil
        }
    }

    func subscribe() {
        if listenerRegistration == nil {
            listenerRegistration = db.collection("trainingplans")
                .document(trainingPlanId)
                .addSnapshotListener { [weak self] (documentSnapshot, error) in
                    guard let snapshot = documentSnapshot, snapshot.exists
                    else {
                        self?.errorMessage = "Training plan not found"
                        return
                    }

                    do {
                        let trainingPlan = try snapshot.data(
                            as: TrainingPlan.self)

                        // Find the training inside any week
                        if let foundTraining = trainingPlan.weeks?
                            .flatMap({ $0.trainings })  // Flatten all trainings from weeks
                            .first(where: { $0.id == self?.workoutId })
                        {

                            self?.workout = foundTraining
                        } else {
                            self?.errorMessage =
                                "Training not found in this plan"
                        }

                    } catch {
                        self?.errorMessage =
                            "Error decoding training plan: \(error.localizedDescription)"
                    }
                }
        }
    }

    func getExerciseListSelectionOptions() -> [MultiSelectionOption] {
        var multiSelectOptions: [MultiSelectionOption] = []

        exerciseList.exercises.forEach {exercise in
            multiSelectOptions.append(MultiSelectionOption(
                exercise.name ?? "No name",
                icon: exercise.systemIconName ?? "figure.strengthtraining.traditional",
                data: exercise.id
            ))
        }

        return multiSelectOptions
    }

    // MARK: - Manipulation functions the Workout
    /// Allow re-ordering of exercises in a workout
    func reorderExercise(from source: IndexSet, to destination: Int) {
        workout?.exercises.move(fromOffsets: source, toOffset: destination)
    }

    func getCompletedPercent() -> Double {
        guard let workout = self.workout?.exercises else { return 0.0 }

        let allSets = workout.flatMap { $0.sets }

        let totalSets = allSets.count
        let completedSets = allSets.filter {
            $0.isCompleted ?? false || $0.isSkipped ?? false
        }.count

        return totalSets > 0
            ? Double(completedSets + 1) / Double(totalSets + 1) : 0.0
    }

    // MARK: - Start/Stop Workout

    func workoutStartStopAction() {
        if workoutStarted {
            stopWorkout()
        } else {
            startWorkout()
        }
    }

    func startWorkout() {
        guard let workout = self.workout else { return }

        completedWorkout = CompletedTraining(
            name: workout.name,
            exercises: workout.exercises,
            startTime: Date()
        )

        startTimer()
        workoutStarted = true

//        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
//            print("Live Activities are not enabled.")
//            return
//        }
//        startLiveActivity()
    }

    func stopWorkout() {
        if completedWorkout != nil {
            completedWorkout?.endTime = Date()
        }

        timer?.invalidate()
        workoutDone = true

//        endLiveActivity()
    }

    func startTimer() {
        guard let startTime = self.completedWorkout?.startTime else { return }

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            [weak self] _ in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }

    // MARK: - LiveActivity
//    func startLiveActivity() {
//        let attributes = WorkoutActivityAttributes(name: workout.name)
//        let initialContentState = WorkoutActivityAttributes.ContentState(
//            exercise: workout.nextExercise() ?? Exercise(),
//            setId: workout.nextExercise()?.nextSet()?.id ?? 0
//        )
//
//        let activityContent = ActivityContent(
//            state: initialContentState,
//            staleDate: Date().addingTimeInterval(10)
//        )
//
//        do {
//            activity = try Activity<WorkoutActivityAttributes>.request(
//                attributes: attributes,
//                content: activityContent,
//                pushType: nil
//            )
//
//            //            WorkoutState.shared.setActivity(activity)
//
//            print("Live Activity started with ID: \(activity?.id ?? "error")")
//        } catch {
//            print(
//                "Failed to start Live Activity: \(error.localizedDescription)")
//        }
//    }
//
//    func updateLiveActivity() {
//        guard let activity = activity else { return }
//
//        let state = WorkoutActivityAttributes.ContentState(
//            exercise: workout.nextExercise() ?? Exercise(),
//            setId: workout.nextExercise()?.nextSet()?.id ?? 0
//        )
//
//        let activityContent = ActivityContent(
//            state: state,
//            staleDate: Date().addingTimeInterval(10)
//        )
//
//        Task {
//            await activity.update(activityContent)
//        }
//        print("Live Activity updated successfully!")
//    }
//
//    func endLiveActivity() {
//        guard let activity = activity else { return }
//
//        let finalContentState = WorkoutActivityAttributes.ContentState(
//            exercise: Exercise(), setId: 0
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
}
