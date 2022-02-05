//
//  User.swift
//  NutriApp
//
//  Created by Mar Cabrera on 25/11/2019.
//  Copyright © 2019 Mar Cabrera. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var email: String?
    @objc dynamic var username: String?
    @objc dynamic var goalMacros: GoalMacros!
}

class GoalMacros: Object {
    @objc dynamic var carbs = 0
    @objc dynamic var protein = 0
    @objc dynamic var fats = 0
    @objc dynamic var totalCalories = 0

}

class DailyCalories: Object {
    @objc dynamic var caloriesID = UUID().uuidString
    @objc dynamic var goal = 0
    @objc dynamic var date: Date?

    override static func primaryKey() -> String {
        return "caloriesID"
    }
}
