//
//  Food.swift
//  NutriApp
//
//  Created by Mar Cabrera on 27/11/2019.
//  Copyright © 2019 Mar Cabrera. All rights reserved.
//

import Foundation
import RealmSwift

class Food: Object {
    @objc dynamic var foodID = UUID().uuidString
    @objc dynamic var name: String?
    @objc dynamic var date: Date?
    @objc dynamic var typeofMeal: String?
    @objc dynamic var quantity = 0
    @objc dynamic var calories = 0
    @objc dynamic var carbs = 0.0
    @objc dynamic var fat = 0.0
    @objc dynamic var protein = 0.0

    override static func primaryKey() -> String? {
        return "foodID"
    }
}

