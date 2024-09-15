//
//  RecipeCategoryModel.swift
//  Yem
//
//  Created by Adam Zapiór on 15/09/2024.
//

import Foundation

struct RecipeCategoryModel: Hashable {
    let value: String
    var displayName: String { value }

    static let breakfast = RecipeCategoryModel(value: "Breakfast")
    static let lunch = RecipeCategoryModel(value: "Lunch")
    static let dinner = RecipeCategoryModel(value: "Dinner")
    static let vegan = RecipeCategoryModel(value: "Vegan")
    static let vegetarian = RecipeCategoryModel(value: "Vegetarian")
    static let desserts = RecipeCategoryModel(value: "Desserts")
    static let snacks = RecipeCategoryModel(value: "Snacks")
    static let beverages = RecipeCategoryModel(value: "Beverages")
    static let appetizers = RecipeCategoryModel(value: "Appetizers")
    static let sideDishes = RecipeCategoryModel(value: "Side Dishes")
    static let notSelected = RecipeCategoryModel(value: "Not selected")

    static let allCases: [RecipeCategoryModel] = [.breakfast, .lunch, .dinner, .vegan, .vegetarian, .desserts, .snacks, .beverages, .appetizers, .sideDishes, .notSelected]
}
