//
//  WorkoutCompleteView.swift
//  fit
//
//  Created by Cedric Kienzler on 15.01.25.
//

import HealthKit
import SharedModels
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
                    .foregroundColor(Color.accentColor)
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
        case 1.0: return "RIP 💀"
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
                value: "\(workout.totalWeightLifted()) kg",
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
        saveToAppleHealth()

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

    func fetchUserBodyWeight() -> Double {
        guard
            let bodyWeightType = HKObjectType.quantityType(
                forIdentifier: .bodyMass)
        else {
            return 0.0
        }

        let semaphore = DispatchSemaphore(value: 0)
        var weightInKg: Double = 0.0  // Initialize with a default value

        let query = HKSampleQuery(
            sampleType: bodyWeightType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [
                NSSortDescriptor(
                    key: HKSampleSortIdentifierStartDate, ascending: false)
            ]
        ) { _, samples, _ in
            if let sample = samples?.first as? HKQuantitySample {
                weightInKg = sample.quantity.doubleValue(
                    for: HKUnit.gramUnit(with: .kilo))
            }
            semaphore.signal()
        }

        HKHealthStore().execute(query)
        semaphore.wait()  // Block the thread until the query completes

        return weightInKg
    }

    private func intensityMET() -> Double {
        switch workoutFeedback {
        case 0.0..<0.3: return 5.75
        case 0.3..<0.7: return 6.0
        case 1.0: return 6.5
        default: return 6.25
        }
    }

    private func workoutDurationInMinutes() -> Double {
        guard let endTime = workout.endTime, let startTime = workout.startTime
        else {
            return 0
        }
        return endTime.timeIntervalSince(startTime) / 60.0  // Convert seconds to minutes
    }

    private func calculateCaloriesBurned(durationInMinutes: Double) -> Double {
        return intensityMET() * fetchUserBodyWeight() * durationInMinutes
    }

    private func saveToAppleHealth() {

        let duration = workoutDurationInMinutes()

        // Calculate calories burned using MET formula
        let caloriesBurned = calculateCaloriesBurned(
            durationInMinutes: duration)

        // Add custom notes as metadata
        let metadata: [String: Any] = [
            "totalWeight": workout.totalWeightLifted(),
            "trainingSummary": workout.name,
        ]

        // Ensure we have valid start and end times
        let startDate = workout.startTime ?? Date()
        let endDate = workout.endTime ?? Date().addingTimeInterval(5 * 60)

        guard endDate > startDate else {
            print("End date must be later than start date.")
            return
        }

        // Create a HealthKit store and workout builder
        let healthStore = HKHealthStore()
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .other

        let builder = HKWorkoutBuilder(
            healthStore: healthStore, configuration: workoutConfiguration,
            device: .local())

        // Manually add the burned calories
        let burnedCaloriesQuantity = HKQuantity(
            unit: .kilocalorie(), doubleValue: caloriesBurned)

        let activeEnergyBurnedType = HKQuantityType.quantityType(
            forIdentifier: .activeEnergyBurned
        )!

        let sample = HKQuantitySample(
            type: activeEnergyBurnedType,
            quantity: burnedCaloriesQuantity,
            start: startDate,
            end: endDate//,
            //metadata: metadata
        )

        builder.beginCollection(withStart: startDate) { (success, error) in
          guard success else {
            return
          }
        }

        // Start the workout collection
//        builder.beginCollection(withStart: startDate) { success, error in
//            guard success else {
//                print(
//                    "Error starting workout collection: \(error?.localizedDescription ?? "Unknown error")"
//                )
//                return
//            }


//            builder.add([sample]) { success, error in
//                guard success else {
//                    print(
//                        "Error adding energy burned sample: \(error?.localizedDescription ?? "Unknown error")"
//                    )
//                    return
//                }
//
//                // End the collection
//                builder.endCollection(withEnd: endDate) { success, error in
//                    guard success else {
//                        print(
//                            "Error ending workout collection: \(error?.localizedDescription ?? "Unknown error")"
//                        )
//                        return
//                    }
//
//                    // Save the workout
//                    builder.finishWorkout { workout, error in
//                        if let error = error {
//                            print(
//                                "Error saving workout: \(error.localizedDescription)"
//                            )
//                        } else {
//                            print("Workout saved successfully with metadata!")
//                        }
//                    }
//                }
//            }
//        }
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
                .foregroundColor(Color.accentColor)
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
