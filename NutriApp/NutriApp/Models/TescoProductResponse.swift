//
//  ProductResponse.swift
//  NutriApp
//
//  Created by Mar Cabrera on 18/10/2019.
//  Copyright © 2019 Mar Cabrera. All rights reserved.
//

import Foundation

struct TescoProductResponse: Codable {
    let products: [Product]
}

struct Product: Codable {
    let productDescription: String?
    let brand: String?
    let productCharacteristics: ProductCharacteristics?
    let calcNutrition: CalcNutrition?

    enum CodingKeys: String, CodingKey {
        case productDescription = "description"
        case brand, productCharacteristics, calcNutrition
    }
}

struct ProductCharacteristics: Codable {
    let isFood: Bool?
    let isDrink: Bool?
    let healthScore: Int?
}

struct CalcNutrition: Codable {
    let per100Header: String?
    let perServingHeader: String?
    let calcNutrients: [CalcNutrient]?
}

struct CalcNutrient: Codable {
    let name: String?
    let valuePer100: String?
    let valuePerServing: String?
}
