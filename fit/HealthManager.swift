//
//  HealthManager.swift
//  fit
//
//  Created by Cedric Kienzler on 21.01.25.
//


import HealthKit

class HealthManager {
    let healthStore = HKHealthStore()

    func requestAuthorization(completion: @Sendable @escaping (Bool, Error?) -> Void) {
        // Define the data types you want to read/write
        guard let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass),
              let activeEnergyBurnedType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(false, nil)
            return
        }

        let readTypes: Set<HKObjectType> = [weightType]
        let writeTypes: Set<HKSampleType> = [activeEnergyBurnedType]

        // Request access
        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
            completion(success, error)
        }
    }
}
