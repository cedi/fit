//
//  WorkoutCompleteView.swift
//  fit
//
//  Created by Cedric Kienzler on 15.01.25.
//

import SwiftUI

struct SetRowView: View {
    let set: ExerciseSet

    var body: some View {
        HStack {
            if set.isCompleted && !set.isPr {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else if set.isPr {
                Image(systemName: "trophy.circle")
                    .foregroundColor(.orange)
            } else {
                Image(systemName: "x.circle.fill")
                    .foregroundColor(.red)
            }

            if set.weight > 0 {
                Text("\(set.setNumber).\t\(set.reps) x \(set.weight) kg")
                    .font(.body)
            } else {
                Text("\(set.setNumber).\t\(set.reps) reps")
                    .font(.body)
            }
        }
    }
}

struct PercivedWorkoutFeedbackView: View {
    @Binding var workoutFeedback: Double

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("How was the workout?")
                    .font(.headline)
                Spacer()
                Text(feedbackText(for: workoutFeedback))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }

            Slider(value: $workoutFeedback)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12).fill(
                Color(UIColor.secondarySystemBackground)))
    }

    private func feedbackText(for value: Double) -> String {
        switch value {
        case 0.0..<0.3: return "Easy 😊"
        case 0.3..<0.7: return "Challenging 💪"
        default: return "Hardcore 🔥"
        }
    }
}

struct RecapStatsView: View {
    @Binding var workout: Workout

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
            SummaryItem(
                iconName: "figure.strengthtraining.traditional",
                value: "\(countExercises())",
                label: "# of Exercises")

            SummaryItem(
                iconName: "timer",
                value: "\(formatElapsedTime(elapsedTime))",
                label: "Training Time"
            )

            SummaryItem(
                iconName: "list.number",
                value: "\(countSets())",
                label: "# of Sets")

            SummaryItem(
                iconName: "scalemass",
                value: "\(totalWeightLifted()) kg",
                label: "Total Weight Lifted")

            if workout.newPRCount() > 0 {
                SummaryItem(
                    iconName: "star.fill",
                    value: "\(workout.newPRCount())",
                    label: "Personal bests")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12).fill(
                Color(UIColor.secondarySystemBackground)))
    }

    private func countExercises() -> Int {
        workout.workout.flatMap { $0.exercises }.count
    }

    private func countSets() -> Int {
        workout.workout.flatMap { $0.exercises }.flatMap { $0.sets }.count
    }

    private func totalWeightLifted() -> Int {
        workout.workout
            .flatMap { $0.exercises }
            .flatMap { $0.sets }
            .filter { $0.isCompleted } // Only include completed sets
            .reduce(0) { $0 + ($1.weight * $1.reps) }
    }

    private var elapsedTime: TimeInterval {
        if let startTime = workout.startTime {
            return workout.endTime?.timeIntervalSince(startTime)
                ?? Date().timeIntervalSince(startTime)
        }
        return 0
    }

    private func formatElapsedTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let minutes = (totalSeconds / 60) % 60
        let hours = totalSeconds / 3600

        return String(format: "%02d:%02d", hours, minutes)
    }
}

struct WorkoutRecapListView: View {
    @Binding var workout: Workout

    var body: some View {
        ForEach(workout.workout) { group in
            VStack(alignment: .leading, spacing: 8) {
                // Group Header
                HStack {
                    Text(group.name)
                        .font(.headline)

                    if group.expectedDurationMin > 0 {
                        Spacer()
                        Text("\(group.expectedDurationMin) min")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                // Exercises List
                ForEach(group.exercises) { exercise in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(exercise.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        ForEach(exercise.sets) { set in
                            SetRowView(set: set)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                Color(
                                    UIColor
                                        .secondarySystemBackground))
                    )
                }
            }
        }
    }
}

struct WorkoutCompleteView: View {
    @Binding var workout: Workout
    @Binding var showView: Bool
    @Binding var isNavigatingBack: Bool

    @State private var workoutFeedback: Double = 0.5
    @State private var savedWorkout: Bool = false

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text(
                        formatWorkoutDuration(
                            start: workout.startTime ?? Date(),
                            end: workout.endTime ?? Date()
                        )
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                    // Stats
                    RecapStatsView(workout: $workout)

                    // Feedback Section
                    PercivedWorkoutFeedbackView(
                        workoutFeedback: $workoutFeedback)

                    // Recap Section
                    WorkoutRecapListView(workout: $workout)
                }
            }

            // Done button to jump to the next workout group
            Button(action: { done(workout: $workout) }) {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
        .navigationTitle("Workout Complete")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing: Button(action: { done(workout: $workout) }) {
                HStack {
                    Text("Done")
                        .bold()
                }
            }
        )
        .onDisappear {
            isNavigatingBack = !savedWorkout
        }
    }

