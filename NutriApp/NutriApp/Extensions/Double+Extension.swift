//
//  Double+Extension.swift
//  NutriApp
//
//  Created by Mar Cabrera on 17/10/2019.
//  Copyright © 2019 Mar Cabrera. All rights reserved.
//

import Foundation

extension Double {
    func removeZerosFromEnd() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return String(formatter.string(from: number) ?? "")
    }

    // Takes a double with long decimals and trims it as many positions as desired
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
