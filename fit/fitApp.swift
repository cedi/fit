//
//  fitApp.swift
//  fit
//
//  Created by Cedric Kienzler on 09.12.24.
//

import SwiftUI
import SwiftData

@main
struct fitApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        let workout = [
            WorkoutGroup(
                id: 1,
                name: "Warmup",
                exercises: [
                    Exercise(
                        id: 11,
                        name: "Cat-Cow Stretches",
                        sets: [
                            ExerciseSet(
                                id: 111, setNumber: 1, weight: 0, reps: 10,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 112, setNumber: 2, weight: 0, reps: 10,
                                isCompleted: false
                            ),
                        ],
                        description: "Foobar"
                    ),
                    Exercise(
                        id: 12,
                        name: "Glute Bridges",
                        sets: [
                            ExerciseSet(
                                id: 121, setNumber: 1, weight: 0, reps: 10,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 122, setNumber: 2, weight: 0, reps: 10,
                                isCompleted: false
                            ),
                        ],
                        description: "hold for 10sec"
                    ),
                    Exercise(
                        id: 13,
                        name: "Bird-Dog",
                        sets: [
                            ExerciseSet(
                                id: 131, setNumber: 1, weight: 0, reps: 10,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 132, setNumber: 2, weight: 0, reps: 10,
                                isCompleted: false
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
                        id: 21,
                        name: "Deadlift",
                        sets: [
                            ExerciseSet(
                                id: 221, setNumber: 1, weight: 150, reps: 3,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 222, setNumber: 2, weight: 160, reps: 3,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 223, setNumber: 3, weight: 160, reps: 3,
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
                        id: 31,
                        name: "Deficit Deadlift",
                        sets: [
                            ExerciseSet(
                                id: 311, setNumber: 1, weight: 100, reps: 3,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 312, setNumber: 2, weight: 110, reps: 3,
                                isCompleted: false),
                            ExerciseSet(
                                id: 313, setNumber: 3, weight: 120, reps: 3,
                                isCompleted: false),
                            ExerciseSet(
                                id: 314, setNumber: 4, weight: 130, reps: 3,
                                isCompleted: false),
                        ],
                        description: "Slow and steady"
                    ),
                    Exercise(
                        id: 32,
                        name: "Bendover Barbell Row",
                        sets: [
                            ExerciseSet(
                                id: 321, setNumber: 1, weight: 50, reps: 3,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 322, setNumber: 2, weight: 60, reps: 3,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 323, setNumber: 3, weight: 70, reps: 3,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 324, setNumber: 4, weight: 70, reps: 3,
                                isCompleted: false
                            ),
                        ],
                        description: "Slow and steady"
                    ),
                    Exercise(
                        id: 33,
                        name: "Strict Military Press",
                        sets: [
                            ExerciseSet(
                                id: 331, setNumber: 1, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 332, setNumber: 2, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                            ExerciseSet(
                                id: 333, setNumber: 3, weight: 40, reps: 6,
                                isCompleted: false
                            ),
                        ],
                        description: "Slow and steady"
                    ),
                ]
            ),
        ]
        
        WindowGroup {
            ContentView(workoutGroups: workout)
        }
        .modelContainer(sharedModelContainer)
    }
}
