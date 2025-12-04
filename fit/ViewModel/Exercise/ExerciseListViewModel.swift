//
//  ExerciseListViewModel.swift
//  fit
//
//  Created by Cedric Kienzler on 23.02.25.
//

import FirebaseFirestore
import Foundation

class ExerciseListViewModel: ObservableObject {
    @Published var exercises: [FirestoreExercise] = []
    @Published var searchText: String = ""  // Search query
    @Published var isPresentingAddExerciseView: Bool = false
    @Published var errorMessage: String?

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
        listenerRegistration = db.collection("exercises")
          .addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
              self?.errorMessage = "No documents in 'exercises' collection"
              return
            }

            self?.exercises = documents.compactMap { queryDocumentSnapshot in
                let result = Result {
                    try queryDocumentSnapshot.data(as: FirestoreExercise.self)
                }

              switch result {
              case .success(let exercise):
                  self?.errorMessage = nil
                  return exercise

              case .failure(let error):
                // A ColorEntry value could not be initialized from the DocumentSnapshot.
                switch error {
                case DecodingError.typeMismatch(_, let context):
                  self?.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                case DecodingError.valueNotFound(_, let context):
                  self?.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                case DecodingError.keyNotFound(_, let context):
                  self?.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                case DecodingError.dataCorrupted(let key):
                  self?.errorMessage = "\(error.localizedDescription): \(key)"
                default:
                  self?.errorMessage = "Error decoding document: \(error.localizedDescription)"
                }
                return nil
              }
            }
          }
      }
    }

    init() {
        subscribe()
    }

    var filteredExercises: [FirestoreExercise] {
        if searchText.isEmpty {
            return exercises
        } else {
            return exercises.filter {
                $0.name?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
}
