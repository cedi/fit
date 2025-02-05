//
//  ExerciseView.swift
//  fit
//
//  Created by Cedric Kienzler on 15.01.25.
//

import ActivityKit
import SharedModels
import SwiftUI
import WidgetKit

struct StickyHeader: View {
    @Binding var workoutGroup: WorkoutGroup

    var body: some View {
        HStack {
            Text(workoutGroup.name)
                .font(.subheadline)
                .padding(.vertical, 8)

            if workoutGroup.expectedDurationMin > 0 {
                Text("(\(workoutGroup.expectedDurationMin)min)")
                    .font(.subheadline)
                    .padding(.vertical, 8)
            }
        }
    }
}

struct WorkoutListView: View {
    @Binding var workout: Workout
    @Binding var currentExercise: Exercise?
    @Binding var workoutStarted: Bool
    let completeSet: (Binding<ExerciseSet>, Bool) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach($workout.workout) { $group in
                    Section(
                        header: StickyHeader(workoutGroup: $group)
                    ) {
                        ForEach($group.exercises) { $exercise in
                            WorkoutExerciseView(
                                exercise: $exercise,
                                workoutStarted: $workoutStarted,
                                isCurrentExercise: currentExercise?.id
                                    == exercise.id,
                                completeSet: completeSet
                            )
                            .listRowInsets(EdgeInsets())
                            .id(exercise.id)
                            .swipeActions(
                                edge: .leading, allowsFullSwipe: true
                            ) {
                                Button(role: .cancel) {} label: {
                                    Label("PR", systemImage: "trophy")
                                }
                                .tint(Color.orange)
                            }
                            .swipeActions(
                                edge: .leading, allowsFullSwipe: false
                            ) {
                                Button(role: .cancel) {} label: {
                                    Label("Note", systemImage: "pencil.and.list.clipboard")
                                }
                            }
                            .swipeActions(
                                edge: .trailing, allowsFullSwipe: true
                            ) {
                                Button(role: .cancel) {} label: {
                                    Label("Done", systemImage: "checkmark.circle")
                                }
                                .tint(Color.accentColor)
                            }
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .padding(.horizontal, 0)
            .background()
            .onChange(of: workout) {
                currentExercise = workout.nextExercise()

                if let exercise = currentExercise {
                    withAnimation {
                        proxy.scrollTo(exercise.id, anchor: .center)
                    }
                }
            }
        }
    }
}

struct WorkoutView: View {
    @State var workout: Workout
    @State var currentExercise: Exercise?
    @State private var workoutStarted: Bool = false

    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var workoutDone: Bool = false

    @State private var activity: Activity<WorkoutActivityAttributes>? = nil
    //@StateObject private var workoutState = WorkoutState.shared

