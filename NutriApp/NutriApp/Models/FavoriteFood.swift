//
//  FavoriteFood.swift
//  NutriApp
//
//  Created by Mar Cabrera on 24/01/2020.
//  Copyright © 2020 Mar Cabrera. All rights reserved.
//

import Foundation
import RealmSwift

class FavoriteFood: Object {
    @objc dynamic var foodID = UUID().uuidString
    @objc dynamic var name: String?
    @objc dynamic var typeofMeal: String?
    @objc dynamic var calories = 0.0
    @objc dynamic var carbs = 0.0
    @objc dynamic var fat = 0.0
    @objc dynamic var protein = 0.0

    override static func primaryKey() -> String? {
        return "foodID"
    }
}
