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
    var spicy: String
    var category: String
    var difficulty: String
    var ingredientList: [IngredientModel]
    var instructionList: [InstructionModel]
    var isImageSaved: Bool
}


enum RecipeCategory: String {
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
}

//lazy var categoryRowArray: [String] = ["Breakfast", "Lunch", "Dinner", "Desserts", "Snacks", "Beverages", "Appetizers", "Side Dishes", "Vegan", "Vegetarian"]
