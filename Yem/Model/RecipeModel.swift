//
//  RecipeModel.swift
//  Yem
//
//  Created by Adam Zapiór on 18/01/2024.
//

import Foundation

struct RecipeModel {
    var id: UUID
    var name: String
    var serving: String
    var perpTimeHours: String
    var perpTimeMinutes: String
    var spicy: RecipeSpicy
    var category: RecipeCategory
    var difficulty: RecipeDifficulty
    var ingredientList: [IngredientModel]
    var instructionList: [InstructionModel]
    var isImageSaved: Bool
    var isFavourite: Bool
}

enum RecipeSpicy: String, CaseIterable {
    case mild = "Mild"
    case medium = "Medium"
    case hot = "Hot"
    case veryHot = "Very hot"

    var displayName: String {
        return rawValue
    }
}

enum RecipeCategory: String, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case vegan = "Vegan"
    case vegetarian = "Vegetarian"
    case desserts = "Desserts"
    case snacks = "Snacks"
    case beverages = "Beverages"
    case appetizers = "Appetizers"
    case sideDishes = "Side Dishes"
    case notSelected = "Not selected"

    var displayName: String {
        return rawValue
    }
}

enum RecipeDifficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hot = "Hard"

    var displayName: String {
        return rawValue
    }
}

extension RecipeModel {
    static var servingRowArray: [Int] {
        return Array(1...36)
    }

    static var timeHoursArray: [Int] {
        return Array(0...48)
    }

    static var timeMinutesArray: [Int] {
        return Array(0...59)
    }
}

extension RecipeModel {
    mutating func sortInstructionsByIndex() {
        instructionList.sort { $0.index < $1.index }
    }
}

extension RecipeModel {
    func getPerpTimeString() -> String {
        var perpTimeString = ""
        var hours = ""
        var minutes = ""

        if perpTimeHours != "0", perpTimeHours != "1", perpTimeHours != "" {
            hours = "\(perpTimeHours) hours"
        } else if perpTimeHours == "1" {
            hours = "\(perpTimeHours) hour"
        }

        if perpTimeMinutes != "0", perpTimeMinutes != "" {
            minutes = "\(perpTimeMinutes) min"
        }

        perpTimeString = "\(hours) \(minutes)".trimmingCharacters(in: .whitespaces)
        return perpTimeString
    }
}
