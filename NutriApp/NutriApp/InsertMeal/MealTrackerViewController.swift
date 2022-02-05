//
//  MealTrackerViewController.swift
//  NutriApp
//
//  Created by Mar Cabrera on 09/10/2019.
//  Copyright © 2019 Mar Cabrera. All rights reserved.
//

import UIKit
import RealmSwift
import HealthKit

class MealTrackerData {

    static var shared = MealTrackerData()

    private init() {}

    var typeOfMeal: String?
    var date: Date?
}

class MealTrackerViewController: UIViewController {

    var date: Date = Date().trimTime()
    var mealSelected: String = ""
    var macros: Macros?

    let realm = try! Realm() //Consider performing error handling
    var breakfastFoods: Results<Food>!
    var lunchFoods: Results<Food>!
    var dinnerFoods: Results<Food>!
    var snackFoods: Results<Food>!
    var dailyCalories: Results<DailyCalories>!


    @IBOutlet weak var leftDateButton: UIButton!
    @IBOutlet weak var rightDateButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var goalKcalLabel: UILabel!
    @IBOutlet weak var currentKcalLabel: UILabel!
    @IBOutlet weak var remainingKcalLabel: UILabel!
    @IBOutlet weak var burnedKcalLabel: UILabel!
    
    @IBOutlet weak var breakfastButton: UIButton!
    @IBOutlet weak var lunchButton: UIButton!
    @IBOutlet weak var dinnerButton: UIButton!
    @IBOutlet weak var snacksButton: UIButton!

    @IBOutlet weak var breakfastTableView: SelfSizedTableView!
    @IBOutlet weak var lunchTableView: SelfSizedTableView!
    @IBOutlet weak var dinnerTableView: SelfSizedTableView!
    @IBOutlet weak var snacksTableView: SelfSizedTableView!

    var currentCalories: Int = 0
    var remainingCalories: Int = 0
    var goalCalories: Int = 0
    var burnedCalories: Int = 0

    // Functionality for unwind segues
    @IBAction func unwindToMealTracker(segue: UIStoryboardSegue) {

    }

    @IBAction func timelineButtonClicked(_ sender: Any) {
        if let sender = sender as? TimelineButton {
            var lowerBoundDate = date
            var upperBoundDate = date
            switch sender {
            case is LeftButton:
                date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
                lowerBoundDate = Calendar.current.date(byAdding: .day, value: -1, to: date)!
                upperBoundDate = date
            case is RightButton:
                date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
                lowerBoundDate = date
                upperBoundDate = Calendar.current.date(byAdding: .day, value: 1, to: date)!
            default: fatalError("Button pressed was not a subclass of TimelineButton")
            }

            getBurnedCalories(startDate: date, endDate: Calendar.current.date(byAdding: .day, value: 1, to: date)!)

            breakfastFoods = realm.objects(Food.self).filter("date \(sender.lowerBoundOperator) %@ && date \(sender.upperBoundOperator) %@ and typeofMeal = 'BREAKFAST'", lowerBoundDate, upperBoundDate)
            lunchFoods = realm.objects(Food.self).filter("date \(sender.lowerBoundOperator) %@ && date \(sender.upperBoundOperator) %@ and typeofMeal = 'LUNCH'", lowerBoundDate, upperBoundDate)
            dinnerFoods = realm.objects(Food.self).filter("date \(sender.lowerBoundOperator) %@ && date \(sender.upperBoundOperator) %@ and typeofMeal = 'DINNER'", lowerBoundDate, upperBoundDate)
            snackFoods = realm.objects(Food.self).filter("date \(sender.lowerBoundOperator) %@ && date \(sender.upperBoundOperator) %@ and  typeofMeal = 'SNACKS'", lowerBoundDate, upperBoundDate)
        }
        dateLabel.text = date.fromDateToString()
        MealTrackerData.shared.date = date// Singleton for state of Food model

        reloadAllTableViews()

        getGoalCalories()
        updateCurrentCalories()
        updateRemainingCalories()
    }

    private func setSingletonValueAndSegue(button: UIButton) {
        if let text = button.titleLabel?.text {
            self.mealSelected = text
            MealTrackerData.shared.typeOfMeal = text // Singleton for Food model
        }
        self.performSegue(withIdentifier: SegueIdentifiers.insertMealSegue, sender: self)
    }

    @IBAction func breakfastButtonClicked(_ sender: Any) {
        setSingletonValueAndSegue(button: breakfastButton)
    }

