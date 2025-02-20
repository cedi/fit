//
//  TestData.swift
//  fit
//
//  Created by Cedric Kienzler on 26.01.25.
//

import SharedModels

@MainActor
let trainingPlan: [WorkoutWeek] = [
    WorkoutWeek(
        number: 1, name: "RAW Strength",
        workouts: [deadliftWorkout, deadliftWorkout], repeatCount: 1),
    WorkoutWeek(
        number: 2, name: "Hypertrophy",
        workouts: [deadliftWorkout, deadliftWorkout], repeatCount: 1),
]

@MainActor
let deadliftWorkout: Workout = Workout(
    id: 1,
    name: "Deadlift",
    workout: [
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
)
