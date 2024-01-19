//
//  AddRecipeVM.swift
//  Yem
//
//  Created by Adam Zapiór on 09/12/2023.
//

import Combine
import CoreData
import Foundation
import UIKit

protocol AddRecipeViewModelDelegate: AnyObject {
    func updateEditButtonVisibility(isEmpty: Bool)
    func reloadTable()
    func pushAlert()
}

class AddRecipeViewModel {
    weak var delegate: AddRecipeViewModelDelegate?
    var repository: DataRepository
    
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
    var ingredientsList: [IngredientModel] = [IngredientModel(id: UUID(), value: "100", valueType: "Grams (g)", name: "Sugar"),
                                              IngredientModel(id: UUID(), value: "100", valueType: "Grams (g)", name: "Sugar")]
    {
        didSet {
            reloadTable()
        }
    }
    
    @Published
    var igredientName: String = ""
    
    @Published
    var igredientValue: String = ""
    
    @Published
    var igredientValueType: String = ""
    
    @Published
    var instructionList: [InstructionModel] = [
        InstructionModel(index: 1, text: "testoweanko alsldlasldls"),
//                                               InstructionModel(index: 2, text: "hardkor")
    ]
    
    /// Error handling
    /// Recepies
    @Published
    var recipeTitleIsError: Bool = false {
        didSet {
            if recipeTitleIsError == true {
                delegate?.pushAlert()
            }
        }
    }
    
    @Published
    var difficultyIsError: Bool = false {
        didSet {
            if difficultyIsError == true {
                delegate?.pushAlert()
            }
        }
    }
    
    @Published
    var servingIsError: Bool = false {
        didSet {
            if servingIsError == true {
                delegate?.pushAlert()
            }
        }
    }
    
    @Published
    var perpTimeIsError: Bool = false {
        didSet {
            if perpTimeIsError == true {
                delegate?.pushAlert()
            }
        }
    }
    
    @Published
    var spicyIsError: Bool = false {
        didSet {
            if spicyIsError == true {
                delegate?.pushAlert()
            }
        }
    }
    
    @Published
    var categoryIsError: Bool = false {
        didSet {
            if categoryIsError == true {
                delegate?.pushAlert()
            }
        }
    }
    
    /// Igredient
    @Published
    var igredientNameIsError: Bool = false
    
    @Published
    var igredientValueIsError: Bool = false
    
    @Published
    var igredientValueTypeIsError: Bool = false
    
    /// validation used for validate all recipe
    @Published
    var validationErrors: [ValidateRecipeErrors] = []

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
    
    init(repository: DataRepository) {
        self.repository = repository
    }
    
    deinit {
        print("AddRecipe viewmodel deinit")
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
        if serving == 0 {
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
    
    private func validateIgredientName() {
        if igredientName.isEmpty {
            igredientNameIsError = true
        }
    }
    
    private func validateIgredientValue() {
        if igredientValue.isEmpty {
            igredientValueIsError = true
        }
    }
    
    private func validateIgredientValueType() {
        if igredientValueType.isEmpty {
            igredientValueTypeIsError = true
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
    
    private func validateIngredientForm() {
        validateIgredientName()
        validateIgredientValue()
        validateIgredientValueType()
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
        
        validateIngredientForm()
        
        if igredientNameIsError || igredientValueIsError || igredientValueTypeIsError {
            // TODO: push alert on VC
            // TODO: change item color
            return false
        }
        
        let ingredient = IngredientModel(id: UUID(), value: igredientValue, valueType: igredientValueType, name: igredientName)
        ingredientsList.append(ingredient)
        return true
    }
    
    func removeIngredientFromList(at index: Int) {
        ingredientsList.remove(at: index)
    }
        
    func saveRecipe() -> Bool {
        resetValidationFlags()
        validateForms()
        
//        if recipeTitleIsError || servingIsError {
//            pushAlert()
//            return false
//        }
        
        let recipe = RecipeModel(id: UUID(),
                                 name: recipeTitle,
                                 serving: serving.description,
                                 perpTimeHours: prepTimeHours,
                                 perpTimeMinutes: prepTimeMinutes,
                                 spicy: spicy,
                                 category: category,
                                 difficulty: difficulty,
                                 ingredientList: ingredientsList,
                                 instructionList: instructionList)
        
        repository.addRecipe(recipe: recipe)
        repository.save()
        print("New recipe saved")
        return true
    }
}

extension AddRecipeViewModel: AddRecipeViewModelDelegate {
    func pushAlert() {
        DispatchQueue.main.async {
            self.delegate?.pushAlert()
        }
    }
    
    func updateEditButtonVisibility(isEmpty: Bool) {
        delegate?.updateEditButtonVisibility(isEmpty: isEmpty)
    }
    
    func reloadTable() {
        DispatchQueue.main.async {
            self.delegate?.reloadTable()
        }
    }
    
    // TODO: push to previous viewcontroller and clear data in textfields or something
}

// TODO: add validate errors

enum ValidateRecipeErrors: CustomStringConvertible {
    case recipeTitle
    case difficulty
    case serving
    case prepTime
    case spicy
    case category
    case ingredientsList

    var description: String {
        switch self {
        case .recipeTitle:
            return ""
        case .difficulty:
            return ""
        case .serving:
            return ""
        case .prepTime:
            return ""
        case .spicy:
            return ""
        case .category:
            return ""
        case .ingredientsList:
            return ""
        }
    }
}
