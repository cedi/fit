//
//  Exercise.swift
//  fit
//
//  Created by Cedric Kienzler on 05.01.25.
//

import Foundation

struct ExerciseSet: Identifiable, Equatable, Codable, Hashable {
    let id: Int
    let setNumber: Int
    let weight: Int
    let reps: Int
    var isCompleted: Bool = false
    var isSkipped: Bool = false
    var isPr: Bool = false
}

struct Exercise: Identifiable, Equatable, Codable, Hashable {
    let id: Int
    var name: String
    var sets: [ExerciseSet]
    let description: String

    func isComplete() -> Bool {
        sets.allSatisfy { $0.isCompleted || $0.isSkipped }
    }
}

struct WorkoutGroup: Identifiable, Equatable, Codable, Hashable {
    let id: Int
    var name: String
    var expectedDurationMin: Int = 0
    var exercises: [Exercise]

    func isComplete() -> Bool {
        exercises.allSatisfy({ $0.isComplete() })
    }

    func nextExercise() -> Exercise? {
        exercises.first { !$0.isComplete() }
    }
}

struct Workout: Identifiable, Equatable, Codable, Hashable {
    let id: Int
    var name: String
    var description: String = ""
    var startTime: Date?
    var endTime: Date?
    var workout: [WorkoutGroup]

    func isComplete() -> Bool {
        workout.allSatisfy({ $0.isComplete() })
    }

    func nextExercise() -> Exercise? {
        for group in workout {
            if let nextExercise = group.nextExercise() {
                return nextExercise
            }
        }
        return nil
    }

    func getCompletedPercent() -> Double {
        let totalSets = workout.flatMap { $0.exercises }.flatMap {
            $0.sets
        }.count
        let completedSets = workout.flatMap { $0.exercises }.flatMap {
            $0.sets
        }.filter { $0.isCompleted || $0.isSkipped }.count

        return totalSets > 0
            ? Double(completedSets + 1) / Double(totalSets + 1) : 0.0
    }

    func newPRCount() -> Int {
            workout.filter { group in
                group.exercises.contains { exercise in
                    exercise.sets.contains { $0.isPr }
                }
            }
            .count
        }

    // Custom Equatable conformance
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.description == rhs.description &&
            lhs.startTime == rhs.startTime &&
            lhs.endTime == rhs.endTime &&
            lhs.workout == rhs.workout
    }
}
