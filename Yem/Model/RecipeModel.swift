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
        return self.rawValue
    }
}

enum RecipeCategory: String, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case desserts = "Desserts"
    case snacks = "Snacks"
    case beverages = "Beverages"
    case appetizers = "Appetizers"
    case sideDishes = "Side Dishes"
    case vegan = "Vegan"
    case vegetarian = "Vegetarian"
    case none = "Not selected" // used only to handle potencial errors in map method

    var displayName: String {
        return self.rawValue
    }
}

enum RecipeDifficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hot = "Hard"

    var displayName: String {
        return self.rawValue
    }
}