    @IBAction func lunchButtonClicked(_ sender: Any) {
        setSingletonValueAndSegue(button: lunchButton)
    }


    @IBAction func dinnerButtonClicked(_ sender: Any) {
        setSingletonValueAndSegue(button: dinnerButton)
    }

    @IBAction func snacksButtonClicked(_ sender: Any) {
        setSingletonValueAndSegue(button: snacksButton)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Meal Tracker"
        dateLabel.text = date.fromDateToString()
        dateLabel.sizeToFit()

        MealTrackerData.shared.date = date// Singleton pattern

  //      loadAndDisplayGoalCalories() // Function to display goal calories from JSON file - DEPRECATED
        getGoalCalories() // Function that replaces the previous one

        // get burned calories of the date - HealthKit
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        getBurnedCalories(startDate: date, endDate: endDate)

        currentKcalLabel.sizeToFit()
        breakfastTableView.maxHeight = 372
        breakfastTableView.separatorStyle = .none

        queryFoodByDate()

        // Test for menstruation
    //    displayMenstrualFlowInformation(startDate: date, endDate: endDate)

    }

    override func viewDidAppear(_ animated: Bool) {

        updateCurrentCalories()
        updateRemainingCalories()
        reloadAllTableViews()
    }

    /// Private function as a test - not working anywhere that returns an Int from the data 
    private func displayMenstrualFlowInformation(startDate: Date, endDate: Date) {
        let healthKitStore = HKHealthStore()

        if let menstruationType = HKObjectType.categoryType(forIdentifier: .menstrualFlow) {
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

            let query = HKSampleQuery(sampleType: menstruationType, predicate: predicate, limit: 30, sortDescriptors: nil) { (query, sample, error) in

                if error != nil {
                    print("Something went wrong")
                    return
                }

                if let result = sample {

                    for item in result {
                        if let sample = item as? HKCategorySample {
                            let value = sample.value
                            print(value)
                        }
                    }

               //     print(result)
                }

            }

              healthKitStore.execute(query)
        }

      }

    private func reloadAllTableViews() {
        breakfastTableView.reloadData()
        lunchTableView.reloadData()
        dinnerTableView.reloadData()
        snacksTableView.reloadData()
    }

    private func getGoalCalories() {
        dailyCalories = realm.objects(DailyCalories.self).filter("date == %@", date)
        goalCalories = 0

        if !dailyCalories.isEmpty {
            goalCalories = dailyCalories.last!.goal
        } else { // if not empty, query the last one where date is available and update it
            dailyCalories = realm.objects(DailyCalories.self).filter("date < %@ AND goal > 0", date)

            guard let goalCal = dailyCalories.last?.goal else {
                goalCalories = 0
                return
            }

            goalCalories = goalCal
        }
        goalKcalLabel.text = "\(goalCalories)"

        queryFoodByDate()
        updateCurrentCalories()
        updateRemainingCalories()
    }

    /// Function that gets the count of all current calories from the different table views in the current date
    private func updateCurrentCalories() {
        currentCalories = 0

        for breakfast in breakfastFoods {
            currentCalories += breakfast.calories
        }

        for lunch in lunchFoods {
            currentCalories += lunch.calories
        }

        for dinner in dinnerFoods {
            currentCalories += dinner.calories
        }

        for snacks in snackFoods {
            currentCalories += snacks.calories
        }


        currentKcalLabel.text = "\(currentCalories)"
    }

    private func updateRemainingCalories() {

        remainingCalories = goalCalories - currentCalories
        remainingKcalLabel.text = "\(remainingCalories)"


        if remainingCalories < 0 {
            remainingKcalLabel.textColor = UIColor.red
        } else {
            let textLabelColor = UIColor(named: "FluidTextLabel")
            remainingKcalLabel.textColor = textLabelColor
        }
    }

    /// Function that querys all food from current date displayed on screen and filtered by type of meal
   private func queryFoodByDate() {
        breakfastFoods = realm.objects(Food.self).filter("date >= %@ && date <= %@ AND typeofMeal = 'BREAKFAST'", date, date)
        lunchFoods = realm.objects(Food.self).filter("date >= %@ && date <= %@ AND typeofMeal = 'LUNCH'", date, date)
        dinnerFoods = realm.objects(Food.self).filter("date >= %@ && date <= %@ AND typeofMeal = 'DINNER'", date, date)
        snackFoods = realm.objects(Food.self).filter("date >= %@ && date <= %@ AND typeofMeal = 'SNACKS'", date, date)
    }

