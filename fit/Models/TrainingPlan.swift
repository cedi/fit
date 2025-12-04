//
//  TrainingPlan.swift
//  fit
//
//  Created by Cedric Kienzler on 01.03.25.
//

import FirebaseFirestore
import Foundation

public struct TrainingSet: Codable, Identifiable, Equatable {
    public var id: String
    public var reps: Int
    public var weight: Double
    public var isCompleted: Bool?
    public var isSkipped: Bool?
    public var isPr: Bool?

}

public struct TrainingExercise: Codable, Identifiable, Equatable {
    public var id: String
    public var exerciseId: DocumentReference?
    public var sets: [TrainingSet]
}

public struct CompletedTraining: Codable, Equatable {
    @DocumentID public var id: String?

    var name: String
    var exercises: [TrainingExercise]

    var startTime: Date?
    var endTime: Date?
}

public struct Training: Codable, Identifiable, Equatable {
    public var id: String
    public var name: String
    public var exercises: [TrainingExercise]
}

public struct TrainingPlanWeek: Codable, Identifiable {
    public var id: String
    public var name: String
    public var repeatCount: Int
    public var trainings: [Training]
}

struct TrainingPlan: Identifiable, Codable {
    @DocumentID public var id: String?
    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var lastUpdatedAt: Date?

    var name: String?
    var description: String?
    var systemIconName: String?
    var weeks: [TrainingPlanWeek]?
}