    func formatWorkoutDuration(start: Date, end: Date) -> String {
        let dateFormatter = DateFormatter()

        // Format for the month and day (e.g., "Jan 8")
        dateFormatter.dateFormat = "MMM d"
        let datePart = dateFormatter.string(from: start)

        // Format for the time with AM/PM (e.g., "02:01 PM")
        dateFormatter.dateFormat = "hh:mm a"
        let startTime = dateFormatter.string(from: start)
        let endTime = dateFormatter.string(from: end)

        // Combine into the desired format
        return "\(datePart) • \(startTime) - \(endTime)"
    }

    private func done(workout: Binding<Workout>) {
        var updatedWorkout = workout.wrappedValue

        // Reset all sets to isCompleted = false
        for groupIndex in updatedWorkout.workout.indices {
            for exerciseIndex in updatedWorkout.workout[groupIndex].exercises
                .indices
            {
                for setIndex in updatedWorkout.workout[groupIndex].exercises[
                    exerciseIndex
                ].sets.indices {
                    updatedWorkout.workout[groupIndex].exercises[exerciseIndex]
                        .sets[setIndex].isCompleted = false
                }
            }
        }

        updatedWorkout.startTime = nil

        // Reassign the updated workout to the binding
        workout.wrappedValue = updatedWorkout

        savedWorkout = true
        showView = false
    }
}

