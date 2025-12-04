//
//  GlobalDefaults.swift
//  fit
//
//  Created by Cedric Kienzler on 02.03.25.
//

import FirebaseFirestore
import Foundation

struct GlobalDefaults: Codable {
    @DocumentID public var id: String?
    @ServerTimestamp var lastUpdatedAt: Date?

    var ExerciseCategories: [String]?
    var ExerciseEquipment: [String]?
}
