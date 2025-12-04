//
//  Exercise.swift
//  fit
//
//  Created by Cedric Kienzler on 23.02.25.
//

import FirebaseFirestore
import Foundation

public struct FirestoreExercise: Identifiable, Equatable, Codable, Hashable {
    @DocumentID public var id: String?
    var name: String?
    var description: String?
    var category: [String]?  // Strength, Mobility, Conditioning, etc.
    var equipment: [String]?  // "Barbell", "Dumbbells", "Machine"
    var systemIconName: String?  // Link to exercise icon in FireStore
    var alternatives: [DocumentReference]?  // List of alternative exercise IDs

    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var lastUpdatedAt: Date?

    public init(
        id: String? = nil,
        name: String? = nil,
        description: String? = nil,
        category: [String]? = nil,
        equipment: [String]? = nil,
        alternatives: [DocumentReference]? = nil,
        systemIconName: String? = nil,
        createdAt: Date? = nil,
        lastUpdatedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.equipment = equipment
        self.alternatives = alternatives
        self.systemIconName = systemIconName
        self.createdAt = createdAt
        self.lastUpdatedAt = lastUpdatedAt
    }
}
