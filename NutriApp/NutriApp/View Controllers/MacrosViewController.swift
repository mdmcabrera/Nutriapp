//
//  MacrosViewController.swift
//  NutriApp
//
//  Created by Mar Cabrera on 01/10/2019.
//  Copyright © 2019 Mar Cabrera. All rights reserved.
//

import UIKit
import RealmSwift

class MacrosViewController: UIViewController {

    var carbsValue = 0
    var proteinValue = 0
    var fatsValue = 0
    var totalKcalValue = 0
    var macros: Macros?

    let realm = try! Realm()
    let date: Date = Date().trimTime()


/*
    @IBOutlet weak var logoutButton: UIButton!
    @IBAction func logoutUser(_ sender: Any) {
        SessionManager.logout()


        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.present(newViewController, animated: true, completion: nil)

    }
*/
    @IBOutlet weak var carbsSlider: UISlider!
    @IBOutlet weak var proteinSlider: UISlider!
    @IBOutlet weak var fatsSlider: UISlider!


    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var fatsLabel: UILabel!


    @IBOutlet weak var saveDataButton: UIButton!
    @IBOutlet weak var totalKcalLabel: UILabel!

    @IBAction func carbsValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)

        carbsLabel.text = "\(currentValue)"

        carbsValue = currentValue

        updateTotalKcalLabel(value: currentValue, typeOf: "CARBS")

    }
    
    @IBAction func proteinValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)

        proteinLabel.text = "\(currentValue)"

        proteinValue = currentValue

        updateTotalKcalLabel(value: currentValue, typeOf: "PROTEIN")
    }

    @IBAction func fatsValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)

        fatsLabel.text = "\(currentValue)"

        fatsValue = currentValue

        updateTotalKcalLabel(value: currentValue, typeOf: "FATS")

    }

    @IBAction func saveData(_ sender: Any) {
        // Save data into json file
        macros = Macros(carbs: carbsValue, protein: proteinValue, fats: fatsValue, totalKcal: totalKcalValue)
        saveMacrosToFile()

        saveMacrostoDB()

    }


    override func viewDidLoad() {
        super.viewDidLoad()

        carbsSlider.minimumTrackTintColor = .white
        proteinSlider.minimumTrackTintColor = .white
        fatsSlider.minimumTrackTintColor = .white

        readMacrosFromFile()
    }
    
    // MARK: - Private Functions
    private func updateTotalKcalLabel(value: Int, typeOf: String) {

        switch typeOf {
        case "CARBS":
            carbsValue = carbsValue * 4
        case "PROTEIN":
            proteinValue = proteinValue * 4
        case "FATS":
            fatsValue = fatsValue * 9
        default:
            break
        }
        totalKcalValue = carbsValue + proteinValue + fatsValue
        totalKcalLabel.text = "\(totalKcalValue)"
    }

    private func saveMacrosToFile() {
        let file = "Macros"

        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file).appendingPathExtension("json")

            print("File Path: \(fileURL.path)")

            do {
                let encoder = JSONEncoder()
                let jsonData = try encoder.encode(macros)
                try jsonData.write(to: fileURL)

                showAlert()
            }
            catch let error as NSError{
                print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
            }
        }

    }

    private func readMacrosFromFile() {
        let file = "Macros"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file).appendingPathExtension("json")

            do {
                let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)


                let decoder = JSONDecoder()

                do {
                     macros = try decoder.decode(Macros.self, from: data)
                    print(macros!)
                } catch {
                    print(error.localizedDescription)
                }


            } catch let error as NSError{
                print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
            }
        }

        updateUI()

    }

    private func saveMacrostoDB() {

        let dailyCalories = DailyCalories()
        dailyCalories.goal = totalKcalValue
        dailyCalories.date = date

        try! realm.write {
            realm.add(dailyCalories, update: .modified)
        }

    }

    private func updateUI() {
        guard let unwrappedMacros = macros else {
            return
        }

        /// The data returned is in calories, so here is the operation to obtain the grams of each macro
        let carbsInGr = unwrappedMacros.carbs/4
        let proteinInGr = unwrappedMacros.protein/4
        let fatsInGr = unwrappedMacros.fats/9

        /// Updates the labels in the view controller
        carbsLabel.text = "\(carbsInGr)"
        proteinLabel.text = "\(proteinInGr)"
        fatsLabel.text = "\(fatsInGr)"
        totalKcalLabel.text = "\(unwrappedMacros.totalKcal)"

        // updates the slider in the view controller
        carbsSlider.value = Float(carbsInGr)
        proteinSlider.value = Float(proteinInGr)
        fatsSlider.value = Float(fatsInGr)
    }

    private func showAlert() {
        let alert = UIAlertController(title: nil,
                                      message: "Your macros were saved successfully!",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))

        present(alert, animated: true, completion: nil)

    }


}
