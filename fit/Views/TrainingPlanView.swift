import SharedModels
import SwiftUI

struct WeekHeaderView: View {
    @Binding var trainingPlan: WorkoutWeek
    @Binding var isEditing: Bool

    @State private var isShowingEditPopup = false
    @State private var newTitle = ""

    var body: some View {
        HStack {
            Button(action: {
                if isEditing {
                    isShowingEditPopup = true
                }
            }) {
                if isEditing {
                    Image(systemName: "pencil")
                }

                Text("Week \(trainingPlan.number)")

                if trainingPlan.repeatCount > 1 {
                    Text(
                        "- \(trainingPlan.number + trainingPlan.repeatCount - 1)"
                    )
                }

                if !trainingPlan.name.isEmpty {
                    Text(trainingPlan.name)
                }
            }
            .buttonStyle(.plain)
            .alert(
                "Edit Week \(trainingPlan.number) Title",
                isPresented: $isShowingEditPopup
            ) {
                TextField("Enter title", text: $newTitle)
                Button(
                    "Save",
                    action: {
                        trainingPlan.name = newTitle
                        isShowingEditPopup = false
                    }
                )
                Button(
                    "Cancel",
                    action: {
                        isShowingEditPopup = false
                    }
                )
            } message: {
                Text("Enter a name for your workout week.")
            }

            Spacer()
            if isEditing {
                Button(action: {
                    trainingPlan.repeatCount += 1
                }) {
                    Image(systemName: "plus.circle")
                }

                Image(systemName: "repeat")
                Text("\(trainingPlan.repeatCount)")

                if trainingPlan.repeatCount == 1 {
                    Button(action: {
                        // delete this week from the training plan
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(Color.red)
                    }
                } else {
                    Button(action: {
                        if trainingPlan.repeatCount > 1 {
                            trainingPlan.repeatCount -= 1
                        }
                    }) {
                        Image(systemName: "minus.circle")
                    }
                }
            }
        }
    }
}

struct TrainingPlanView: View {
    @StateObject private var viewModel = TrainingPlanViewModel()

    var body: some View {
        List {
            ForEach(viewModel.trainingPlan.indices, id: \.self) { weekIndex in
                Section(
                    header: WeekHeaderView(
                        trainingPlan: $viewModel.trainingPlan[weekIndex],
                        isEditing: $viewModel.isEditing
                    )
                ) {
                    ForEach(viewModel.trainingPlan[weekIndex].workouts) {
                        workout in
                        if viewModel.isEditing {
                            HStack {
                                Text(workout.name)
                                Spacer()
                                Button(action: {
                                    viewModel.deleteWorkout(
                                        from: weekIndex, workout: workout)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        } else {
                            NavigationLink(
                                destination: WorkoutView(workout: workout)
                            ) {
                                Text(workout.name)
                            }
                        }
                    }
                    .onMove { indices, destination in
                        viewModel.moveWorkout(
                            from: indices, to: destination, weekIndex: weekIndex
                        )
                    }

                    if viewModel.isEditing {
                        Button(action: { viewModel.addWorkout(to: weekIndex) })
                        {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Workout")
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
            }

            if viewModel.isEditing {
                Button(action: viewModel.addWeek) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Week")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.blue)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .environment(\.editMode, $viewModel.editMode)
        .navigationTitle("Training Plan")
        .navigationBarItems(trailing: editButton)
    }

    // MARK: - Unified Edit Button
    private var editButton: some View {
        Button(action: {
            viewModel.isEditing.toggle()
            viewModel.editMode = viewModel.isEditing ? .active : .inactive
        }) {
            Text(viewModel.isEditing ? "Done" : "Edit")
        }
    }
}

#Preview {
    NavigationView {
        TrainingPlanView()
    }
}