struct SummaryItem: View {
    let iconName: String
    let value: String
    let label: String

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.title)
                .foregroundColor(.blue)
            VStack(alignment: .leading) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    let deadliftWorkout = Workout(
        id: 1,
        name: "Deadlift",
        description: "foobar2342",
        startTime: Date(),
        endTime: Date().addingTimeInterval(60 * 60),
        workout: [
            WorkoutGroup(
                id: 1,
                name: "Warmup",
                expectedDurationMin: 15,
                exercises: [
                    Exercise(
                        id: 1,
                        name: "Cat-Cow Stretches",
                        sets: [
                            ExerciseSet(
                                id: 1, setNumber: 1, weight: 0, reps: 10,
                                isCompleted: true
                            ),
                            ExerciseSet(
                                id: 2, setNumber: 2, weight: 0, reps: 10,
                                isCompleted: true
                            ),
                        ],
                        description: "Foobar"
                    ),
                    Exercise(
                        id: 2,
                        name: "Glute Bridges",
                        sets: [
                            ExerciseSet(
                                id: 1, setNumber: 1, weight: 0, reps: 10,
                                isCompleted: true
                            ),
                            ExerciseSet(
                                id: 2, setNumber: 2, weight: 0, reps: 10,
                                isCompleted: true
                            ),
                        ],
                        description: "hold for 10sec"
                    ),
                    Exercise(
                        id: 3,
                        name: "Bird-Dog",
                        sets: [
                            ExerciseSet(
                                id: 1, setNumber: 1, weight: 0, reps: 10,
                                isCompleted: true
                            ),
                            ExerciseSet(
                                id: 2, setNumber: 2, weight: 0, reps: 10,
                                isCompleted: true
                            ),
                        ],
                        description: "reps per side"
                    ),
                    Exercise(
                        id: 4,
                        name: "Standing Good Mornings",
                        sets: [
                            ExerciseSet(
                                id: 1, setNumber: 1, weight: 0, reps: 10,
                                isCompleted: true
                            )
                        ],
                        description: "Bodyweight"
                    ),
                ]
            ),
            WorkoutGroup(
                id: 2,
                name: "Main Lift",
                exercises: [
                    Exercise(
                        id: 1,
                        name: "Deadlift",
                        sets: [
                            ExerciseSet(
                                id: 1, setNumber: 1, weight: 150, reps: 3,
                                isCompleted: true
                            ),
                            ExerciseSet(
                                id: 2, setNumber: 2, weight: 160, reps: 3,
                                isCompleted: true
                            ),
                            ExerciseSet(
                                id: 3, setNumber: 3, weight: 160, reps: 3,
                                isCompleted: true
                            ),
                            ExerciseSet(
                                id: 4, setNumber: 4, weight: 165, reps: 1,
                                isCompleted: true
                            ),
                            ExerciseSet(
                                id: 5, setNumber: 5, weight: 165, reps: 1,
                                isCompleted: true
                            ),
                            ExerciseSet(
                                id: 6, setNumber: 6, weight: 165, reps: 1,
                                isCompleted: true
                            ),
                            ExerciseSet(
                                id: 7, setNumber: 7, weight: 170, reps: 1,
                                isCompleted: true,
                                isPr: true
                            ),
                        ],
                        description: "Slow and steady"
                    ),
                    Exercise(
                        id: 2,
                        name: "Deficit Deadlift",
                        sets: [
                            ExerciseSet(
                                id: 1, setNumber: 1, weight: 100, reps: 3,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 2, setNumber: 2, weight: 110, reps: 3,
                                isCompleted: false),
                            ExerciseSet(
                                id: 3, setNumber: 3, weight: 120, reps: 3,
                                isCompleted: false),
                            ExerciseSet(
                                id: 4, setNumber: 4, weight: 130, reps: 3,
                                isCompleted: false),
                        ],
                        description: "Slow and steady"
                    ),
                    Exercise(
                        id: 3,
                        name: "Bendover Barbell Row",
                        sets: [
                            ExerciseSet(
                                id: 1, setNumber: 1, weight: 50, reps: 3,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 2, setNumber: 2, weight: 60, reps: 3,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 3, setNumber: 3, weight: 70, reps: 3,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 4, setNumber: 4, weight: 70, reps: 3,
                                isCompleted: false
                            ),
                        ],
                        description: "Slow and steady"
                    ),
                    Exercise(
                        id: 4,
                        name: "Strict Military Press",
                        sets: [
                            ExerciseSet(
                                id: 1, setNumber: 1, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 2, setNumber: 2, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 3, setNumber: 3, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                        ],
                        description: "Slow and steady"
                    ),
                    Exercise(
                        id: 5,
                        name: "Strict Military Press",
                        sets: [
                            ExerciseSet(
                                id: 1, setNumber: 1, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 2, setNumber: 2, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 3, setNumber: 3, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                        ],
                        description: "Slow and steady"
                    ),
                    Exercise(
                        id: 6,
                        name: "Strict Military Press",
                        sets: [
                            ExerciseSet(
                                id: 1, setNumber: 1, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 2, setNumber: 2, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 3, setNumber: 3, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                        ],
                        description: "Slow and steady"
                    ),
                    Exercise(
                        id: 7,
                        name: "Strict Military Press",
                        sets: [
                            ExerciseSet(
                                id: 1, setNumber: 1, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 2, setNumber: 2, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 3, setNumber: 3, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                        ],
                        description: "Slow and steady"
                    ),
                    Exercise(
                        id: 8,
                        name: "Strict Military Press",
                        sets: [
                            ExerciseSet(
                                id: 1, setNumber: 1, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 2, setNumber: 2, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 3, setNumber: 3, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                        ],
                        description: "Slow and steady"
                    ),
                    Exercise(
                        id: 9,
                        name: "Strict Military Press",
                        sets: [
                            ExerciseSet(
                                id: 1, setNumber: 1, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 2, setNumber: 2, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 3, setNumber: 3, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                        ],
                        description: "Slow and steady"
                    ),
                    Exercise(
                        id: 10,
                        name: "Strict Military Press",
                        sets: [
                            ExerciseSet(
                                id: 1, setNumber: 1, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 2, setNumber: 2, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 3, setNumber: 3, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                        ],
                        description: "Slow and steady"
                    ),
                    Exercise(
                        id: 11,
                        name: "Strict Military Press",
                        sets: [
                            ExerciseSet(
                                id: 1, setNumber: 1, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 2, setNumber: 2, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 3, setNumber: 3, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                        ],
                        description: "Slow and steady"
                    ),
                ]
            ),
            WorkoutGroup(
                id: 3,
                name: "Accessories",
                exercises: [
                    Exercise(
                        id: 2,
                        name: "Deficit Deadlift",
                        sets: [
                            ExerciseSet(
                                id: 1, setNumber: 1, weight: 100, reps: 3,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 2, setNumber: 2, weight: 110, reps: 3,
                                isCompleted: false),
                            ExerciseSet(
                                id: 3, setNumber: 3, weight: 120, reps: 3,
                                isCompleted: false),
                            ExerciseSet(
                                id: 4, setNumber: 4, weight: 130, reps: 3,
                                isCompleted: false),
                        ],
                        description: "Slow and steady"
                    ),
                    Exercise(
                        id: 3,
                        name: "Bendover Barbell Row",
                        sets: [
                            ExerciseSet(
                                id: 1, setNumber: 1, weight: 50, reps: 3,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 2, setNumber: 2, weight: 60, reps: 3,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 3, setNumber: 3, weight: 70, reps: 3,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 4, setNumber: 4, weight: 70, reps: 3,
                                isCompleted: false
                            ),
                        ],
                        description: "Slow and steady"
                    ),
                    Exercise(
                        id: 4,
                        name: "Strict Military Press",
                        sets: [
                            ExerciseSet(
                                id: 1, setNumber: 1, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 2, setNumber: 2, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 3, setNumber: 3, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                        ],
                        description: "Slow and steady"
                    ),
                ]
            ),
        ]
    )

    WorkoutCompleteView(
        workout: .constant(deadliftWorkout),
        showView: .constant(true),
        isNavigatingBack: .constant(false)
    )
}
