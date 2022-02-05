//
//  UserHealthProfile.swift
//  NutriApp
//
//  Created by Mar Cabrera on 30/09/2019.
//  Copyright © 2019 Mar Cabrera. All rights reserved.
//

import HealthKit

class UserHealthProfile {
    var age: Int?
    var gender: HKBiologicalSex?
    var heightInMeters: Double?
    var weightInKg: Double?

    var bodyMassIndex: Double? {
        guard let weightInKg = weightInKg, let heightInMeters = heightInMeters, heightInMeters > 0 else {
            return nil
        }
        return (weightInKg/(heightInMeters*heightInMeters))
    }

}
