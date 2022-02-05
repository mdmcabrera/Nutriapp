//
//  InsertMealViewController.swift
//  NutriApp
//
//  Created by Mar Cabrera on 15/10/2019.
//  Copyright © 2019 Mar Cabrera. All rights reserved.
//

import UIKit

class InsertMealViewController: UIViewController {

    var meal: String = ""

    @IBOutlet weak var mealLabel: UILabel!
    @IBOutlet weak var barcodeView: UIView!
    @IBOutlet weak var searchView: UIView!

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        mealLabel.text = meal
        mealLabel.font = UIFont(name: "dealerplate", size: 30)

    }
    
    @IBAction func switchViews(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            barcodeView.alpha = 0
            searchView.alpha = 1
        } else {
            barcodeView.alpha = 1
            searchView.alpha = 0
        }
    }

}
