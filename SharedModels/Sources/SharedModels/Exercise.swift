//
//  Exercise.swift
//  fit
//
//  Created by Cedric Kienzler on 20.01.25.
//

import Foundation

public struct ExerciseSet: Identifiable, Equatable, Codable, Hashable {
    public let id: Int
    public let setNumber: Int
    public let weight: Int
    public let reps: Int
    public var isCompleted: Bool = false
    public var isSkipped: Bool = false
    public var isPr: Bool = false

    public init(
        id: Int,
        setNumber: Int,
        weight: Int,
        reps: Int,
        isCompleted: Bool = false,
        isSkipped: Bool = false,
        isPr: Bool = false
    ) {
        self.id = id
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.isCompleted = isCompleted
        self.isSkipped = isSkipped
        self.isPr = isPr
    }
}

public struct Exercise: Identifiable, Equatable, Codable, Hashable {
    public let id: Int
    public var name: String
    public var sets: [ExerciseSet]
    public let description: String

    public init(
        id: Int = 0,
        name: String = "",
        sets: [ExerciseSet] = [],
        description: String = ""
    ) {
        self.id = id
        self.name = name
        self.sets = sets
        self.description = description
    }

    public func isComplete() -> Bool {
        sets.allSatisfy { $0.isCompleted || $0.isSkipped }
    }

    public func nextSet() -> ExerciseSet? {
        sets.first { !$0.isCompleted && !$0.isSkipped }
    }

    public func findFirstIncompleteSet() -> ExerciseSet? {
        sets.first(where: { !$0.isCompleted && !$0.isSkipped })
    }

    public func findLastHandledSet() -> ExerciseSet? {
        sets.last(where: { $0.isCompleted || $0.isSkipped })
    }
}

public struct WorkoutGroup: Identifiable, Equatable, Codable, Hashable {
    public let id: Int
    public var name: String
    public var expectedDurationMin: Int = 0
    public var exercises: [Exercise]

    public init(
        id: Int,
        name: String,
        expectedDurationMin: Int = 0,
        exercises: [Exercise] = []
    ) {
        self.id = id
        self.name = name
        self.expectedDurationMin = expectedDurationMin
        self.exercises = exercises
    }

    public func isComplete() -> Bool {
        exercises.allSatisfy({ $0.isComplete() })
    }

    public func nextExercise() -> Exercise? {
        exercises.first { !$0.isComplete() }
    }
}

public struct Workout: Identifiable, Equatable, Codable, Hashable {
    public let id: Int
    public var name: String
    public var description: String = ""
    public var startTime: Date?
    public var endTime: Date?
    public var workout: [WorkoutGroup]

    public init(
        id: Int,
        name: String,
        description: String = "",
        startTime: Date? = nil,
        endTime: Date? = nil,
        workout: [WorkoutGroup] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
        self.workout = workout
    }

    public func isComplete() -> Bool {
        workout.allSatisfy({ $0.isComplete() })
    }

    public func findExercise(bySetId setID: Int) -> Exercise? {
        for group in workout {
            for exercise in group.exercises {
                if exercise.sets.contains(where: { $0.id == setID }) {
                    return exercise
                }
            }
        }
        return nil
    }

    public func nextExercise() -> Exercise? {
        for group in workout {
            if let nextExercise = group.nextExercise() {
                return nextExercise
            }
        }
        return nil
    }

    public func getCompletedPercent() -> Double {
        let totalSets = workout.flatMap { $0.exercises }.flatMap {
            $0.sets
        }.count
        let completedSets = workout.flatMap { $0.exercises }.flatMap {
            $0.sets
        }.filter { $0.isCompleted || $0.isSkipped }.count

        return totalSets > 0
            ? Double(completedSets + 1) / Double(totalSets + 1) : 0.0
    }

    public func newPRCount() -> Int {
        workout.filter { group in
            group.exercises.contains { exercise in
                exercise.sets.contains { $0.isPr }
            }
        }
        .count
    }

    // Custom Equatable conformance
    public static func == (lhs: Workout, rhs: Workout) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
            && lhs.description == rhs.description
            && lhs.startTime == rhs.startTime && lhs.endTime == rhs.endTime
            && lhs.workout == rhs.workout
    }

    public func getUpcomingExercises() -> [String] {
        workout
            .flatMap { $0.exercises }  // Combine all exercises from groups
            .filter { exercise in
                // Keep exercises where not all sets are completed or skipped
                exercise.isComplete()
            }
            .map { $0.name }  // Extract the exercise names
    }

    public func totalWeightLifted() -> Int {
        workout
            .flatMap { $0.exercises }
            .flatMap { $0.sets }
            .filter { $0.isCompleted }  // Only include completed sets
            .reduce(0) { $0 + ($1.weight * $1.reps) }
    }
}

public struct WorkoutWeek: Identifiable {
    public let id = UUID()
    public var number: Int
    public var name: String
    public var workouts: [Workout]
    public var repeatCount: Int

    public init(
        number: Int,
        name: String = "",
        workouts: [Workout] = [],
        repeatCount: Int = 1
    ) {
        self.number = number
        self.name = name
        self.workouts = workouts
        self.repeatCount = repeatCount
    }
}
