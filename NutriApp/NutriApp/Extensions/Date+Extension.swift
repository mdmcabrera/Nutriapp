//
//  Date.swift
//  NutriApp
//
//  Created by Mar Cabrera on 14/10/2019.
//  Copyright © 2019 Mar Cabrera. All rights reserved.
//

import Foundation

extension Date {
    func fromDateToString()-> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"

        let date = formatter.string(from: self)
        return date
    }

    func trimTime() -> Date {
        var boundary = Date()
        var interval: TimeInterval = 0
        _ = Calendar.current.dateInterval(of: .day, start: &boundary, interval: &interval, for: self)

        return Date(timeInterval: TimeInterval(NSTimeZone.system.secondsFromGMT()), since: boundary)
    }

}
