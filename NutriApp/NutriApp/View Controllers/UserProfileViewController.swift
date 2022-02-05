//
//  ProfileViewController.swift
//  NutriApp
//
//  Created by Mar Cabrera on 30/09/2019.
//  Copyright © 2019 Mar Cabrera. All rights reserved.
//

import UIKit
import HealthKit

class UserProfileViewController: UITableViewController {
    var macros: Macros?

    private enum ProfileSection: Int {
        case ageSex
        case weightHeightBMI
        case readHealthKitData
        case saveBMI
    }

    private enum ProfileDataError: Error {
        case missingBodyMaxIndex

        var localizedDescription: String {
            switch self {
            case .missingBodyMaxIndex: return "Unable to calculate body mass index with available profile data"
            }
        }
    }

    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var bodyMassIndexLabel: UILabel!
    
    @IBOutlet weak var dailyCaloriesLabel: UILabel!

    private let userHealthProfile = UserHealthProfile()

    private func updateHealthInfo() {
        loadAndDisplayAgeAndSex()
        loadAndDisplayMostRecentHeight()
        loadAndDisplayMostRecentWeight()
        loadAndDisplayDailyCalories()

    }



    private func loadAndDisplayDailyCalories() {
        let file = "Macros"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file).appendingPathExtension("json")

            do {
                let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)


                let decoder = JSONDecoder()

                do {
                     macros = try decoder.decode(Macros.self, from: data)
                   // print(macros!)
                } catch {
                    print(error.localizedDescription)
                }


            } catch let error as NSError{
                print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
            }
        }

        if let dailyCalories = macros?.totalKcal {
            dailyCaloriesLabel.text = dailyCalories.toString()
        }
        
    }



    private func loadAndDisplayAgeAndSex() {
        do {
            let userAgeAndSex = try ProfileDataStore.getAgeAndSex()
            userHealthProfile.age = userAgeAndSex.age
            userHealthProfile.gender = userAgeAndSex.gender
            updateLabels()
        } catch let error {
            self.displayAlert(for: error)
        }
    }

    private func loadAndDisplayMostRecentHeight() {
        guard let heightSampleType = HKSampleType.quantityType(forIdentifier: .height) else {
            print("Height Sample is no longer available in HealthKit")
            return
        }

        ProfileDataStore.getMostRecentSample(for: heightSampleType) { (sample, error) in

            guard let sample = sample else {
                if let error = error {
                    self.displayAlert(for: error)
                }

                return
            }

            let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
            self.userHealthProfile.heightInMeters = heightInMeters
            self.updateLabels()
        }
    }

    private func loadAndDisplayMostRecentWeight() {
        guard let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
            print("Body Mass Sample Type is no longer available in HealthKit")
            return
        }

        ProfileDataStore.getMostRecentSample(for: weightSampleType) { (sample, error) in

            guard let sample = sample else {
                if let error = error {
                    self.displayAlert(for: error)
                }

                return
            }

            let weightInKg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            self.userHealthProfile.weightInKg = weightInKg
            self.updateLabels()

        }
    }

    private func updateLabels() {
        if let age = userHealthProfile.age {
            ageLabel.text = "\(age)"
        }

        if let gender = userHealthProfile.gender {
            sexLabel.text = "\(gender.stringRepresentation)"
        }

        if let weight = userHealthProfile.weightInKg {
            let weightFormatter = MassFormatter()
            weightFormatter.isForPersonMassUse = true
            weightLabel.text = weightFormatter.string(fromKilograms: weight)

        }

        if let height = userHealthProfile.heightInMeters {
            let heightFormatter = LengthFormatter()
            heightFormatter.isForPersonHeightUse = true
            heightLabel.text = heightFormatter.string(fromMeters: height)
        }

        if let bodyMassIndex = userHealthProfile.bodyMassIndex {
            bodyMassIndexLabel.text = String(format: "%.02f", bodyMassIndex)
        }
       }

    private func displayAlert(for error: Error) {

      let alert = UIAlertController(title: nil,
                                    message: error.localizedDescription,
                                    preferredStyle: .alert)

      alert.addAction(UIAlertAction(title: "O.K.",
                                    style: .default,
                                    handler: nil))

      present(alert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in

          guard authorized else {

            let baseMessage = "HealthKit Authorization Failed"

            if let error = error {
              print("\(baseMessage). Reason: \(error.localizedDescription)")
            } else {
              print(baseMessage)
            }

            return
          }
            DispatchQueue.main.async {
                self.updateHealthInfo()
            }

          print("HealthKit Successfully Authorized.")
        }

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = ProfileSection(rawValue: indexPath.section) else {
            fatalError("A ProfileSection should map to the index path's section")
        }

        switch section {
        case .readHealthKitData:
            updateHealthInfo()
        default: break
        }
    }

}

