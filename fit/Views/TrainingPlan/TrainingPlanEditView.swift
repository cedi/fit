//
//  TrainingPlanEditView.swift
//  fit
//
//  Created by Cedric Kienzler on 11.03.25.
//

import FirebaseFirestore
import SwiftUI

struct TrainingPlanView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: TrainingPlanEditorViewModel

    init(
        trainingPlan: TrainingPlan = TrainingPlan(),
        viewModel: TrainingPlanEditorViewModel = TrainingPlanEditorViewModel()
    ) {
        viewModel.trainingPlan = trainingPlan
        _viewModel = .init(wrappedValue: viewModel)
    }

    @ViewBuilder
    var topRow: some View {
        // Top row (Name)
        HStack(alignment: .center, spacing: 10) {
            if viewModel.isEditing {
                IconPickerControl(
                    Binding(
                        get: {
                            viewModel.trainingPlan.systemIconName
                                ?? "figure.strengthtraining.traditional"
                        },
                        set: {
                            viewModel.trainingPlan.systemIconName = $0
                        }
                    ),
                    size: 40
                )
            } else {
                Image(
                    systemName: viewModel.trainingPlan.systemIconName
                        ?? "figure.strengthtraining.traditional"
                )
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(Color.accentColor)
            }

            if viewModel.isEditing {
                TextField(
                    "Plan Name",
                    text: Binding(
                        get: { viewModel.trainingPlan.name ?? "" },  // If nil, provide empty array
                        set: { viewModel.trainingPlan.name = $0 }  // Update the value
                    )
                )
                .font(.title)
                .keyboardType(.default)
                .foregroundColor(.primary)
                .padding(.vertical, 12)
                .padding(.horizontal, 10)
                .cornerRadius(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray5).opacity(0.3))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            Color.accentColor,
                            lineWidth: viewModel.trainingPlan.name?
                                .isEmpty
                                ?? true
                                ? 0 : 1
                        )
                )
            } else {
                Text(viewModel.trainingPlan.name ?? "")
                    .font(.title)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 10)
                    .cornerRadius(10)

                Spacer()
            }
        }

    }

    @ViewBuilder
    var details: some View {
        // Details
        VStack(alignment: .leading, spacing: 5) {
            SectionView(title: "Description") {
                if viewModel.isEditing {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray5).opacity(0.3))
                            .frame(height: 87)

                        TextEditor(
                            text: Binding(
                                get: {
                                    viewModel.trainingPlan.description ?? ""
                                },
                                set: { viewModel.trainingPlan.description = $0 }
                            )
                        )
                        .frame(height: 75)
                        .autocapitalization(.sentences)
                        .multilineTextAlignment(.leading)
                        .keyboardType(.default)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.vertical, 3)
                        .padding(.horizontal, 5)
                        .scrollContentBackground(.hidden)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                Color.accentColor,
                                lineWidth: viewModel.trainingPlan
                                    .description?.isEmpty ?? true ? 0 : 1
                            )
                    )
                } else {
                    ScrollView {
                        Text(viewModel.trainingPlan.description ?? "")
                            .font(.body)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 10)
                            .cornerRadius(10)
                    }
                    .frame(height: 75)  // Ensure same height
                }
            }
        }
    }

    @ViewBuilder
    var workouts: some View {
        List {
            if let weeks = viewModel.trainingPlan.weeks {
                ForEach(weeks.indices, id: \.self) { index in
                    Section(
                        header: Text(weeks[index].name)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .fontWeight(.medium)
                            .padding(.vertical, 8)
                    ) {
                        ForEach(weeks[index].trainings) { training in
                            HStack {
                                if viewModel.isEditing {
                                    Button(action: {
                                        // delete this one from the training plan
                                    }) {
                                        Image(
                                            systemName: "minus.circle.fill"
                                        )
                                        .foregroundColor(Color.red)
                                    }
                                }

                                // TODO: Refactor away the example deadliftWorkout
                                if viewModel.isEditing {
                                    Text(training.name)
                                } else {
                                    NavigationLink(
                                        destination: WorkoutView(
                                            trainingPlanId: viewModel.trainingPlan.id ?? "",
                                            workoutId: training.id
                                        )
                                    ) {
                                        Text(training.name)
                                    }
                                }
                            }
                            .swipeActions(
                                edge: .trailing, allowsFullSwipe: true
                            ) {
                                if !viewModel.isEditing {
                                    Button(
                                        role: .destructive,
                                        action: {
                                            // delete this one from the training plan
                                        }
                                    ) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .onMove {
                            indices,
                            newOffset in
                            viewModel
                                .moveWorkoutInWeek(
                                    in: index,
                                    from: indices,
                                    to: newOffset
                                )
                        }

                        if viewModel.isEditing {
                            Button(action: {}) {
                                HStack(alignment: .center) {
                                    Image(systemName: "plus")
                                    Text("Add Training")
                                }
                            }
                        }
                    }
                }

                if viewModel.isEditing {
                    Section(
                        header: Text("Add Week")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .fontWeight(.medium)
                            .padding(.vertical, 8)
                    ) {
                        Button(action: viewModel.addNewWeek) {
                            HStack(alignment: .center) {
                                Image(systemName: "plus")
                                Text("Add Week")
                            }
                        }
                    }
                }
                //                    .onDelete(perform: isEditing ? deleteWeek : nil) // error
                //                    if viewModel.isEditing {
                //                        Button(action: {
                ////                            addWeek()
                //                        }) {
                //                            HStack {
                //                                Image(systemName: "plus")
                //                                Text("Add Week")
                //                            }
                //                            .frame(maxWidth: .infinity, alignment: .center)
                //                            .foregroundColor(.blue)
                //                        }
                //                    }
            }
        }
        .listStyle(GroupedListStyle())
        .environment(
            \.editMode, .constant(viewModel.isEditing ? .active : .inactive))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 10) {
                topRow
                details
            }
            .padding(.horizontal)
            .padding(.bottom, 10)

            workouts

            if let errorMessage = viewModel.errorMessage {
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.trainingPlan.name ?? "New Plan")
        .navigationBarBackButtonHidden(viewModel.isEditing)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if viewModel.isEditing {
                    Button("Cancel") {
                        viewModel.isEditing.toggle()
                    }
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(viewModel.isEditing ? "Save" : "Edit") {
                    Task {
                        if viewModel.isEditing {
                            if await viewModel.save() {
                                viewModel.isEditing.toggle()
                            }
                        } else {
                            viewModel.isEditing.toggle()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        TrainingPlanView(
            trainingPlan: TrainingPlan(
                id: "XP8rjv6fSYkxNGYyhyAX",
                name: "Power Lifting",
                description:
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                systemIconName: "figure.strengthtraining.traditional",
                weeks: [
                    TrainingPlanWeek(
                        id: UUID().uuidString,
                        name: "Week 1",
                        repeatCount: 0,
                        trainings: [
                            Training(
                                id: UUID().uuidString,
                                name: "Deadlift Workout",
                                exercises: [
                                    TrainingExercise(
                                        id: UUID().uuidString,
                                        exerciseId: nil,
                                        sets: [
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 6,
                                                weight: 60
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 4,
                                                weight: 75
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 2,
                                                weight: 80
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 1,
                                                weight: 90
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 1,
                                                weight: 100
                                            ),
                                        ]
                                    )
                                ]
                            ),
                            Training(
                                id: UUID().uuidString,
                                name: "Squat Workout",
                                exercises: [
                                    TrainingExercise(
                                        id: UUID().uuidString,
                                        exerciseId: nil,
                                        sets: [
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 6,
                                                weight: 60
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 4,
                                                weight: 75
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 2,
                                                weight: 80
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 1,
                                                weight: 90
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 1,
                                                weight: 100
                                            ),
                                        ]
                                    )
                                ]
                            ),
                            Training(
                                id: UUID().uuidString,
                                name: "Bench Workout",
                                exercises: [
                                    TrainingExercise(
                                        id: UUID().uuidString,
                                        exerciseId: nil,
                                        sets: [
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 6,
                                                weight: 60
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 4,
                                                weight: 75
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 2,
                                                weight: 80
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 1,
                                                weight: 90
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 1,
                                                weight: 100
                                            ),
                                        ]
                                    )
                                ]
                            ),
                        ]
                    ),
                    TrainingPlanWeek(
                        id: UUID().uuidString,
                        name: "Week 2",
                        repeatCount: 0,
                        trainings: [
                            Training(
                                id: UUID().uuidString,
                                name: "Deadlift Workout",
                                exercises: [
                                    TrainingExercise(
                                        id: UUID().uuidString,
                                        exerciseId: nil,
                                        sets: [
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 6,
                                                weight: 60
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 4,
                                                weight: 75
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 2,
                                                weight: 80
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 1,
                                                weight: 90
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 1,
                                                weight: 100
                                            ),
                                        ]
                                    )
                                ]
                            ),
                            Training(
                                id: UUID().uuidString,
                                name: "Squat Workout",
                                exercises: [
                                    TrainingExercise(
                                        id: UUID().uuidString,
                                        exerciseId: nil,
                                        sets: [
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 6,
                                                weight: 60
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 4,
                                                weight: 75
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 2,
                                                weight: 80
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 1,
                                                weight: 90
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 1,
                                                weight: 100
                                            ),
                                        ]
                                    )
                                ]
                            ),
                            Training(
                                id: UUID().uuidString,
                                name: "Bench Workout",
                                exercises: [
                                    TrainingExercise(
                                        id: UUID().uuidString,
                                        exerciseId: nil,
                                        sets: [
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 6,
                                                weight: 60
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 4,
                                                weight: 75
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 2,
                                                weight: 80
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 1,
                                                weight: 90
                                            ),
                                            TrainingSet(
                                                id: UUID().uuidString, reps: 1,
                                                weight: 100
                                            ),
                                        ]
                                    )
                                ]
                            ),
                        ]
                    ),
                ]
            )
        )
    }
}
