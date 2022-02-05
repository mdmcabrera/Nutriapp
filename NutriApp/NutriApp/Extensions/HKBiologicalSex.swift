//
//  HKBiologicalSex.swift
//  NutriApp
//
//  Created by Mar Cabrera on 30/09/2019.
//  Copyright © 2019 Mar Cabrera. All rights reserved.
//

import HealthKit

extension HKBiologicalSex {
    var stringRepresentation: String {
        switch self {
            case .notSet: return "Unknown"
            case .female: return "Female"
            case .male: return "Male"
            case .other: return "Other"
        @unknown default:
            fatalError()
        }
    }
}
