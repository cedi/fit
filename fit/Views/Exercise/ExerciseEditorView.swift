//
//  ExerciseEditorView.swift
//  fit
//
//  Created by Cedric Kienzler on 23.02.25.
//

import SwiftUI

struct MediaItemView: View {
    let label: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        VStack {
            Button(action: action) {
                Image(systemName: systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(Color.accentColor)
                    .padding()
                    .background(Circle().fill(Color(.systemGray5)))
            }

            Text(label)
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }
}

struct ExerciseEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: ExerciseEditorViewModel
    @StateObject var globalDefaults: GlobalDefaultsViewModel

    init(exercise: FirestoreExercise) {
        _viewModel = .init(
            wrappedValue: ExerciseEditorViewModel(exercise: exercise))
        _globalDefaults = .init(wrappedValue: GlobalDefaultsViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Top row (Name)
                HStack(alignment: .center, spacing: 15) {
                    IconPickerControl(
                        Binding(
                            get: {
                                viewModel.exercise.systemIconName
                                    ?? "figure.strengthtraining.traditional"
                            },
                            set: { viewModel.exercise.systemIconName = $0 }
                        ),
                        size: 40
                    )

                    TextField(
                        "Exercise Name",
                        text: Binding(
                            get: { viewModel.exercise.name ?? "" },  // If nil, provide empty array
                            set: { viewModel.exercise.name = $0 }  // Update the value
                        )
                    )
                    .font(.title)
                    .keyboardType(.default)
                    .foregroundColor(.primary)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 10)
                    .cornerRadius(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5).opacity(0.3))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                Color.accentColor,
                                lineWidth: viewModel.exercise.name?.isEmpty
                                    ?? true
                                    ? 0 : 1
                            )
                    )
                }

                // Details
                VStack(alignment: .leading, spacing: 15) {
                    SectionView(title: "Description") {
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray5).opacity(0.3))
                                .frame(height: 122)

                            TextEditor(
                                text: Binding(
                                    get: {
                                        viewModel.exercise.description ?? ""  // If nil, provide empty array
                                    },
                                    set: { viewModel.exercise.description = $0 }  // Update the value
                                )
                            )
                            .frame(height: 100)
                            .autocapitalization(.sentences)
                            .multilineTextAlignment(.leading)
                            .keyboardType(.default)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 10)
                            .cornerRadius(10)
                            .background(Color.clear)
                            .scrollContentBackground(.hidden)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    Color.accentColor,
                                    lineWidth: viewModel.exercise.description?
                                        .isEmpty ?? true
                                        ? 0 : 1
                                )
                        )
                    }

                    SectionView(title: "Category") {
                        MultiSelectionControl(
                            text: "Select Workout Category",
                            selection: Binding(
                                get: {
                                    (viewModel.exercise.category ?? [])
                                        .toMultiSelectionOptions()
                                },
                                set: { newSelection in
                                    viewModel.exercise.category =
                                        newSelection.map { $0.text }
                                }
                            ),
                            options: globalDefaults.getExerciseCategories()
                                .toMultiSelectionOptions(),
                            isAddingAllowed: true,
                            onAddOption: {
                                return globalDefaults.addExerciseCategory($0.text)
                            }
                        )
                    }

                    SectionView(title: "Equipment") {
                        MultiSelectionControl(
                            text: "Select Workout Equipment",
                            selection: Binding(
                                get: {
                                    (viewModel.exercise.equipment ?? [])
                                        .toMultiSelectionOptions()
                                },
                                set: { newSelection in
                                    viewModel.exercise.equipment =
                                        newSelection.map { $0.text }
                                }
                            ),
                            options: globalDefaults.getExerciseEquipment()
                                .toMultiSelectionOptions(),
                            isAddingAllowed: true,
                            onAddOption: {
                                return globalDefaults.addExerciseEquipment($0.text)
                            }
                        )
                    }

                    SectionView(title: "Media") {
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible()), GridItem(.flexible()),
                            ], spacing: 16
                        ) {
                            MediaItemView(
                                label: "Image",
                                systemImage: "photo"
                            ) {
                                //viewModel.showImagePicker.toggle()
                            }
                            MediaItemView(
                                label: "Video", systemImage: "video"
                            ) {
                                //viewModel.showVideoPicker.toggle()
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.exercise.name ?? "New Exercise")
        .navigationBarItems(
            trailing: Button("Save") {
                Task {
                    if await viewModel.save() {
                        dismiss()
                    }
                }
            }
        )
    }
}

#Preview {
    NavigationView {
        ExerciseEditorView(
            exercise: FirestoreExercise(
                name: "Test",
                category: ["Strength"],
                equipment: ["Barbell"]
            )
        )
    }
}
