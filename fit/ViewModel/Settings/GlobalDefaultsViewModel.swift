//
//  GlobalDefaultsViewModel.swift
//  fit
//
//  Created by Cedric Kienzler on 02.03.25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

extension Array where Element == String {
    func toMultiSelectionOptions() -> [MultiSelectionOption] {
        return self.map { MultiSelectionOption($0) }
    }
}

@MainActor
class GlobalDefaultsViewModel: ObservableObject {
    @Published var defaults: [GlobalDefaults] = []
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?

    public func unsubscribe() {
        if listenerRegistration != nil {
            listenerRegistration?.remove()
            listenerRegistration = nil
        }
    }

    private func subscribe() {
        if listenerRegistration == nil {
            listenerRegistration = db.collection("defaults")
                .addSnapshotListener { [weak self] (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        self?.errorMessage =
                            "No documents in 'defaults' collection"
                        return
                    }

                    self?.defaults = documents.compactMap {
                        queryDocumentSnapshot in
                        let result = Result {
                            try queryDocumentSnapshot.data(
                                as: GlobalDefaults.self)
                        }

                        switch result {
                        case .success(let exercise):
                            self?.errorMessage = nil
                            return exercise

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

    init() {
        subscribe()
    }

    public func save() -> Bool {
        guard defaults.count == 1 else {
            return false
        }

        var defaults = defaults[0]


        do {
            let ref = db.collection("defaults").document(defaults.id ?? "")
            defaults.lastUpdatedAt = nil
            try ref.setData(from: defaults)

            return true
        } catch {
            print(error.localizedDescription)
        }

        return false
    }

    public func getExerciseCategories() -> [String] {
        guard defaults.count == 1 else {
            return []
        }

        guard let categories = defaults[0].ExerciseCategories else {
            return []
        }

        return categories
    }

    public func getExerciseEquipment() -> [String] {
        guard defaults.count == 1 else {
            return []
        }

        guard let equipment = defaults[0].ExerciseEquipment else {
            return []
        }

        return equipment
    }

    public func addExerciseCategory(_ category: String) -> Bool {
        var categories = getExerciseCategories()
        categories.append(category)

        if defaults.isEmpty {
            defaults = [GlobalDefaults(ExerciseCategories: categories)]
        } else {
            defaults[0].ExerciseCategories = categories
        }

        return save()
    }

    public func addExerciseEquipment(_ equipment: String) -> Bool {
        var equipments = getExerciseEquipment()
        equipments.append(equipment)

        if defaults.isEmpty {
            defaults = [GlobalDefaults(ExerciseEquipment: equipments)]
        } else {
            defaults[0].ExerciseEquipment = equipments
        }

        return save()
    }
}
