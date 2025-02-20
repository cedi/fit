//
//  HealthManager.swift
//  fit
//
//  Created by Cedric Kienzler on 21.01.25.
//

import HealthKit

@MainActor
class HealthKitPermissionViewModel: ObservableObject {
    @Published var errorMessage: String?

    private let healthStore = HKHealthStore()
    private let onSave: (() async -> Void)

    init(onSave: @escaping () async -> Void = {}) {
        self.onSave = onSave
    }

    /// request the authorization from the user to allow accessing HealthKit
    /// - Note: should the authorization fail, `errorMessage` will be set with an appropriate value
    func requestAuthorization() {
        // Define the data types you want to read/write
        guard
            let weightType = HKObjectType.quantityType(
                forIdentifier: .bodyMass),
            let activeEnergyBurnedType = HKObjectType.quantityType(
                forIdentifier: .activeEnergyBurned)
        else {
            errorMessage = "HealthKit authorization was denied."
            return
        }

        let readTypes: Set<HKObjectType> = [weightType]
        let writeTypes: Set<HKSampleType> = [activeEnergyBurnedType]

        // Request access
        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) {
            [weak self] success, error in
            guard let strongSelf = self else { return }

            Task { @MainActor in
                if success {
                    await strongSelf.onSave()
                } else {
                    strongSelf.errorMessage =
                        error?.localizedDescription
                        ?? "HealthKit authorization was denied."
                }
            }
        }
    }
}
