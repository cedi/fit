//
//  TrainingPlanViewModel.swift
//  fit
//
//  Created by Cedric Kienzler on 16.02.25.
//

import FirebaseFirestore
import SharedModels
import SwiftUI

@MainActor
class TrainingPlanListViewModel: ObservableObject {
    @Published var trainingPlans: [TrainingPlan] = []
    @Published var searchText: String = ""  // Search query
    @Published var errorMessage: String?

    var exerciseViewModel: ExerciseListViewModel

    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?

    public func unsubscribe() {
        if listenerRegistration != nil {
            listenerRegistration?.remove()
            listenerRegistration = nil
        }
    }

    func subscribe() {
        if listenerRegistration == nil {
            listenerRegistration = db.collection("trainingplans")
                .addSnapshotListener { [weak self] (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        self?.errorMessage =
                            "No documents in 'trainingplans' collection"
                        return
                    }

                    // TODO: Only fetch training plans the user has created, purchased, or is subscribed to
                    self?.trainingPlans = documents.compactMap {
                        queryDocumentSnapshot in
                        let result = Result {
                            try queryDocumentSnapshot.data(
                                as: TrainingPlan.self)
                        }

                        switch result {
                        case .success(let trainingPlan):
                            self?.errorMessage = nil
                            return trainingPlan

                        case .failure(let error):
                            // A ColorEntry value could not be initialized from the DocumentSnapshot.
                            switch error {
                            case DecodingError.typeMismatch(_, let context):
                                self?.errorMessage =
                                    "\(error.localizedDescription): \(context.debugDescription)"
                            case DecodingError.valueNotFound(_, let context):
                                self?.errorMessage =
                                    "\(error.localizedDescription): \(context.debugDescription)"
                            case DecodingError.keyNotFound(_, let context):
                                self?.errorMessage =
                                    "\(error.localizedDescription): \(context.debugDescription)"
                            case DecodingError.dataCorrupted(let key):
                                self?.errorMessage =
                                    "\(error.localizedDescription): \(key)"
                            default:
                                self?.errorMessage =
                                    "Error decoding document: \(error.localizedDescription)"
                            }
                            return nil
                        }
                    }
                }
        }
    }

    init(exerciseViewModel: ExerciseListViewModel = ExerciseListViewModel()) {
        self.exerciseViewModel = exerciseViewModel
        subscribe()
    }

    var filteredTrainingPlans: [TrainingPlan] {
        if searchText.isEmpty {
            return trainingPlans
        } else {
            return trainingPlans.filter {
                $0.name?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
}
