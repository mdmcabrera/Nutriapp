//
//  ProductViewController.swift
//  NutriApp
//
//  Created by Mar Cabrera on 17/10/2019.
//  Copyright © 2019 Mar Cabrera. All rights reserved.
//

import UIKit
import RealmSwift

class TescoProductViewController: UIViewController, UITextFieldDelegate {
    var product: Product?
   
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var healthScoreLabel: UILabel!
    @IBOutlet weak var healthScoreImageView: UIImageView!

    @IBOutlet weak var energyLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var saturatesLabel: UILabel!
    @IBOutlet weak var carbohydratesLabel: UILabel!
    @IBOutlet weak var sugarsLabel: UILabel!
    @IBOutlet weak var fibreLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var saltLabel: UILabel!
    @IBOutlet weak var totalCaloriesLabel: UILabel!

    @IBOutlet weak var productQuantityTextField: UITextField! {
        didSet {
            productQuantityTextField?.addDoneCancelToolbar()
        }
       }
    @IBOutlet weak var saveProductButton: UIButton!
    @IBAction func saveProductCalories(_ sender: Any) {

        // Implement Realm configuration
        let realm = try! Realm()

        let food = Food()
        food.name = productDescriptionLabel.text!
        food.quantity = Int(productQuantityTextField.text!)!
        food.calories = Int(totalCaloriesLabel.text!)!
        food.carbs = Double(carbohydratesLabel.text!)!
        food.fat = Double(fatLabel.text!)!
        food.protein = Double(proteinLabel.text!)!

        // Gets the state of the singleton object to add it to the database
        food.date = MealTrackerData.shared.date
        food.typeofMeal = MealTrackerData.shared.typeOfMeal


        try! realm.write {
            realm.add(food, update: .modified)
        }

        performSegue(withIdentifier: SegueIdentifiers.unwindSegueToMealTracker, sender: self)

    }

    var energyValue = 0


    override func viewDidLoad() {
        super.viewDidLoad()
    //    let products = self.productResponse!.products
        getProductInfo()

        productQuantityTextField.keyboardType = UIKeyboardType.decimalPad
        listenKeyboardEvents()

        productQuantityTextField.delegate = self
        saveProductButton.isUserInteractionEnabled = false
        saveProductButton.isEnabled = false

        totalCaloriesLabel.sizeToFit()
    }

    private func getProductInfo() {
        guard let productDescription = product?.productDescription else {
            return
        }

        productDescriptionLabel.text = productDescription
        productDescriptionLabel.adjustsFontSizeToFitWidth = true

        guard let productHealthScore = product?.productCharacteristics?.healthScore else {
            return
        }

        healthScoreLabel.text = "\(productHealthScore)"

        guard let energyKcalInfo = product?.calcNutrition?.calcNutrients![1].valuePer100 else {
            /// Shows an alert when no nutritional information is available
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "Nutrition facts not found", message: "Sorry! We don't have any nutrition facts about this product", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            emptyNutritionalLabels()
            saveProductButton.isEnabled = false
            productQuantityTextField.isUserInteractionEnabled = false

            return
        }

         energyLabel.text = energyKcalInfo
        energyValue = Int(energyKcalInfo)!

        guard let fatInfo = product?.calcNutrition?.calcNutrients![2].valuePer100 else {
            return
        }

        fatLabel.text = fatInfo

        guard let saturatesInfo = product?.calcNutrition?.calcNutrients![3].valuePer100 else {
            return
        }

        saturatesLabel.text = saturatesInfo

        guard let carbohydratesInfo = product?.calcNutrition?.calcNutrients![4].valuePer100 else {
            return
        }

        carbohydratesLabel.text = carbohydratesInfo

        guard let sugarsInfo = product?.calcNutrition?.calcNutrients![5].valuePer100 else {
            return
        }

        sugarsLabel.text = sugarsInfo

        guard let fibreInfo = product?.calcNutrition?.calcNutrients![6].valuePer100 else {
            return
        }

        fibreLabel.text = fibreInfo

        guard let proteinInfo = product?.calcNutrition?.calcNutrients![7].valuePer100 else {
            return
        }

        proteinLabel.text = proteinInfo

        guard let saltInfo = product?.calcNutrition?.calcNutrients![8].valuePer100 else {
            return
        }

        saltLabel.text = saltInfo

        /*
               if productHealthScore <= 50 {
                   healthScoreLabel.textColor = .systemRed
                   healthScoreImageView.image = UIImage(systemName: "hand.draw")
               } else if productHealthScore > 50 && productHealthScore <= 70 {
                   healthScoreLabel.textColor = .systemOrange
               } else if productHealthScore > 71 {
                   healthScoreLabel.textColor = .systemGreen
               }

 */

    }

    private func emptyNutritionalLabels() {
        energyLabel.text = ""
        fatLabel.text = ""
        saturatesLabel.text = ""
        carbohydratesLabel.text = ""
        sugarsLabel.text = ""
        fibreLabel.text = ""
        proteinLabel.text = ""
        saltLabel.text = ""
    }

    private func listenKeyboardEvents() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChange(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChange(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChange(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    /// Stops listening for keyboard hide/show events
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillChangeFrameNotification,
                                                  object: nil)
    }

    @objc func keyboardWillChange(notification: Notification) {
        /// We get the size of the keyboard to be able to move the screen
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        if notification.name == UIResponder.keyboardWillShowNotification {
            view.frame.origin.y = -keyboardRect.height
        } else {
            view.frame.origin.y = 0
        }
    }

    ///Function that keeps track of input of textfield and enables button if user types 
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if !text.isEmpty {
            updateLabels(productQuantity: text)
            saveProductButton.isUserInteractionEnabled = true
            saveProductButton.isEnabled = true
        } else {
            totalCaloriesLabel.text = "0"
            saveProductButton.isUserInteractionEnabled = false
            saveProductButton.isEnabled = false
        }
         return true
    }

    /*
     Private function that updates the nutritional labels depending on the user's input on the textfield
     */
    private func updateLabels(productQuantity: String) {

        let energy = energyValue * Int(productQuantity)!
        totalCaloriesLabel.text = "\(energy/100)"

    }
}
