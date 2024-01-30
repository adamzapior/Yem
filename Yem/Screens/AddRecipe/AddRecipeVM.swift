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

protocol AddRecipeVCDelegate: AnyObject {
    func delegateDetailsError(_ type: ValidationErrorTypes)
}

protocol AddRecipeIngredientsVCDelegate: AnyObject {
    func reloadIngredientsTable()
}

protocol AddIngredientSheetVCDelegate: AnyObject {
    func delegateIngredientError(_ type: ValidationErrorTypes)
}

protocol AddRecipeInstructionsVCDelegate: AnyObject {
    func reloadInstructionTable()
}

protocol AddInstructionSheetVCDelegate: AnyObject {
    func delegateInstructionError(_ type: ValidationErrorTypes)
}

final class AddRecipeViewModel {
    var repository: DataRepository
    
    weak var delegateDetails: AddRecipeVCDelegate?
    weak var delegateIngredients: AddRecipeIngredientsVCDelegate?
    weak var delegateIngredientSheet: AddIngredientSheetVCDelegate?
    weak var delegateInstructions: AddRecipeInstructionsVCDelegate?
    weak var delegateInstructionSheet: AddInstructionSheetVCDelegate?
        
    // MARK: - Observable properties
    
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
    var ingredientsList: [IngredientModel] = [IngredientModel(id: UUID(), value: "12", valueType: "12", name: "12")] {
        didSet {
            reloadIngredientsTable()
        }
    }
    
    @Published
    var igredientName: String = ""
    
    @Published
    var igredientValue: String = ""
    
    @Published
    var igredientValueType: String = ""
    
    @Published
    var instructionList: [InstructionModel] = [] {
        didSet {
            reloadInstructionTable()
        }
    }
    
    @Published
    var instruction: String = ""
    
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
    
    @Published
    var ingredientListIsError: Bool = false
    
    @Published
    var instructionIsError: Bool = false
    
    @Published
    var instructionListIsError: Bool = false
    
    /// validation used for validate all recipe
    @Published
    var validationErrors: [ValidateRecipeErrors] = []

    // MARK: - Properties
    
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
    
    // MARK: - Initialization
    
    init(repository: DataRepository) {
        self.repository = repository
    }
    
    deinit {
        print("AddRecipe viewmodel deinit")
        print(instruction)
    }
    
    // MARK: - Public methods
    
    /// Add methods:

    func addIngredientToList() -> Bool {
        validationErrors = []
        resetIgredientValidationFlags()
        validateIngredientForm()
        
        if igredientNameIsError || igredientValueIsError || igredientValueTypeIsError {
            return false
        }
        
        let ingredient = IngredientModel(id: UUID(), value: igredientValue, valueType: igredientValueType, name: igredientName)
        ingredientsList.append(ingredient)
        clearIngredientProperties()
        return true
    }
    
    func addInstructionToList() -> Bool {
        validationErrors = []
        resetValidationFlags()
        validateInstruction()
        
        if instructionIsError {
            return false
        }
        
        let count = instructionList.count
        let index = count + 1
        let instruction = InstructionModel(index: index, text: instruction)
        instructionList.append(instruction)
        clearInstructionProperties()
        return true
    }
    
    /// Update method:

    func updateInstructionIndexes() {
        for (index, var instruction) in instructionList.enumerated() {
            instruction.index = index + 1
            instructionList[index] = instruction
        }
    }
    
    func clearIngredientProperties() {
        igredientName = ""
        igredientValue = ""
        igredientValueType = ""
    }
    
    func clearInstructionProperties() {
        instruction = ""
    }

    /// Delete methods:
    
    func removeIngredientFromList(at index: Int) {
        ingredientsList.remove(at: index)
    }
    
    func removeInstructionFromList(at index: Int) {
        instructionList.remove(at: index)
    }
    
    /// Save method:
    
