//
//  HomeView.swift
//  fit
//
//  Created by Cedric Kienzler on 09.12.24.
//

import ActivityKit
import Combine
import SwiftUI
import UserNotifications

struct TrainingCalendarView: View {
    let workoutDates: [Date]
    @State private var selectedDate = Date()

    var body: some View {
        VStack(alignment: .leading) {
            Text("Training Calendar")
                .font(.headline)
                .padding(.bottom, 5)

            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemGray6)))
                .padding(.horizontal)

            if workoutDates.contains { Calendar.current.isDate($0, inSameDayAs: selectedDate) } {
                Text("✅ Trained on this day!")
                    .font(.footnote)
                    .foregroundColor(.green)
                    .padding(.top, 5)
            } else {
                Text("🚀 Rest day or no recorded workout.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
            }
        }
    }
}


struct WorkoutStatsView: View {
    let totalWorkouts: Int
    let bestLift: String
    let lastWorkoutDate: String

    var body: some View {
        HStack(spacing: 20) {
            StatCard(title: "Total Workouts", value: "\(totalWorkouts)")
            StatCard(title: "Best Lift", value: bestLift)
            StatCard(title: "Last Workout", value: lastWorkoutDate)
        }
        .padding()
    }
}

struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
            Text(title)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(width: 100, height: 80)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

struct NextWorkoutCard: View {
    let workout: WorkoutTest?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Next Workout")
                .font(.headline)

            if let workout = workout {
                VStack(alignment: .leading) {
                    Text(workout.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text(workout.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("No upcoming workout found")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}

struct WorkoutTest {
    let name: String
    let description: String
}

struct HomeView: View {
       @StateObject var viewModel = HomeViewModel()

    var body: some View {
            ScrollView {
                VStack(spacing: 20) {

                    // Workout Statistics
                    WorkoutStatsView(totalWorkouts: viewModel.totalWorkouts,
                                     bestLift: viewModel.bestLift,
                                     lastWorkoutDate: viewModel.lastWorkoutDate)

                    // Training Calendar
                    TrainingCalendarView(workoutDates: viewModel.workoutDates)

                    // Upcoming Workout
                    NextWorkoutCard(workout: viewModel.nextWorkout)

                    // Start Workout Button
                    Button(action: {
                        viewModel.startWorkout()
                    }) {
                        Text("Start Workout of the Day")
                            .font(.title3)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Home")
    }
}

#Preview {
    HomeView()
}
