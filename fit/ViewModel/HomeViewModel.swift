//
//  HomeViewModel.swift
//  fit
//
//  Created by Cedric Kienzler on 21.02.25.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var totalWorkouts: Int = 45
    @Published var bestLift: String = "180kg Deadlift"
    @Published var lastWorkoutDate: String = "Feb 15, 2025"
    @Published var workoutDates: [Date] = [Date().addingTimeInterval(-86400 * 2), Date().addingTimeInterval(-86400 * 4)] // Example past dates
    @Published var nextWorkout: WorkoutTest? = WorkoutTest(name: "Upper Body Strength", description: "Bench Press, Rows, and Shoulder Press")

    func startWorkout() {
        print("Starting workout...")
    }
}
