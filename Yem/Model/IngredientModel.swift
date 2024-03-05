//
//  IngridientModel.swift
//  Yem
//
//  Created by Adam Zapiór on 09/12/2023.
//

import Foundation

struct IngredientModel {
    var id: UUID
    var value: String
    var valueType: String
    var name: String
}

enum IngredientValueType: String, CaseIterable {
    case unit = "Unit"
    case grams = "Grams (g)"
    case kilograms = "Kilograms (kg)"
    case milliliters = "Milliliters (ml)"
    case liters = "Liters (L)"
    case teaspoons = "Teaspoons (tsp)"
    case tablespoons = "Tablespoons (Tbsp)"
    case cups = "Cups (c)"
    case pinch = "Pinch"

    var displayName: String {
        return self.rawValue
    }
}
