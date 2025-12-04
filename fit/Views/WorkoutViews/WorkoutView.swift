//
//  ExerciseView.swift
//  fit
//
//  Created by Cedric Kienzler on 15.01.25.
//

import ActivityKit
import SharedModels
import SwiftUI
import WidgetKit

struct WorkoutView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: WorkoutViewModel

    init(trainingPlanId: String, workoutId: String) {
        _viewModel = .init(
            wrappedValue: WorkoutViewModel(
                trainingPlanId: trainingPlanId,
                workoutId: workoutId
            )
        )
    }

    @ViewBuilder
    var listView: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(viewModel.workout?.exercises ?? []) { exercise in
                    Text("\(exercise.id)")
                        //                    WorkoutExerciseView(
                        //                        exercise: $exercise,
                        //                        workoutStarted: $workoutStarted,
                        //                        isCurrentExercise: currentExercise?.id
                        //                            == exercise.id,
                        //                        completeSet: completeSet
                        //                    )
                        .listRowInsets(EdgeInsets())
                        .id(exercise.id)
                        .swipeActions(
                            edge: .leading, allowsFullSwipe: true
                        ) {
                            Button(role: .cancel) {
                            } label: {
                                Label("PR", systemImage: "trophy")
                            }
                            .tint(Color.orange)
                        }
                        .swipeActions(
                            edge: .leading, allowsFullSwipe: false
                        ) {
                            Button(role: .cancel) {
                            } label: {
                                Label(
                                    "Note",
                                    systemImage: "pencil.and.list.clipboard"
                                )
                            }
                        }
                        .swipeActions(
                            edge: .trailing, allowsFullSwipe: true
                        ) {
                            Button(role: .cancel) {
                            } label: {
                                Label(
                                    "Done", systemImage: "checkmark.circle")
                            }
                            .tint(Color.accentColor)
                        }
                }
                .onMove { indices, newOffset in
                    viewModel.reorderExercise(
                        from: indices,
                        to: newOffset
                    )
                }

                if viewModel.isEditing {
                    Button(action: {
                        viewModel.isAddWorkoutSheetPresented.toggle()
                    }) {
                        HStack(alignment: .center) {
                            Spacer()
                            Image(systemName: "plus")
                            Text("Add Exercise")
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .environment(
                \.editMode, .constant(viewModel.isEditing ? .active : .inactive))
            .padding(.horizontal, 0)
            .background()
            //            .onChange(of: workout) {
            //                currentExercise = workout.nextExercise()
            //
            //                if let exercise = currentExercise {
            //                    withAnimation {
            //                        proxy.scrollTo(exercise.id, anchor: .center)
            //                    }
            //                }
            //            }
        }
    }

    @ViewBuilder
    var startStopBtn: some View {
        HStack(alignment: .center) {
            if viewModel.workoutStarted {
                NavigationLink(
                    destination: EmptyView()
                        //                                WorkoutCompleteView(
                        //                                    workout: $workout,
                        //                                    showView: $workoutDone,
                        //                                    isNavigatingBack: $workoutStarted
                        //                                )
                ) {
                    HStack {
                        Image(systemName: "trophy")
                        Text("Done")
                            .bold()
                        Text("(\(viewModel.elapsedTimeFormatted))")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .onDisappear {
                    if viewModel.workoutStarted {
                        viewModel.startTimer()
                    }
                }
            } else {
                Button(action: viewModel.workoutStartStopAction) {
                    HStack {
                        Image(systemName: "play")
                        Text("Start")
                    }.padding()
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            listView

            Spacer()

            ProgressView(value: viewModel.getCompletedPercent())
                .progressViewStyle(
                    LinearProgressViewStyle(tint: Color.accentColor)
                )
                .animation(.easeInOut, value: viewModel.getCompletedPercent())
                .frame(height: 1)
                .padding()

            startStopBtn
                .font(.headline)
                .foregroundColor(.white)
                .background(Color.accentColor)
                .cornerRadius(10)
                .padding(.horizontal)
                .onDisappear {
                    viewModel.timer?.invalidate()
                }

            Spacer()
        }
        .navigationBarTitleDisplayMode(
            viewModel.isEditing ? .inline : .automatic
        )
        .navigationTitle(viewModel.workout?.name ?? "New Workout")
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
//                            if await viewModel.save() {
                                viewModel.isEditing.toggle()
//                            }
                        } else {
                            viewModel.isEditing.toggle()
                        }
                    }
                }
            }
        }
        .onChange(of: viewModel.workout) {
            print("Workout updated")
        }
        //        .onChange(of: workout) {
        //            updateLiveActivity()
        //        }
        .sheet(isPresented: $viewModel.isAddWorkoutSheetPresented) {
            @Previewable @State var selectedItems: [MultiSelectionOption] = []

            MultiSelectionPicker(
                title: "Select Exercises",
                options: viewModel.getExerciseListSelectionOptions(),
                selectedItems: $selectedItems,
                isAddingAllowed: false,
                onAddOption: { _ in return true }
            )
        }
    }

    //    private func completeSet(
    //        set: Binding<ExerciseSet>, skipSet: Bool
    //    ) {
    //        var exercise: Exercise? = nil
    //
    //        for group in workout.workout {
    //            for e in group.exercises {
    //                if e.sets.contains(where: { $0.id == set.id }) {
    //                    exercise = e
    //                }
    //            }
    //        }
    //
    //        guard let currentExercise = exercise else { return }
    //
    //        // Handle incomplete sets
    //        if let firstIncompleteSet = currentExercise.findFirstIncompleteSet() {
    //            if !set.wrappedValue.isCompleted && !set.wrappedValue.isSkipped {
    //                withAnimation {
    //                    completeOrSkipSet(
    //                        firstIncompleteSet, in: $workout, skip: skipSet)
    //
    //                    if !workoutStarted {
    //                        startWorkout()
    //                    }
    //                }
    //                return
    //            }
    //        }
    //
    //        // Handle undo of the last completed/skipped set
    //        if let lastHandledSet = currentExercise.findLastHandledSet() {
    //            withAnimation {
    //                undoLastHandledSet(lastHandledSet, in: $workout)
    //            }
    //        }
    //    }
    //
    //    private func completeOrSkipSet(
    //        _ set: ExerciseSet, in workout: Binding<Workout>, skip: Bool
    //    ) {
    //        updateSet(set, in: workout) { set in
    //            if skip {
    //                set.isSkipped = true
    //            } else {
    //                set.isCompleted = true
    //            }
    //        }
    //    }
    //
    //    private func undoLastHandledSet(
    //        _ set: ExerciseSet, in workout: Binding<Workout>
    //    ) {
    //        updateSet(set, in: workout) { set in
    //            set.isCompleted = false
    //            set.isSkipped = false
    //        }
    //    }
    //
    //    private func updateSet(
    //        _ targetSet: ExerciseSet, in workout: Binding<Workout>,
    //        update: (inout ExerciseSet) -> Void
    //    ) {
    //        for groupIndex in workout.wrappedValue.workout.indices {
    //            for exerciseIndex in workout.wrappedValue.workout[groupIndex]
    //                .exercises.indices
    //            {
    //                if let setIndex = workout.wrappedValue.workout[groupIndex]
    //                    .exercises[exerciseIndex].sets.firstIndex(where: {
    //                        $0.id == targetSet.id
    //                    })
    //                {
    //                    //                    Task {
    //                    //                        await workoutState.completeSet(setId: targetSet.id)
    //                    //                    }
    //
    //                    update(
    //                        &workout.wrappedValue.workout[groupIndex].exercises[
    //                            exerciseIndex
    //                        ].sets[setIndex])
    //                    return
    //                }
    //            }
    //        }
    //    }
}

#Preview {
    NavigationView {
        WorkoutView(
            trainingPlanId: "XP8rjv6fSYkxNGYyhyAX",
            workoutId: "E322F34C-76C0-4CAD-A8BE-B3A88FDE95E1")
    }
}
