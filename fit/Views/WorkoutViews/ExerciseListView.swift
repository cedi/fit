//
//  HomeView.swift
//  fit
//
//  Created by Cedric Kienzler on 09.12.24.
//

import SwiftUI

struct ExerciseView: View {
    @Binding var exercise: Exercise
    @State private var expanded: Bool = false
    @State private var exerciseComplete: Bool = false

    var body: some View {
        // Now, let's add the title, top aligned
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 4) {
                HStack(alignment: .center) {
                    ZStack {
                        Image(
                            systemName: exerciseComplete
                                ? "checkmark.seal.fill"
                                : "figure.strengthtraining.traditional"
                        )
                        .foregroundColor(Color.accentColor)
                        .frame(width: 32, height: 32)  // Fixed frame size
                    }
                    .overlay(
                        exerciseComplete
                            ? ConfettiView().allowsHitTesting(false) : nil
                    )
                    .coordinateSpace(name: "confettiArea")  // Define a named coordinate space

                    Text(exercise.name)
                        .strikethrough(exerciseComplete)
                }
                .font(.title3)

                if !expanded {
                    // Sets right aligned
                    Spacer()
                    SetView(
                        sets: $exercise.sets, detailView: $expanded,
                        exerciseComplete: $exerciseComplete)
                }
            }

            // Expandable chevron button row
            if expanded {
                VStack(alignment: .leading, spacing: 4) {
                    SetView(
                        sets: $exercise.sets, detailView: $expanded,
                        exerciseComplete: $exerciseComplete)

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
        .background(Color(UIColor.secondarySystemBackground))
        .frame(maxWidth: .infinity)
    }

    private func toggleDetailView() {
        withAnimation(.interactiveSpring) {
            expanded.toggle()
        }
    }
}

struct ExerciseListView: View {
    @Binding var exercises: [Exercise]

    var body: some View {
        List {
            ForEach($exercises) { $exercise in
                ExerciseView(
                    exercise: $exercise
                )
                .listRowInsets(EdgeInsets())
            }
        }
        .listStyle(.plain)
        .padding(.horizontal, 0)
        .background(Color(UIColor.systemGroupedBackground))
    }
}

struct WorkoutGroupView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var workoutGroups: [WorkoutGroup]
    @State private var currentIndex: Int
    @State private var showBackBtn: Bool = false
    @State private var showNextBtn: Bool = true

    let onHome: () -> Void

    init(
        workoutGroups: Binding<[WorkoutGroup]>, currentIndex: Int,
        onHome: @escaping () -> Void
    ) {
        self._workoutGroups = workoutGroups
        self._currentIndex = State(initialValue: currentIndex)
        self.onHome = onHome
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                VStack {
                    ExerciseListView(
                        exercises: $workoutGroups[currentIndex].exercises)

                    Spacer()

                    ProgressView(value: groupProgress)
                        .progressViewStyle(
                            LinearProgressViewStyle(tint: Color.accentColor)
                        )
                        .padding(.horizontal)
                        .animation(.easeInOut, value: groupProgress)

                    // Done button to jump to the next workout group
                    Button(action: handleForward) {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                .navigationBarTitle(
                    workoutGroups[currentIndex].name, displayMode: .inline
                )
                .navigationBarBackButtonHidden(false)
                .navigationBarItems(
                    leading: !showBackBtn
                        ? nil
                        : Button(action: handleBackward) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color.accentColor)
                            Text("Back")
                        },
                    trailing: !showNextBtn
                        ? nil
                        : Button(action: handleForward) {
                            Text("Next")
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color.accentColor)
                        }
                )
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            handleSwipe(value: value)
                        }
                )

                ProgressView(value: absoluteProgress)
                    .progressViewStyle(
                        LinearProgressViewStyle(tint: Color.accentColor)
                    )
                    //.padding(.horizontal)
                    .animation(.easeInOut, value: absoluteProgress)
                    .frame(height: 1)  // Set the height of the progress bar
                //.padding(.top, 44)  // Push it down to align with the bottom of the nav bar
            }
        }
    }

    private var groupProgress: Double {
        let totalSets = workoutGroups[currentIndex].exercises.flatMap {
            $0.sets
        }.count
        let completedSets = workoutGroups[currentIndex].exercises.flatMap {
            $0.sets
        }.filter { $0.isCompleted }.count

        return totalSets > 0
            ? Double(completedSets + 1) / Double(totalSets + 1) : 0.0
    }

    private var absoluteProgress: Double {
        let totalSets = workoutGroups.flatMap { $0.exercises }.flatMap {
            $0.sets
        }.count
        let completedSets = workoutGroups.flatMap { $0.exercises }.flatMap {
            $0.sets
        }.filter { $0.isCompleted }.count

        return totalSets > 0
            ? Double(completedSets + 1) / Double(totalSets + 1) : 0.0
    }

    private func handleForward() {
        // Swipe from right to left (Go to next section)
        if currentIndex < workoutGroups.count - 1 {
            currentIndex += 1
        } else {
            presentationMode.wrappedValue.dismiss()  // Go back if it's the first section
        }
        updateNavigationBar()
    }

    private func handleBackward() {
        // Swipe from left to right (Go back to previous section)
        if currentIndex > 0 {
            currentIndex -= 1
        } else {
            onHome()  // Navigate to home if it's the last section
        }
        updateNavigationBar()
    }

    private func updateNavigationBar() {
        if currentIndex == 0 {
            showBackBtn = false
            showNextBtn = true
        } else if currentIndex == workoutGroups.count {
            showBackBtn = true
            showNextBtn = false
        } else {
            showNextBtn = true
            showBackBtn = true
        }
    }

    private func handleSwipe(value: DragGesture.Value) {
        let threshold: CGFloat = 50  // Minimum swipe distance to trigger navigation
        if value.translation.width > threshold {
            handleBackward()
        } else if value.translation.width < -threshold {
            handleForward()
        }
    }
}

struct WorkoutView: View {
    @State var workoutGroups: [WorkoutGroup]

    var body: some View {
        WorkoutGroupView(
            workoutGroups: $workoutGroups, currentIndex: 0,
            onHome: {
                print("Navigation back to home")
            })
    }
}

#Preview {
    let workout = [
        WorkoutGroup(
            id: 1,
            name: "Warmup",
            exercises: [
                Exercise(
                    id: 1,
                    name: "Cat-Cow Stretches",
                    sets: [
                        ExerciseSet(
                            id: 1, setNumber: 1, weight: 0, reps: 10,
                            isCompleted: false
                        ),
                        ExerciseSet(
                            id: 2, setNumber: 2, weight: 0, reps: 10,
                            isCompleted: false
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
                            isCompleted: false
                        ),
                        ExerciseSet(
                            id: 2, setNumber: 2, weight: 0, reps: 10,
                            isCompleted: false
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
                            isCompleted: false
                        ),
                        ExerciseSet(
                            id: 2, setNumber: 2, weight: 0, reps: 10,
                            isCompleted: false
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
                            isCompleted: false
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

    WorkoutView(workoutGroups: workout)
}
