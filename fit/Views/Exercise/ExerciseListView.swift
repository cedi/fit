//
//  ExerciseListView.swift
//  fit
//
//  Created by Cedric Kienzler on 23.02.25.
//

import SwiftUI

struct ExerciseListView: View {
    @StateObject private var viewModel: ExerciseListViewModel
    @Binding var selectedExerciseId: String

    init(
        viewModel: ExerciseListViewModel = ExerciseListViewModel(),
        isPresentingAddExerciseView: Bool = false,
        selectedExerciseId: Binding<String> = .constant("")
    ) {
        _viewModel = .init(wrappedValue: viewModel)
        _selectedExerciseId = selectedExerciseId
        viewModel.isPresentingAddExerciseView = isPresentingAddExerciseView
    }

    var body: some View {
        VStack {
            TextField("Search Exercises", text: $viewModel.searchText)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5).opacity(0.3))
                )
                .overlay(
                    HStack {
                        Spacer()
                        if !viewModel.searchText.isEmpty {
                            Button(action: { viewModel.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 10)
                        }
                    }
                )
                .padding(.horizontal)

            List {
                ForEach(viewModel.filteredExercises, id: \.id) { exercise in
                    if viewModel.isPresentingAddExerciseView {
                        ListViewIconRow(
                            text: exercise.name ?? "",
                            icon: exercise.systemIconName
                                ?? "figure.strengthtraining.traditional"
                        )
                        .id(exercise.id)
                    } else {
                        NavigationLink(
                            destination: ExerciseEditorView(exercise: exercise)
                        ) {
                            ListViewIconRow(
                                text: exercise.name ?? "",
                                icon: exercise.systemIconName
                                    ?? "figure.strengthtraining.traditional"
                            )
                        }
                        .id(exercise.id)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Group {
                    if !viewModel.isPresentingAddExerciseView {
                        NavigationLink(
                            destination: ExerciseEditorView(
                                exercise: FirestoreExercise()
                            )
                        ) {
                            Image(systemName: "plus")
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color.accentColor)
                        }
                    } else {
                        EmptyView()
                    }
                }
            )
        }
    }
}

#Preview {
    NavigationView {
        ExerciseListView(viewModel: createExerciseListMockVM())
    }
}

func createExerciseListMockVM() -> ExerciseListViewModel {
    let viewModel = ExerciseListViewModel()
    viewModel.exercises = [
        FirestoreExercise(
            id: "1",
            name: "Deadlift",
            category: ["Compound Exercise"],
            equipment: ["Powerbar"]
        ),
        FirestoreExercise(
            id: "2",
            name: "Squat",
            category: ["Compound Exercise"],
            equipment: ["Powerbar"]
        ),
        FirestoreExercise(
            id: "3",
            name: "Bench Press",
            category: ["Compound Exercise"],
            equipment: ["Powerbar"]
        ),
    ]
    return viewModel
}
