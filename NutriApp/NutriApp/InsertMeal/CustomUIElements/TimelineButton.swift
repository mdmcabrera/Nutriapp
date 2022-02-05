//
//  TimelineButton.swift
//  NutriApp
//
//  Created by Mar Cabrera on 23/01/2020.
//  Copyright © 2020 Mar Cabrera. All rights reserved.
//

import Foundation
import UIKit

protocol TimelineButton {
    var date: Date { get set }
    var lowerBoundDate: Date { get }
    var upperBoundDate: Date { get }
    var lowerBoundModifier: Int { get }
    var upperBoundModifier:  Int { get }
    var lowerBoundOperator: String { get }
    var upperBoundOperator: String { get }
}
class LeftButton: UIButton, TimelineButton {
    var date = Date().trimTime()
    var lowerBoundDate: Date { return Calendar.current.date(byAdding: .day, value: -2, to: date)! }
    var upperBoundDate: Date { return Calendar.current.date(byAdding: .day, value: -1, to: date)! }
    var lowerBoundModifier = -2
    var upperBoundModifier = -1
    var lowerBoundOperator = ">"
    var upperBoundOperator = "<="
}
class RightButton: UIButton, TimelineButton {
    var date = Date().trimTime()
    var lowerBoundDate: Date { return Calendar.current.date(byAdding: .day, value: 1, to: date)! }
    var upperBoundDate: Date { return Calendar.current.date(byAdding: .day, value: 2, to: date)! }
    var lowerBoundModifier = 1
    var upperBoundModifier = 2
    var lowerBoundOperator = ">="
    var upperBoundOperator = "<"
}
