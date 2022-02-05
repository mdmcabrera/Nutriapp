//
//  BarcodeViewController.swift
//  NutriApp
//
//  Created by Mar Cabrera on 15/10/2019.
//  Copyright © 2019 Mar Cabrera. All rights reserved.
//

import UIKit
import MTBBarcodeScanner

class BarcodeViewController: UIViewController {

    @IBOutlet weak var previewView: UIView!
    var scanner: MTBBarcodeScanner?

    var barcode: String = ""
    var productResponse: TescoProductResponse?
    var product: Product?

    let tescoAPIKey = "c08aeb4a16694b218b3c9dc6ef5375f5"


    override func viewDidLoad() {
        super.viewDidLoad()

        scanner = MTBBarcodeScanner(previewView: previewView)
        self.scanner?.unfreezeCapture()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startScanningBarcode()
    }

    /**
     Method that scans a barcode in a live streaming view
    */
    func startScanningBarcode() {
        MTBBarcodeScanner.requestCameraPermission(success: { success in
            if success {
                do {
                    try self.scanner?.startScanning(resultBlock: { codes in
                        if let codes = codes {
                            for code in codes {
                                self.barcode = code.stringValue!
                                self.scanner?.freezeCapture()
                                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                                self.performCallTescoAPI(barcode: self.barcode)

                            }
                        }

                    })
                } catch {
                    NSLog("Unable to start scanning")
                }
            } else {

                let alertController = UIAlertController(title: "Scanning unavailable", message: "This app does not have permission to access the camera", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                })
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.showProduct {
            let controller = segue.destination as! TescoProductViewController
            controller.product = self.product

        }
    }

    private func performCallTescoAPI(barcode: String) {

        let url_barcode = "https://dev.tescolabs.com/product/?gtin=\(barcode)"

        let url = NSURL(string: url_barcode)

        let request = NSMutableURLRequest(url: url! as URL)
        request.setValue(self.tescoAPIKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
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
                    self.productResponse = try decoder.decode(TescoProductResponse.self, from: jsonData)
                    let products = self.productResponse!.products
                    /// If the Tesco API doesn't have the product on their database
                    if products.count == 0 {
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: "Item not found", message: "Sorry! We don't have this item in our database at the moment", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                                 self.scanner?.unfreezeCapture()
                            })
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.product = products[0]
                            //TODO: Uncomment once the nutritional information gets done
                         //   if productNutritionInfo != nil {
                            self.performSegue(withIdentifier: SegueIdentifiers.showProduct, sender: self) 
                        //    }

                        }
                    }
                    
                } catch {
                    print("Cannot process data")
                }

            } else {
                print("Error: \(String(describing: error))")
            }
        }

        mData.resume()

    }


}
