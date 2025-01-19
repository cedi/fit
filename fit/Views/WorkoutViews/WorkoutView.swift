//
//  ExerciseView.swift
//  fit
//
//  Created by Cedric Kienzler on 15.01.25.
//

import SwiftUI

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
                                    == exercise.id
                            )
                            .listRowInsets(EdgeInsets())
                            .id(exercise.id)
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

struct WorkoutControlsView: View {
    @Binding var workout: Workout
    @Binding var workoutStarted: Bool

    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var workoutDone: Bool = false

    var body: some View {
        HStack(alignment: .center) {
            Button(action: workoutBtnAction) {
                HStack {
                    Image(systemName: workoutStarted ? "trophy" : "play")
                    Text(workoutStarted ? "Done" : "Start Workout")

                    if workoutStarted {
                        Text("(\(formatElapsedTime(elapsedTime)))")
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .navigationDestination(isPresented: $workoutDone) {
                WorkoutCompleteView(
                    workout: $workout,
                    showView: $workoutDone,
                    isNavigatingBack: $workoutStarted
                ).onDisappear {
                    if workoutStarted {
                        startTimer()
                    }
                }
            }
        }
        .font(.headline)
        .foregroundColor(.white)
        .background(Color.accentColor)
        .cornerRadius(10)
        .onDisappear {
            timer?.invalidate()
        }
        .navigationBarItems(
            trailing: Button(action: workoutBtnAction) {
                HStack {
                    Text(workoutStarted ? "Done" : "Start")
                        .bold()
                }
            }
        )
        .onChange(of: workoutStarted) {
            if workoutStarted {
                workout.startTime = Date()
                startTimer()
            }
        }
    }

    private func workoutBtnAction() {
        if workoutStarted {
            workout.endTime = Date()  // Save end time
            timer?.invalidate()  // stop the timer

            withAnimation {
                workoutDone = true
            }
        } else {
            withAnimation {
                workoutStarted = true
            }
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task {
                await updateElapsedTime()
            }
        }
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

struct WorkoutView: View {
    @State var workout: Workout
    @State var currentExercise: Exercise?
    @State private var workoutStarted: Bool = false

    init(workout: Workout) {
        self.workout = workout
        self.currentExercise = workout.nextExercise()
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                WorkoutListView(
                    workout: $workout,
                    currentExercise: $currentExercise,
                    workoutStarted: $workoutStarted
                )

                Spacer()

                ProgressView(value: workout.getCompletedPercent())
                    .progressViewStyle(
                        LinearProgressViewStyle(tint: Color.accentColor)
                    )
                    .animation(.easeInOut, value: workout.getCompletedPercent())
                    .frame(height: 1)
                    .padding()

                WorkoutControlsView(
                    workout: $workout, workoutStarted: $workoutStarted
                )
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle(workout.name)
        }
    }
}

#Preview {
    let deadliftWorkout = Workout(
        id: 1,
        name: "Deadlift",
        description: "foobar2342",
        workout: [
            WorkoutGroup(
                id: 11,
                name: "Warmup",
                expectedDurationMin: 15,
                exercises: [
                    Exercise(
                        id: 111,
                        name: "Cat-Cow Stretches",
                        sets: [
                            ExerciseSet(
                                id: 1111, setNumber: 1, weight: 0, reps: 10,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 1112, setNumber: 2, weight: 0, reps: 10,
                                isCompleted: false
                            ),
                        ],
                        description: "Foobar"
                    ),
                    Exercise(
                        id: 112,
                        name: "Glute Bridges",
                        sets: [
                            ExerciseSet(
                                id: 1121, setNumber: 1, weight: 0, reps: 10,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 1122, setNumber: 2, weight: 0, reps: 10,
                                isCompleted: false
                            ),
                        ],
                        description: "hold for 10sec"
                    ),
                    Exercise(
                        id: 113,
                        name: "Bird-Dog",
                        sets: [
                            ExerciseSet(
                                id: 1131, setNumber: 1, weight: 0, reps: 10,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 1132, setNumber: 2, weight: 0, reps: 10,
                                isCompleted: false
                            ),
                        ],
                        description: "reps per side"
                    ),
                    Exercise(
                        id: 114,
                        name: "Standing Good Mornings",
                        sets: [
                            ExerciseSet(
                                id: 1141, setNumber: 1, weight: 0, reps: 10,
                                isCompleted: false
                            )
                        ],
                        description: "Bodyweight"
                    ),
                ]
            ),
            WorkoutGroup(
                id: 12,
                name: "Main Lift",
                exercises: [
                    Exercise(
                        id: 121,
                        name: "Deadlift",
                        sets: [
                            ExerciseSet(
                                id: 1211, setNumber: 1, weight: 150, reps: 3,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 1212, setNumber: 2, weight: 160, reps: 3,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 1213, setNumber: 3, weight: 160, reps: 3,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 1214, setNumber: 4, weight: 165, reps: 1,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 1215, setNumber: 5, weight: 165, reps: 1,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 1216, setNumber: 6, weight: 165, reps: 1,
                                isCompleted: false
                            ),
                        ],
                        description: "Slow and steady"
                    )
                ]
            ),
            WorkoutGroup(
                id: 3,
                name: "Accessories",
                exercises: [
                    Exercise(
                        id: 122,
                        name: "Deficit Deadlift",
                        sets: [
                            ExerciseSet(
                                id: 1221, setNumber: 1, weight: 100, reps: 3,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 1222, setNumber: 2, weight: 110, reps: 3,
                                isCompleted: false),
                            ExerciseSet(
                                id: 1223, setNumber: 3, weight: 120, reps: 3,
                                isCompleted: false),
                            ExerciseSet(
                                id: 1224, setNumber: 4, weight: 130, reps: 3,
                                isCompleted: false),
                        ],
                        description: "Slow and steady"
                    ),
                    Exercise(
                        id: 123,
                        name: "Bendover Barbell Row",
                        sets: [
                            ExerciseSet(
                                id: 1231, setNumber: 1, weight: 50, reps: 3,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 1232, setNumber: 2, weight: 60, reps: 3,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 1233, setNumber: 3, weight: 70, reps: 3,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 1234, setNumber: 4, weight: 70, reps: 3,
                                isCompleted: false
                            ),
                        ],
                        description: "Slow and steady"
                    ),
                    Exercise(
                        id: 124,
                        name: "Strict Military Press",
                        sets: [
                            ExerciseSet(
                                id: 1241, setNumber: 1, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 1242, setNumber: 2, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 1243, setNumber: 3, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                        ],
                        description: "Slow and steady"
                    ),
                ]
            ),
        ]
    )

    WorkoutView(workout: deadliftWorkout)
}
