//
//  EdamamProductViewController.swift
//  NutriApp
//
//  Created by Mar Cabrera on 20/01/2020.
//  Copyright © 2020 Mar Cabrera. All rights reserved.
//

import UIKit
import RealmSwift

class EdamamProductViewController: UIViewController {
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var energyKcalLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var totalCaloriesLabel: UILabel!

    @IBOutlet weak var saveProductButton: UIButton!
    @IBOutlet weak var productAmountTextField: UITextField!
    @IBOutlet weak var favoriteProductButton: UIButton!
    @IBOutlet weak var nutritionFactsLabel: UILabel!

    var edamamProduct: EdamamFood?
    var energyValue = 0
    var buttonActive = true
    var isFavorite = false
    let realm = try! Realm()

    var favoriteFoundFood: Results<FavoriteFood>!

    @IBAction func favoriteButtonTapped(_ sender: Any) {
        let largeConfiguration = UIImage.SymbolConfiguration(scale: .large)

        if buttonActive {
            favoriteProductButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: largeConfiguration), for: .normal)
            isFavorite = true
        } else {
            favoriteProductButton.setImage(UIImage(systemName: "heart", withConfiguration: largeConfiguration), for: .normal)
            isFavorite = false
        }
        buttonActive = !buttonActive
    }

    
    @IBAction func saveProductCalories(_ sender: Any) {

        let food = Food()
        food.name = productLabel.text!
        food.quantity = Int(productAmountTextField.text!)!
        food.calories = Int(totalCaloriesLabel.text!)!
        food.carbs = Double(carbsLabel.text!)!
        food.fat = Double(fatLabel.text!)!
        food.protein = Double(proteinLabel.text!)!

        food.date = MealTrackerData.shared.date
        food.typeofMeal = MealTrackerData.shared.typeOfMeal

        try! realm.write {
            realm.add(food, update: .modified)
        }

        if isFavorite{
            addProductToFavorites()
        }

        performSegue(withIdentifier: SegueIdentifiers.unwindSegueToMealTracker, sender: self)


    }



    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayProductInformation()

    // If the food has been previously saved as a favorite, it needs to be queried and the button for the heart needs to be filled


        productAmountTextField.keyboardType = UIKeyboardType.decimalPad
        totalCaloriesLabel.sizeToFit()

        productAmountTextField.delegate = self
        productAmountTextField.addDoneCancelToolbar()

        listenKeyboardEvents()

        saveProductButton.isUserInteractionEnabled = false
        saveProductButton.isEnabled = false

    }

    private func displayProductInformation() {
        productLabel.text = edamamProduct?.name

        energyKcalLabel.text = "\(edamamProduct!.nutrients.energyKcalRounded)"
        carbsLabel.text = "\(edamamProduct!.nutrients.carbsRounded)"
        proteinLabel.text = "\(edamamProduct!.nutrients.proteinRounded)"
        fatLabel.text = "\(edamamProduct!.nutrients.fatRounded)"

        energyValue = Int(edamamProduct!.nutrients.energyKcalRounded)

    }
/// Function that will look in the DB if the food added has been added previously with the same type of meal. If it hasn't, it will add it to the DB, if not, it won't do anything
    private func addProductToFavorites() {
        let favoriteFood = FavoriteFood()
        favoriteFood.name = productLabel.text!
        favoriteFood.typeofMeal = MealTrackerData.shared.typeOfMeal
        favoriteFood.calories = Double(energyKcalLabel.text!)!
        favoriteFood.carbs = Double(carbsLabel.text!)!
        favoriteFood.fat = Double(fatLabel.text!)!
        favoriteFood.protein = Double(proteinLabel.text!)!

        favoriteFoundFood = realm.objects(FavoriteFood.self).filter("name = '\(favoriteFood.name!)' && typeofMeal = '\(favoriteFood.typeofMeal!)'")

              if favoriteFoundFood.isEmpty {
                try! realm.write {
                    realm.add(favoriteFood)
                }
              }
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

}

extension EdamamProductViewController: UITextFieldDelegate {

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
