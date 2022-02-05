//
//  ProductEdamamResponse.swift
//  NutriApp
//
//  Created by Mar Cabrera on 14/01/2020.
//  Copyright © 2020 Mar Cabrera. All rights reserved.
//

import Foundation

struct ProductEdamamResponse: Codable {
    let text: String
    let parsed: [Parsed]?
    let hints: [Hint]?

}

struct Hint: Codable {
    let food: HintFood?
}

struct HintFood: Codable {
    let foodID: String?
    let label: String?
    let brand: String?
    let nutrients: Nutrients?
    let category: Category?
    let categoryLabel: CategoryLabel?
    let foodContentsLabel: String?

    enum CodingKeys: String, CodingKey {
        case foodID = "foodId"
        case label, brand, nutrients, category, categoryLabel, foodContentsLabel
    }

    /// If the response of the API doesn't provide a brand, it'll show as 'Unknown'
    func getBrand() -> String {
        guard let _ = brand else {
            return "Unknown"
        }
        return brand!
    }
}

enum Category: String, Codable {
    case fastFoods = "Fast foods"
    case genericFoods = "Generic foods"
    case genericMeals = "Generic meals"
    case packagedFoods = "Packaged foods"
}

enum CategoryLabel: String, Codable {
    case food = "food"
    case meal = "meal"
}

struct Nutrients: Codable {
    let enercKcal: Double?
    let protein, fat: Double?
    let carbs: Double?

    var energyKcalRounded: Double {
        get { return getProperty(self.enercKcal?.rounded(toPlaces: 2)) }
    }

    var proteinRounded: Double {
        get { return getProperty(self.protein?.rounded(toPlaces: 2)) }
    }
    var fatRounded: Double {
        get { return getProperty(self.fat?.rounded(toPlaces: 2)) }
    }
    var carbsRounded: Double {
        get { return getProperty(self.carbs?.rounded(toPlaces: 2)) }
    }

    enum CodingKeys: String, CodingKey {
        case enercKcal = "ENERC_KCAL"
        case protein = "PROCNT"
        case fat = "FAT"
        case carbs = "CHOCDF"
    }
    // Sometimes API doesn't provide this information, so it will display 0 for user. 
    func getProperty(_ nutrient: Double?) -> Double {
        guard let _ = nutrient else {
            return 0
        }
        return  nutrient!
    }
}

struct Parsed: Codable {
    let food: ParsedFood?
}

struct ParsedFood: Codable {
    let foodID, label: String?
    let nutrients: Nutrients?
    let category: Category?
    let categoryLabel: CategoryLabel?

    enum CodingKeys: String, CodingKey {
        case foodID = "foodId"
        case label, nutrients, category, categoryLabel
    }
}



