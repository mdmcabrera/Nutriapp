//
//  SearchProductResultsTableViewController.swift
//  NutriApp
//
//  Created by Mar Cabrera on 14/01/2020.
//  Copyright © 2020 Mar Cabrera. All rights reserved.
//

import UIKit

class SearchProductResultsTableViewController: UITableViewController {

    var productToSearch: String = ""
    var productEdamamResults: ProductEdamamResponse?

    var productNameResults: [String] = []
    var productBrandResults: [String] = []
    var nutrientsProductResults: [Nutrients] = []

    var caloriesProductResults: [String] = []

    var edamamFoodArray: [EdamamFood] = []
    var edamamProduct: EdamamFood?


    override func viewDidLoad() {
        super.viewDidLoad()

        processAPIResponse()

    }

    private func processAPIResponse() {
        guard let searchText = productEdamamResults?.text else {
            return
        }
        self.title = "Results for '\(searchText)'"

        guard let productHints = productEdamamResults?.hints else {
            
            return
        }

        for hint in productHints {
            guard let nutrients = hint.food?.nutrients else {
                return
            }

            edamamProduct = EdamamFood(name: (hint.food?.label)!, brand: hint.food?.getBrand(), nutrients: nutrients)

            edamamFoodArray.append(edamamProduct!)

        }

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return edamamFoodArray.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.edamamProductCell, for: indexPath) as! EdamamProductTableCell

        cell.nameLabel?.text = edamamFoodArray[indexPath.row].name
        cell.brandLabel?.text = edamamFoodArray[indexPath.row].brand
        cell.caloriesLabel?.text = "\(edamamFoodArray[indexPath.row].nutrients.energyKcalRounded)"

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        edamamProduct = edamamFoodArray[indexPath.row]
        self.performSegue(withIdentifier: SegueIdentifiers.showEdamamProduct, sender: nil)
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.showEdamamProduct {
            let controller = segue.destination as! EdamamProductViewController
            controller.edamamProduct = self.edamamProduct
        }
    }
}
