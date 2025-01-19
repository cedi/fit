//
//  ContentView.swift
//  fit
//
//  Created by Cedric Kienzler on 09.12.24.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var workout: Workout

    enum Tab {
        case home, session, plan, profile
    }

    var body: some View {
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(Tab.home)
                    .navigationBarTitle("Home", displayMode: .inline)
                WorkoutView(workout: workout)
                    .tabItem {
                        Image(systemName: "figure.strengthtraining.traditional")
                        Text("Workout")
                    }
                    .tag(Tab.session)
                    .navigationBarTitle(workout.name, displayMode: .inline)
                Text("TrainingPlan")
                    .tabItem {
                        Image(systemName: "list.triangle")
                        Text("Trainings Plan")
                    }
                    .tag(Tab.plan)
                    .navigationBarTitle("Trainings Plan", displayMode: .inline)
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Profile")
                    }
                    .tag(Tab.profile)
                    .navigationBarTitle("Profile", displayMode: .inline)
            }
    }
}

#Preview {
    let deadliftWorkout = Workout(
        id: 1,
        name: "Deadlift",
        workout: [
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
                                isCompleted: true
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
                                isCompleted: true
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

    ContentView(workout: deadliftWorkout)
}
