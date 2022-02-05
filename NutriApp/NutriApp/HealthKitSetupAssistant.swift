//
//  HealthKitSetupAssistant.swift
//  NutriApp
//
//  Created by Mar Cabrera on 27/09/2019.
//  Copyright © 2019 Mar Cabrera. All rights reserved.
//

import HealthKit

class HealthKitSetupAssistant {
    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }

    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        // Checks to see if Healthkit is available on the device
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
        // Missing weight
        guard let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            let menstrualFlow = HKObjectType.categoryType(forIdentifier: .menstrualFlow),
            let height = HKObjectType.quantityType(forIdentifier: .height),
            let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
            let gender = HKObjectType.characteristicType(forIdentifier: .biologicalSex)
                else {
                    completion(false, HealthkitSetupError.dataTypeNotAvailable)
                    return
                }

        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth, height, gender, bodyMass, activeEnergy, menstrualFlow]

        // Request authorization
        HKHealthStore().requestAuthorization(toShare: nil, read: healthKitTypesToRead) { (success, error) in
            completion(success, error)
        }
    }
}
