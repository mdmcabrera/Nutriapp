//
//  SearchProductViewController.swift
//  NutriApp
//
//  Created by Mar Cabrera on 16/10/2019.
//  Copyright © 2019 Mar Cabrera. All rights reserved.
//

import UIKit
import RealmSwift

class SearchProductViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    var searchProduct = [String]()
    var products = [String]()
    var searching = false
    let realm = try! Realm()
    var favoriteFoods: Results<FavoriteFood>!

    @IBAction func unwindToSearchProductVC(segue: UIStoryboardSegue) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        queryFavoriteFoods()

    }

    private func queryFavoriteFoods() {
        favoriteFoods = realm.objects(FavoriteFood.self).filter("typeofMeal = '\(MealTrackerData.shared.typeOfMeal!)'")
        self.tableView.reloadData()

        for food in favoriteFoods {
            products.append(food.name!)
        }
    }



}

extension SearchProductViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
          return searchProduct.count
        } else {
            return favoriteFoods.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if searching {
            cell?.textLabel?.text = searchProduct[indexPath.row]
        } else {
            cell?.textLabel?.text = favoriteFoods[indexPath.row].name
            cell?.detailTextLabel?.text = "\(favoriteFoods[indexPath.row].carbs)"
        }
        return cell!
    }

}

extension SearchProductViewController: UISearchBarDelegate {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.searchProductResults {
            let controller = segue.destination as! SearchProductResultsTableViewController
            controller.productToSearch = searchBar.text!

        } else if segue.identifier == SegueIdentifiers.loadProductSearch {
            let controller = segue.destination as! LoadSearchProductViewController
            controller.productToSearch = searchBar.text!
        }
    }


    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchProduct = products.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})

        searching = true
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            performSegue(withIdentifier: SegueIdentifiers.loadProductSearch, sender: nil)
        } else {
            displayAlert()
        }

    }

    private func displayAlert() {

        let alert = UIAlertController(title: "Oops!",
                                      message: "Looks like you didn't write anything! Please try again",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "O.K.",
                                      style: .default,
                                      handler: nil))

        present(alert, animated: true, completion: nil)
      }



}
