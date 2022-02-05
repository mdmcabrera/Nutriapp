//
//  LoadSearchProductViewController.swift
//  NutriApp
//
//  Created by Mar Cabrera on 14/01/2020.
//  Copyright © 2020 Mar Cabrera. All rights reserved.
//

import UIKit

class LoadSearchProductViewController: UIViewController {

    @IBOutlet weak var searchProductSpinner: UIActivityIndicatorView!
    var productToSearch: String = ""
    let edamamAppID = "6a071a74"
    let edamamAppKey = "e222b6b7551c6575c6a260ad126139a4"
    var productEdamamResponse: ProductEdamamResponse?



    override func viewDidLoad() {
        super.viewDidLoad()

        searchProductSpinner.startAnimating()
        searchFoodEdamamAPI()
    }

    private func searchFoodEdamamAPI() {

        let encodedStringProduct = productToSearch.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url_food_search = "https://api.edamam.com/api/food-database/parser?ingr=\(encodedStringProduct)&app_id=\(edamamAppID)&app_key=\(edamamAppKey)"
        let url = NSURL(string: url_food_search)

        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "GET"
        let session = URLSession.shared

        let mData = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in

            if let _ = response as? HTTPURLResponse {
                guard let jsonData = data else {
                    print("No data available")
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    self.productEdamamResponse = try decoder.decode(ProductEdamamResponse.self, from: jsonData)
                    let products = self.productEdamamResponse!.hints
                    if products?.count == 0 {
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: "Item not found", message: "Sorry! We can't find this product in our database", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                                self.navigationController?.popViewController(animated: true)
                            })
                            alertController.addAction(okAction
                            
                            //
                            
                            
                            
                            
                            
                            
                            )
                            self.present(alertController, animated: true, completion: nil)
                        }

                    } else {
                        DispatchQueue.main.async {
                            self.searchProductSpinner.stopAnimating()
                            self.performSegue(withIdentifier: SegueIdentifiers.searchProductResults, sender: nil)

                        }
                    }

                } catch {
                    print("Cannot process data")
                }

            }

        }

        mData.resume()

    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.searchProductResults {
            let controller = segue.destination as! SearchProductResultsTableViewController
            controller.productEdamamResults = self.productEdamamResponse!
        }
    }

}
