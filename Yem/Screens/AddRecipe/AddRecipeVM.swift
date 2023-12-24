//
//  AddRecipeVM.swift
//  Yem
//
//  Created by Adam Zapiór on 09/12/2023.
//

import Combine
import Foundation
import UIKit

protocol AddRecipeViewModelDelegate: AnyObject {
    func reloadTable()
}

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
    
    /// Igredient sheet and vc variables
    @Published
    var ingredientsList: [IngredientModel] = [
        IngredientModel(id: 1, value: "100", valueType: "kg", name: "Milk"),
        IngredientModel(id: 2, value: "1", valueType: "kg", name: "Milk"),
        IngredientModel(id: 3, value: "20", valueType: "pounds", name: "Milk"),
        IngredientModel(id: 4, value: "13", valueType: "gram", name: "Milk"),
        IngredientModel(id: 5, value: "2", valueType: "count", name: "Milk")
    ]
    
    @Published
    var igredientName: String = ""
    
    @Published
    var igredientValue: String = ""
    
    @Published
    var igredientValueType: String = ""
    
    /// Error handling
    /// Recepies
    @Published
    var recipeTitleIsError: Bool = false
    
    @Published
    var difficultyIsError: Bool = false
    
    @Published
    var servingIsError: Bool = false
    
    @Published
    var perpTimeIsError: Bool = false
    
    @Published
    var spicyIsError: Bool = false
    
    @Published
    var categoryIsError: Bool = false
    
    /// Igredient
    @Published
    var igredientNameIsError: Bool = false
    
    @Published
    var igredientValueIsError: Bool = false
    
    @Published
    var igredientValueTypeIsError: Bool = false

    // MARK: Properties
    
    /// UIPickerView properties
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
    
    lazy var valueTypeArray: [String] = ["Unit", "Grams (g)", "Kilograms (kg)", "Milliliters (ml)", "Liters (L)", "Teaspoons (tsp)", "Tablespoons (Tbsp)", "Cups (c)", "Pinch"]
    
    // MARK: Initialization
    
    init() {}
    
    deinit {
        print("viewmodel out")
        print(recipeTitle)
        
        for items in ingredientsList {
            print(items.name)
        }
    }
    
    // MARK: Methods
    
    /// Validation
    
    private func validateRecipeTitle() {
        if recipeTitle.isEmpty {
            recipeTitleIsError = true
        }
    }
    
    private func validateDifficulty() {
        if difficulty.isEmpty {
            difficultyIsError = true
        }
    }
    
    private func validateServing() {
        if serving != 0 {
            servingIsError = true
        }
    }
    
    private func validatePerpTime() {
        if recipeTitle.isEmpty {
            recipeTitleIsError = true
        }
    }

    private func validateSpicy() {
        if spicy.isEmpty {
            spicyIsError = true
        }
    }

    private func validateCategory() {
        if category.isEmpty {
            categoryIsError = true
        }
    }
    
    private func validateForms() {
        validateRecipeTitle()
        validateDifficulty()
        validateServing()
        validatePerpTime()
        validateSpicy()
        validateCategory()
    }
    
    private func resetValidationFlags() {
        recipeTitleIsError = false
        difficultyIsError = false
        servingIsError = false
        perpTimeIsError = false
        spicyIsError = false
        categoryIsError = false
    }
    
    private func resetIgredientValidationFlags() {
        igredientNameIsError = false
        igredientValueIsError = false
        igredientValueTypeIsError = false
    }
    
    func addIngredientToList() -> Bool {
        resetIgredientValidationFlags()
        
        if perpTimeIsError || igredientValueIsError || igredientValueTypeIsError  {
            // TODO: push alert on VC
            // TODO: change item color
            return false
        }
        
        var ingredient = IngredientModel(id: Int64(), value: igredientValue, valueType: igredientValueType, name: igredientName)
        ingredientsList.append(ingredient)
        return true
    }
    
    func saveRecipe() {
        // Logika zapisu przepisu
    }
}

extension AddRecipeViewModel: AddRecipeViewModelDelegate {
    func reloadTable() {
        print("reload data")
    }
}