    init(workout: Workout) {
        self.workout = workout
        self.currentExercise = workout.nextExercise()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            WorkoutListView(
                workout: $workout,
                currentExercise: $currentExercise,
                workoutStarted: $workoutStarted,
                completeSet: completeSet
            )

            Spacer()

            ProgressView(value: workout.getCompletedPercent())
                .progressViewStyle(
                    LinearProgressViewStyle(tint: Color.accentColor)
                )
                .animation(.easeInOut, value: workout.getCompletedPercent())
                .frame(height: 1)
                .padding()

            HStack(alignment: .center) {
                HStack {
                    if workoutStarted {
                        NavigationLink(
                            destination:
                                WorkoutCompleteView(
                                    workout: $workout,
                                    showView: $workoutDone,
                                    isNavigatingBack: $workoutStarted
                                )
                        ) {
                            HStack {
                                Image(systemName: "trophy")
                                Text("Done")
                                    .bold()
                                Text("(\(formatElapsedTime(elapsedTime)))")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                        }
                        .onDisappear {
                            if workoutStarted {
                                startTimer()
                            }
                        }
                    } else {
                        Button(action: workoutBtnAction) {
                            HStack {
                                Image(systemName: "play")
                                Text("Start")
                            }.padding()
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .font(.headline)
            .foregroundColor(.white)
            .background(Color.accentColor)
            .cornerRadius(10)
            .onDisappear {
                timer?.invalidate()
            }
            .navigationBarItems(
                trailing: HStack {
                    if workoutStarted {
                        NavigationLink(
                            destination:
                                WorkoutCompleteView(
                                    workout: $workout,
                                    showView: $workoutDone,
                                    isNavigatingBack: $workoutStarted
                                )
                        ) {
                            Text("Done")
                                .bold()
                        }
                        .onDisappear {
                            if workoutStarted {
                                startTimer()
                            }
                        }
                    } else {
                        Button(action: workoutBtnAction) {
                            Text("Start")
                        }
                    }
                }
            )
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle(workout.name)
        .onChange(of: workout) {
            updateLiveActivity()
        }
    }

    func startWorkout() {
        workout.startTime = Date()
        startTimer()

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled.")
            return
        }

        startLiveActivity()

        withAnimation {
            workoutStarted = true
        }
    }

    func stopWorkout() {
        workout.endTime = Date()  // Save end time
        timer?.invalidate()  // stop the timer

        endLiveActivity()

        withAnimation {
            workoutDone = true
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task {
                await updateElapsedTime()
            }
        }
    }

    private func workoutBtnAction() {
        if workoutStarted {
            stopWorkout()
        } else {
            startWorkout()
        }
    }

    private func completeSet(
        set: Binding<ExerciseSet>, skipSet: Bool
    ) {
        var exercise: Exercise? = nil

        for group in workout.workout {
            for e in group.exercises {
                if e.sets.contains(where: { $0.id == set.id }) {
                    exercise = e
                }
            }
        }

        guard let currentExercise = exercise else { return }

        // Handle incomplete sets
        if let firstIncompleteSet = currentExercise.findFirstIncompleteSet() {
            if !set.wrappedValue.isCompleted && !set.wrappedValue.isSkipped {
                withAnimation {
                    completeOrSkipSet(
                        firstIncompleteSet, in: $workout, skip: skipSet)

                    if !workoutStarted {
                        startWorkout()
                    }
                }
                return
            }
        }

        // Handle undo of the last completed/skipped set
        if let lastHandledSet = currentExercise.findLastHandledSet() {
            withAnimation {
                undoLastHandledSet(lastHandledSet, in: $workout)
            }
        }
    }

    private func completeOrSkipSet(
        _ set: ExerciseSet, in workout: Binding<Workout>, skip: Bool
    ) {
        updateSet(set, in: workout) { set in
            if skip {
                set.isSkipped = true
            } else {
                set.isCompleted = true
            }
        }
    }

    private func undoLastHandledSet(
        _ set: ExerciseSet, in workout: Binding<Workout>
    ) {
        updateSet(set, in: workout) { set in
            set.isCompleted = false
            set.isSkipped = false
        }
    }

    private func updateSet(
        _ targetSet: ExerciseSet, in workout: Binding<Workout>,
        update: (inout ExerciseSet) -> Void
    ) {
        for groupIndex in workout.wrappedValue.workout.indices {
            for exerciseIndex in workout.wrappedValue.workout[groupIndex]
                .exercises.indices
            {
                if let setIndex = workout.wrappedValue.workout[groupIndex]
                    .exercises[exerciseIndex].sets.firstIndex(where: {
                        $0.id == targetSet.id
                    })
                {
                    //                    Task {
                    //                        await workoutState.completeSet(setId: targetSet.id)
                    //                    }

                    update(
                        &workout.wrappedValue.workout[groupIndex].exercises[
                            exerciseIndex
                        ].sets[setIndex])
                    return
                }
            }
        }
    }

    @MainActor
    func startLiveActivity() {
        let attributes = WorkoutActivityAttributes(name: workout.name)
        let initialContentState = WorkoutActivityAttributes.ContentState(
            exercise: workout.nextExercise() ?? Exercise(),
            setId: workout.nextExercise()?.nextSet()?.id ?? 0
        )

        let activityContent = ActivityContent(
            state: initialContentState,
            staleDate: Date().addingTimeInterval(10)
        )

        do {
            activity = try Activity<WorkoutActivityAttributes>.request(
                attributes: attributes,
                content: activityContent,
                pushType: nil
            )

            //            WorkoutState.shared.setActivity(activity)

            print("Live Activity started with ID: \(activity?.id ?? "error")")
        } catch {
            print(
                "Failed to start Live Activity: \(error.localizedDescription)")
        }
    }

    @MainActor
    func updateLiveActivity() {
        guard let activity = activity else { return }

        let state = WorkoutActivityAttributes.ContentState(
            exercise: workout.nextExercise() ?? Exercise(),
            setId: workout.nextExercise()?.nextSet()?.id ?? 0
        )

        let activityContent = ActivityContent(
            state: state,
            staleDate: Date().addingTimeInterval(10)
        )

        Task {
            await activity.update(activityContent)
        }
        print("Live Activity updated successfully!")
    }

    @MainActor
    func endLiveActivity() {
        guard let activity = activity else { return }

        let finalContentState = WorkoutActivityAttributes.ContentState(
            exercise: Exercise(), setId: 0
        )

        let finalActivityContent = ActivityContent(
            state: finalContentState,
            staleDate: nil
        )

        Task {
            await activity.end(
                finalActivityContent, dismissalPolicy: .immediate)
        }
        print("Live Activity ended successfully!")
    }

    @MainActor
    private func updateElapsedTime() {
        guard let startTime = workout.startTime else { return }
        elapsedTime = Date().timeIntervalSince(startTime)
    }

    private func formatElapsedTime(
        _ time: TimeInterval, hoursOnly: Bool = false
    ) -> String {
        let totalSeconds = Int(time)
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        let hours = totalSeconds / 3600

        if hours > 0 || hoursOnly {
            return String(format: "%02d:%02d", hours, minutes)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

#Preview {
    NavigationView {
        WorkoutView(workout: deadliftWorkout)
    }
}
