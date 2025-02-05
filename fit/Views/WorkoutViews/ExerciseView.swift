//
//  HomeView.swift
//  fit
//
//  Created by Cedric Kienzler on 09.12.24.
//

import SwiftUI
import SharedModels

struct WorkoutExerciseView: View {
    @State private var expanded: Bool = false

    @Binding var exercise: Exercise
    @Binding var workoutStarted: Bool
    var isCurrentExercise: Bool
    let completeSet: (Binding<ExerciseSet>, Bool) -> Void

    var body: some View {
        // Now, let's add the title, top aligned
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 4) {
                HStack(alignment: .center) {
                    ZStack {
                        Image(
                            systemName: exercise.isComplete()
                                ? "checkmark.seal.fill"
                                : !workoutStarted
                                    ? "figure.strengthtraining.traditional"
                                    : isCurrentExercise
                                        ? "play.circle" : "pause.circle"
                        )
                        .foregroundColor(Color.accentColor)
                        .frame(width: 32, height: 32)  // Fixed frame size
                    }
                    .overlay(
                        exercise.isComplete()
                            ? ConfettiView().allowsHitTesting(false) : nil
                    )
                    .coordinateSpace(name: "confettiArea")  // Define a named coordinate space

                    Text(exercise.name)
                }
                .font(.headline)

                if !expanded {
                    // Sets right aligned
                    Spacer()
                    SetView(
                        sets: $exercise.sets,
                        detailView: $expanded,
                        completeSet: completeSet
                    )
                }
            }

            // Expandable chevron button row
            if expanded {
                VStack(alignment: .leading, spacing: 4) {
                    SetView(
                        sets: $exercise.sets,
                        detailView: $expanded,
                        completeSet: completeSet
                    )

                    if !exercise.description.isEmpty {
                        Spacer()

                        HStack(spacing: 4) {
                            Text("Description:").font(.headline)
                            Text(exercise.description).font(.callout).italic()
                        }
                        .padding(.horizontal, 4)  // Padding only on left and right
                    }
                }

                HStack {
                    Spacer()

                    Button(action: toggleDetailView) {
                        Image(systemName: "chevron.up")
                            .padding(2)  // Reduced padding for the button
                            .opacity(0.5)
                    }
                    Spacer()
                }
            } else {
                HStack {
                    Spacer()

                    Button(action: toggleDetailView) {
                        Image(systemName: "chevron.down")
                            .padding(2)  // Reduced padding for the button
                            .opacity(0.5)
                    }
                    Spacer()
                }

            }
        }
        .padding(.horizontal, 8)  // Padding only on left and right
        .padding(.vertical, 8)  // Slight padding at the top
        .frame(maxWidth: .infinity)
        .overlay(
            // Add the marker if workout is started and isCurrentExercise is true
            isCurrentExercise && workoutStarted
                ? Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: 4)  // Width of the marker
                    .cornerRadius(4)
                : nil,
            alignment: .leading  // Align marker to the left
        )
    }

    private func toggleDetailView() {
        withAnimation(.interactiveSpring) {
            expanded.toggle()
        }
    }
}

#Preview {
    let exercise = Exercise(
        id: 1,
        name: "Deadlift",
        sets: [
            ExerciseSet(
                id: 1, setNumber: 1, weight: 150, reps: 3,
                isCompleted: false
            ),
            ExerciseSet(
                id: 2, setNumber: 2, weight: 160, reps: 3,
                isCompleted: false
            ),
            ExerciseSet(
                id: 3, setNumber: 3, weight: 160, reps: 3,
                isCompleted: false
            ),
            ExerciseSet(
                id: 4, setNumber: 4, weight: 165, reps: 1,
                isCompleted: false
            ),
            ExerciseSet(
                id: 5, setNumber: 5, weight: 165, reps: 1,
                isCompleted: false
            ),
            ExerciseSet(
                id: 6, setNumber: 6, weight: 165, reps: 1,
                isCompleted: false
            ),
        ],
        description: "Slow and steady"
    )

    WorkoutExerciseView(
        exercise: .constant(exercise),
        workoutStarted: .constant(true),
        isCurrentExercise: true,
        completeSet: {_,_ in}
    )
    .frame(height: 100)
}
