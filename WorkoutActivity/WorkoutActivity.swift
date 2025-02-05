//
//  Workout.swift
//  Workout
//
//  Created by Cedric Kienzler on 20.01.25.
//

import SwiftUI
import WidgetKit
import SharedModels

struct WorkoutActivity: Widget {
    let kind: String = "WorkoutActivity"

    var body: some WidgetConfiguration {
        // MARK: Live Activity (Lock Screen)
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            VStack(alignment: .leading, spacing: 8) {
                Text("Now")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text(context.state.exercise.name)
                    .font(.title2)
                    .fontWeight(.bold)

                HStack(spacing: 4) {
                    let reps = context.state.exercise.sets.first(where: {$0.id == context.state.setId})?.reps ?? 0
                    let weight = context.state.exercise.sets.first(where: {$0.id == context.state.setId})?.weight ?? 0

                    Text("\(reps)")

                    if weight > 0 {
                        Text("x")
                        Text("\(weight) kg")
                    } else {
                        Text("reps")
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)

                Button(intent: CompleteSetIntent()) {
                    Text("Complete Set")
                        .font(.subheadline)
                        .bold()
                        .padding(8)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .activityBackgroundTint(Color(UIColor.systemGroupedBackground))
            .activitySystemActionForegroundColor(Color.accentColor)
            .alignmentGuide(.top) { _ in 0 }  // Align this VStack to the top

        } dynamicIsland: { context in
            // MARK: Expanded Dynamic Island
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack {
                        Spacer()
                        Text(context.state.exercise.name)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Spacer()
                    }
                }

                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .center, spacing: 4) {
                        HStack(spacing: 4) {
                            let reps = context.state.exercise.sets.first(where: {$0.id == context.state.setId})?.reps ?? 0
                            let weight = context.state.exercise.sets.first(where: {$0.id == context.state.setId})?.weight ?? 0

                            Text("\(reps)")

                            if weight > 0 {
                                Text("x")
                                Text("\(weight) kg")
                            } else {
                                Text("reps")
                            }
                        }
                        .font(.title)
                        .fontWeight(.bold)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Button(intent: CompleteSetIntent()) {
                        Image(systemName: "checkmark")
                            .frame(width: 30, height: 40)
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .padding(.trailing, 2)  // Add spacing from the edge
                }

                DynamicIslandExpandedRegion(.bottom) {
                    EmptyView()
                }

            } compactLeading: {
                Text("\(context.state.exercise.name)")
                    .foregroundColor(.secondary)
            } compactTrailing: {
                HStack(spacing: 4) {
                    let reps = context.state.exercise.sets.first(where: {$0.id == context.state.setId})?.reps ?? 0
                    let weight = context.state.exercise.sets.first(where: {$0.id == context.state.setId})?.weight ?? 0

                    Text("\(reps)")

                    if weight > 0 {
                        Text("x")
                        Text("\(weight) kg")
                    } else {
                        Text("reps")
                    }
                }
                .foregroundColor(Color.accentColor)
            } minimal: {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundColor(Color.accentColor)
            }
            .widgetURL(URL(string: "myapp://workout"))
            .keylineTint(Color.accentColor)
        }
    }

    private func completeWorkout() {

    }
}

extension WorkoutActivityAttributes {
    fileprivate static var preview: WorkoutActivityAttributes {
        WorkoutActivityAttributes(name: "Workout")
    }
}

#Preview("Notification", as: .content, using: WorkoutActivityAttributes.preview)
{
    WorkoutActivity()
} contentStates: {
    WorkoutActivityAttributes.ContentState(
        exercise: Exercise(
            id: 114,
            name: "Deadlift",
            sets: [
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 120, reps: 10,
                    isCompleted: false
                ),
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 130, reps: 10,
                    isCompleted: false
                ),
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 135, reps: 10,
                    isCompleted: false
                )
            ],
            description: "Bodyweight"
        ),
        setId: 1141
    )
    WorkoutActivityAttributes.ContentState(
        exercise: Exercise(
            id: 114,
            name: "Cat Cow Stretches",
            sets: [
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 0, reps: 10,
                    isCompleted: false
                ),
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 0, reps: 10,
                    isCompleted: false
                ),
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 0, reps: 10,
                    isCompleted: false
                )
            ],
            description: "Bodyweight"
        ),
        setId: 1141
    )
}

#Preview(
    "Dynamic Island Expanded", as: .dynamicIsland(.expanded),
    using: WorkoutActivityAttributes.preview
) {
    WorkoutActivity()
} contentStates: {
    WorkoutActivityAttributes.ContentState(
        exercise: Exercise(
            id: 114,
            name: "Deadlift",
            sets: [
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 120, reps: 10,
                    isCompleted: false
                ),
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 130, reps: 10,
                    isCompleted: false
                ),
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 135, reps: 10,
                    isCompleted: false
                )
            ],
            description: "Bodyweight"
        ),
        setId: 1141
    )
    WorkoutActivityAttributes.ContentState(
        exercise: Exercise(
            id: 114,
            name: "Cat Cow Stretches",
            sets: [
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 0, reps: 10,
                    isCompleted: false
                ),
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 0, reps: 10,
                    isCompleted: false
                ),
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 0, reps: 10,
                    isCompleted: false
                )
            ],
            description: "Bodyweight"
        ),
        setId: 1141
    )
}

#Preview(
    "Dynamic Island Compact", as: .dynamicIsland(.compact),
    using: WorkoutActivityAttributes.preview
) {
    WorkoutActivity()
} contentStates: {
    WorkoutActivityAttributes.ContentState(
        exercise: Exercise(
            id: 114,
            name: "Deadlift",
            sets: [
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 120, reps: 10,
                    isCompleted: false
                ),
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 130, reps: 10,
                    isCompleted: false
                ),
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 135, reps: 10,
                    isCompleted: false
                )
            ],
            description: "Bodyweight"
        ),
        setId: 1141
    )
    WorkoutActivityAttributes.ContentState(
        exercise: Exercise(
            id: 114,
            name: "Cat Cow Stretches",
            sets: [
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 0, reps: 10,
                    isCompleted: false
                ),
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 0, reps: 10,
                    isCompleted: false
                ),
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 0, reps: 10,
                    isCompleted: false
                )
            ],
            description: "Bodyweight"
        ),
        setId: 1141
    )
}

#Preview(
    "Dynamic Island Minimal", as: .dynamicIsland(.minimal),
    using: WorkoutActivityAttributes.preview
) {
    WorkoutActivity()
} contentStates: {
    WorkoutActivityAttributes.ContentState(
        exercise: Exercise(
            id: 114,
            name: "Deadlift",
            sets: [
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 120, reps: 10,
                    isCompleted: false
                ),
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 130, reps: 10,
                    isCompleted: false
                ),
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 135, reps: 10,
                    isCompleted: false
                )
            ],
            description: "Bodyweight"
        ),
        setId: 1141
    )
    WorkoutActivityAttributes.ContentState(
        exercise: Exercise(
            id: 114,
            name: "Cat Cow Stretches",
            sets: [
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 0, reps: 10,
                    isCompleted: false
                ),
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 0, reps: 10,
                    isCompleted: false
                ),
                ExerciseSet(
                    id: 1141, setNumber: 1, weight: 0, reps: 10,
                    isCompleted: false
                )
            ],
            description: "Bodyweight"
        ),
        setId: 1141
    )
}