    // MOCK FUNCTION
    private func makeAPICallSpoonacular() {
        let url = URL(string: "https://api.spoonacular.com/food/ingredients/9266/information?apiKey=4b5c9a82cd2742ed951a25a700ea8451")
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "GET"
        let dataTask = URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
            guard let data = data else {
                return

            }
            print(String(data: data, encoding: .utf8)!)
        }

        dataTask.resume()

    }

    private func loadAndDisplayGoalCalories() {
        let file = "Macros"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file).appendingPathExtension("json")

            do {
                let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)


                let decoder = JSONDecoder()

                do {
                     macros = try decoder.decode(Macros.self, from: data)
                } catch {
                    print(error.localizedDescription)
                }

            } catch let error as NSError{
                print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
            }
        }

        if let dailyCalories = macros?.totalKcal {
            goalKcalLabel.text = dailyCalories.toString()
            goalCalories = dailyCalories // Test for goal calories
        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.insertMealSegue {
            let controller = segue.destination as! InsertMealViewController
            controller.meal = self.mealSelected
        }
    }

    /// Function that gets data from HealthKit to obtain the burned calories in the last 24h from the user
    private func getBurnedCalories(startDate: Date, endDate: Date) {
        let healthKitStore = HKHealthStore()

        guard let energyBurnedSample = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned) else {
            print("Active Energy Sample is no longer available in HealthKit")
            return
        }

        let last24hPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let energyQuery = HKSampleQuery(sampleType: energyBurnedSample, predicate: last24hPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, sample, error) in

            guard error == nil, let quantitySamples = sample as? [HKQuantitySample] else {
                print("Something went wrong: \(error!)")
                return
            }

            let total = Int(quantitySamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.kilocalorie()) })

            DispatchQueue.main.async {
                self.burnedKcalLabel.text = "\(total)"
            }
        }

        healthKitStore.execute(energyQuery)
    }
}

extension MealTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRow = 0

        switch tableView {
        case breakfastTableView:
            numberOfRow = breakfastFoods.count
        case lunchTableView:
            numberOfRow = lunchFoods.count
        case dinnerTableView:
            numberOfRow = dinnerFoods.count
        case snacksTableView:
            numberOfRow = snackFoods.count
        default:
            print("Something went wrong!")
        }

        return numberOfRow
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = MyFoodsTableCell()

        switch tableView {
        case breakfastTableView:
            cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.breakfastCell, for: indexPath) as! MyFoodsTableCell

            let breakfast = breakfastFoods![indexPath.row]

            cell.textLabel?.text = breakfast.name
            cell.detailTextLabel?.text = "\(breakfast.calories)"

        case lunchTableView :
            cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.lunchCell, for: indexPath) as! MyFoodsTableCell

            let lunch = lunchFoods![indexPath.row]

            cell.textLabel?.text = lunch.name
            cell.detailTextLabel?.text = "\(lunch.calories)"

        case dinnerTableView:
            cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.dinnerCell, for: indexPath) as! MyFoodsTableCell

            let dinner = dinnerFoods![indexPath.row]

            cell.textLabel?.text = dinner.name
            cell.detailTextLabel?.text = "\(dinner.calories)"

        case snacksTableView:
            cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.snacksCell, for: indexPath) as! MyFoodsTableCell

            let snack = snackFoods![indexPath.row]

            cell.textLabel?.text = snack.name
            cell.detailTextLabel?.text = "\(snack.calories)"


        default:
            print("Something went wrong!")
        }


        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            switch tableView {
            case breakfastTableView:
                try! realm.write {
                    realm.delete(breakfastFoods![indexPath.row])
                }
                tableView.deleteRows(at: [indexPath], with: .fade) 

            case lunchTableView:
                try! realm.write {
                    realm.delete(lunchFoods![indexPath.row])
                }
                tableView.deleteRows(at: [indexPath], with: .fade)

            case dinnerTableView:
                try! realm.write {
                    realm.delete(dinnerFoods![indexPath.row])
                }
                tableView.deleteRows(at: [indexPath], with: .fade)

            case snacksTableView:
                try! realm.write {
                    realm.delete(snackFoods![indexPath.row])
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
            default:
                print("Oops, the item could not be removed")
            }


            
        }
    }

}



