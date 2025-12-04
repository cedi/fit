import SharedModels
import SwiftUI

struct TrainingPlanListView: View {
    @StateObject private var viewModel: TrainingPlanListViewModel

    init(
        viewModel: TrainingPlanListViewModel = TrainingPlanListViewModel()
    ) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            TextField("Search training plans", text: $viewModel.searchText)
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
                ForEach(viewModel.filteredTrainingPlans, id: \.id) { trainingPlan in
                    NavigationLink(destination: TrainingPlanView(trainingPlan: trainingPlan)) {
                        ListViewIconRow(
                            text: trainingPlan.name ?? "",
                            icon: trainingPlan.systemIconName
                            ?? "figure.strengthtraining.traditional"
                        )
                    }
                    .id(trainingPlan.id)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Training Plans")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Group {
                    NavigationLink(
                        destination: ExerciseEditorView(
                            exercise: FirestoreExercise()
                        )
                    ) {
                        Image(systemName: "plus")
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color.accentColor)
                    }
                }
            )

            if let errorMessage = viewModel.errorMessage {
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)\
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        TrainingPlanListView()
    }
}
