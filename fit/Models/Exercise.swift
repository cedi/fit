//
//  Exercise.swift
//  fit
//
//  Created by Cedric Kienzler on 05.01.25.
//

struct ExerciseSet: Identifiable, Equatable {
    let id: Int
    let setNumber: Int
    let weight: Int
    let reps: Int
    var isCompleted: Bool
}

struct Exercise: Identifiable, Equatable {
    let id: Int
    var name: String
    var sets: [ExerciseSet]
    let description: String
}

struct WorkoutGroup: Identifiable, Equatable {
    let id: Int
    var name: String
    var exercises: [Exercise]
}
