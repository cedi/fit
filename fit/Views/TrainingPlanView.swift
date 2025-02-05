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
    @State var trainingPlan: [WorkoutWeek]
    @State private var isEditing = false

    var body: some View {
        List {
            ForEach(trainingPlan.indices, id: \..self) { index in
                Section(
                    header: WeekHeaderView(
                        trainingPlan: $trainingPlan[index],
                        isEditing: $isEditing
                    )
                ) {
                    ForEach(trainingPlan[index].workouts) { workout in
                        if isEditing {
                            HStack {
                                Text(workout.name)
                                Spacer()
                                Button(action: {
                                    // delete this one from the training plan
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(Color.red)
                                }
                            }
                            .swipeActions(
                                edge: .trailing, allowsFullSwipe: true
                            ) {
                                if isEditing {
                                    Button(role: .destructive) {
                                        deleteWorkout(
                                            from: index, workout: workout)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
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
                    if isEditing {
                        Button(action: {
                            addWorkout(to: index)
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Workout")
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
            }
            //.onDelete(perform: isEditing ? deleteWeek : nil) // error

            if isEditing {
                Button(action: {
                    addWeek()
                }) {
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
        .navigationTitle("Training Plan")
        .navigationBarItems(
            trailing: HStack {
                Button(action: { isEditing.toggle() }) {
                    Text(isEditing ? "Save" : "Edit")
                }
            }
        )
    }

    func addWeek() {
        let newWeek = WorkoutWeek(
            number: trainingPlan.count + 1, workouts: [], repeatCount: 1)
        trainingPlan.append(newWeek)
    }

    func deleteWeek(at offsets: IndexSet) {
        trainingPlan.remove(atOffsets: offsets)
    }

    func addWorkout(to weekIndex: Int) {
        trainingPlan[weekIndex].workouts.append(deadliftWorkout)
    }

    func deleteWorkout(from weekIndex: Int, workout: Workout) {
        if let workoutIndex = trainingPlan[weekIndex].workouts.firstIndex(
            of: workout)
        {
            trainingPlan[weekIndex].workouts.remove(at: workoutIndex)
        }
    }
}

#Preview {
    NavigationView {
        TrainingPlanView(trainingPlan: trainingPlan)
    }
}
