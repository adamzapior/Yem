//
//  AddRecipeVM.swift
//  Yem
//
//  Created by Adam Zapiór on 09/12/2023.
//

import Combine
import Foundation
import UIKit

class AddRecipeViewModel {
    
    // MARK: Observable properties
    
    @Published
    var recipeTitle: String = ""
    
    @Published
    var difficulty: String = ""
    
    @Published
    var serving: Int = 0
    
    @Published
    var prepTimeHours: String = ""
    
    @Published
    var prepTimeMinutes: String = ""
    
    @Published
    var spicy: String = ""
    
    @Published
    var category: String = ""
    
    @Published
    var ingredientsList: [IngredientModel] = [
        IngredientModel(id: 1, value: "100", valueType: "kg", name: "Milk"),
        IngredientModel(id: 2, value: "1", valueType: "kg", name: "Milk"),
        IngredientModel(id: 3, value: "20", valueType: "pounds", name: "Milk"),
        IngredientModel(id: 4, value: "13", valueType: "gram", name: "Milk"),
        IngredientModel(id: 5, value: "2", valueType: "count", name: "Milk")
    ]
    
    // MARK: Properties
    
    var difficultyRowArray: [String] = ["Easy", "Medium", "Hard"]
    
    lazy var servingRowArray: [Int] = {
        var array: [Int] = []
        for i in 1...36 {
            array.append(i)
        }
        return array
    }()
    
    lazy var timeHoursArray: [Int] = {
        var array: [Int] = []
        for i in 0...48 {
            array.append(i)
        }
        return array
    }()
    
    lazy var timeMinutesArray: [Int] = {
        var array: [Int] = []
        for i in 0...59 {
            array.append(i)
        }
        return array
    }()
    
    lazy var spicyRowArray: [String] = ["Mild", "Medium", "Hot", "Very hot"]
    
    lazy var categoryRowArray: [String] = ["Breakfast", "Lunch", "Dinner", "Desserts", "Snacks", "Beverages", "Appetizers", "Side Dishes", "Vegan", "Vegetarian"]
    
    // MARK: Initialization
    
    init() {}
    
    deinit {
        print("viewmodel out")
        print(recipeTitle)
    }
    
    // MARK: Methods
    
    func saveRecipe() {
        // Logika zapisu przepisu
    }
}
