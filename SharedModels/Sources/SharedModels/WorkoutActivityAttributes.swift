//
//  WorkoutActivityAttributes.swift
//  SharedModels
//
//  Created by Cedric Kienzler on 20.01.25.
//

import ActivityKit
import SwiftUI
import WidgetKit
import AppIntents
import Foundation

@available(iOS 16.2, *)
public struct CompleteSetIntent: AppIntent {
    public static let title: LocalizedStringResource = "Complete Set"

    public init() {}

    @Parameter(title: "SetID")
    public var setId: Int

    public func perform() async throws -> some IntentResult {
        // Perform the action here
        print("Set completed")

        //await WorkoutState.shared.completeSet(setId: setId)

        return .result()
    }
}

public struct WorkoutActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var exercise: Exercise
        public var setId: Int

        public init(
            exercise: Exercise,
            setId: Int
        ) {
            self.exercise = exercise
            self.setId = setId
        }
    }

    public var name: String

    public init(name: String) {
        self.name = name
    }
}
