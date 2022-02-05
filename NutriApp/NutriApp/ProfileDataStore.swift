//
//  ProfileDataStore.swift
//  NutriApp
//
//  Created by Mar Cabrera on 30/09/2019.
//  Copyright © 2019 Mar Cabrera. All rights reserved.
//

import HealthKit

class ProfileDataStore {

    class func getAgeAndSex() throws -> (age: Int, gender: HKBiologicalSex) {

           let healthKitStore = HKHealthStore()

           do {
               // Throws error if these data are not available
               let birthdayComponents = try healthKitStore.dateOfBirthComponents()
               let gender = try healthKitStore.biologicalSex()

               // Use of Calendar to calculate age
               let today = Date()
               let calendar = Calendar.current
               let todayDateComponents = calendar.dateComponents([.year], from: today)

               let thisYear = todayDateComponents.year!
               let age = thisYear - birthdayComponents.year!

               let unwrappedBiologicalSex = gender.biologicalSex

               return (age, unwrappedBiologicalSex)

           }
       }

    class func getMostRecentSample(for sampleType: HKSampleType, completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {

        // Using HKQuery to load the most recent samples
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let limit = 1

        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in

            DispatchQueue.main.async {
                guard let samples = samples, let mostRecentSample = samples.first as? HKQuantitySample else {
                    completion(nil, error)
                    return
                }

                completion(mostRecentSample, nil)
            }
        }

        HKHealthStore().execute(sampleQuery)
    }
}