    func saveRecipe() -> Bool {
        validationErrors = []
        resetValidationFlags()
        resetIgredientValidationFlags()
        resetInstructionValidationFlags()
        validateForms()
        
        if recipeTitleIsError || servingIsError || difficultyIsError || perpTimeIsError || spicyIsError || categoryIsError {
            return false
        }
        
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
    
    // MARK: - Private methods
    
    /// Validation
    
    private func validateRecipeTitle() {
        if recipeTitle.isEmpty {
            recipeTitleIsError = true
            validationErrors.append(.recipeTitle)
            delegateDetailsError(.recipeTitle)
            print("called")
        }
    }
    
    private func validateDifficulty() {
        if difficulty.isEmpty {
            difficultyIsError = true
            validationErrors.append(.difficulty)
            delegateDetailsError(.difficulty)
        }
    }
    
    private func validateServing() {
        if serving == 0 {
            servingIsError = true
            validationErrors.append(.serving)
            delegateDetailsError(.servings)
        }
    }
    
    // TODO: fix
    private func validatePerpTime() {
        if recipeTitle.isEmpty {
            recipeTitleIsError = true
            validationErrors.append(.prepTime)
            delegateDetailsError(.prepTime)
        }
    }

    private func validateSpicy() {
        if spicy.isEmpty {
            spicyIsError = true
            validationErrors.append(.spicy)
            delegateDetailsError(.spicy)
        }
    }

    private func validateCategory() {
        if category.isEmpty {
            categoryIsError = true
            validationErrors.append(.category)
            delegateDetailsError(.category)
        }
    }
    
    private func validateIgredientName() {
        if igredientName.isEmpty {
            igredientNameIsError = true
            delegateDetailsError(.ingredientName)
        }
    }
    
    private func validateIgredientValue() {
        if igredientValue.isEmpty {
            igredientValueIsError = true
            delegateDetailsError(.ingredientValue)
        }
    }
    
    private func validateIgredientValueType() {
        if igredientValueType.isEmpty {
            igredientValueTypeIsError = true
            delegateDetailsError(.ingredientValueType)
        }
    }
    
    private func validateIngredientList() {
        if ingredientsList.isEmpty {
            ingredientListIsError = true
            validationErrors.append(.ingredientsList)
        }
    }
    
    private func validateInstruction() {
        if instruction.isEmpty {
            instructionIsError = true
            delegateInstructionError(.instruction)
        }
    }
    
    private func validateInstructionList() {
        if instructionList.isEmpty {
            instructionListIsError = true
            validationErrors.append(.instructionList)
        }
    }
    
    private func validateForms() {
        validateRecipeTitle()
        validateDifficulty()
        validateServing()
        validatePerpTime()
        validateSpicy()
        validateCategory()
        validateIngredientList()
        validateInstructionList()
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
        ingredientListIsError = false
        instructionListIsError = false
    }
    
    private func resetIgredientValidationFlags() {
        igredientNameIsError = false
        igredientValueIsError = false
        igredientValueTypeIsError = false
    }
    
    private func resetInstructionValidationFlags() {
        instructionIsError = false
        instructionListIsError = false
    }
}

// MARK: - Delegate methods

extension AddRecipeViewModel: AddRecipeVCDelegate {
    func delegateDetailsError(_ type: ValidationErrorTypes) {
        DispatchQueue.main.async {
            self.delegateDetails?.delegateDetailsError(type)
        }
    }
}

extension AddRecipeViewModel: AddRecipeIngredientsVCDelegate {
    func reloadIngredientsTable() {
        DispatchQueue.main.async {
            self.delegateIngredients?.reloadIngredientsTable()
        }
    }
}

extension AddRecipeViewModel: AddIngredientSheetVCDelegate {
    func delegateIngredientError(_ type: ValidationErrorTypes) {
        DispatchQueue.main.async {
            self.delegateIngredientSheet?.delegateIngredientError(type)
        }
    }
}

extension AddRecipeViewModel: AddRecipeInstructionsVCDelegate {
    func reloadInstructionTable() {
        DispatchQueue.main.async {
            self.delegateInstructions?.reloadInstructionTable()
        }
    }
}

extension AddRecipeViewModel: AddInstructionSheetVCDelegate {
    func delegateInstructionError(_ type: ValidationErrorTypes) {
        DispatchQueue.main.async {
            self.delegateInstructionSheet?.delegateInstructionError(type)
        }
    }
}

// MARK: - Enums

enum ValidateRecipeErrors: CustomStringConvertible {
    case recipeTitle
    case difficulty
    case serving
    case prepTime
    case spicy
    case category
    case ingredientName
    case ingredientValue
    case ingredientValueType
    case ingredientsList
    case instruction
    case instructionList

    var description: String {
        switch self {
        case .recipeTitle:
            return "Recipe title is required."
        case .difficulty:
            return "Invalid difficulty level selected."
        case .serving:
            return "Number of servings must be specified."
        case .prepTime:
            return "Invalid preparation time format."
        case .spicy:
            return "Spiciness level must be specified."
        case .category:
            return "Recipe category is required."
        case .ingredientName:
            return "Ingredient name is required."
        case .ingredientValue:
            return "Ingredient value must be specified."
        case .ingredientValueType:
            return "Ingredient value type must be specified."
        case .ingredientsList:
            return "At least one ingredient is required."
        case .instruction:
            return "Invalid instruction provided."
        case .instructionList:
            return "At least one instruction is required."
        }
    }
}

enum ValidationErrorTypes {
    case recipeTitle
    case difficulty
    case servings
    case prepTime
    case spicy
    case category
    case ingredientName
    case ingredientValue
    case ingredientValueType
    case instruction
}
