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
    func delegateError(_ type: ValidationErrorTypes)
    func reloadTable()
}

final class AddRecipeViewModel {
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
        InstructionModel(index: 1, text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus nec placerat sem. Morbi eget turpis tincidunt, porttitor odio id, dignissim ante. Aenean id viverra tortor. Cras vehicula sapien sed nisl mattis scelerisque. "),
        InstructionModel(index: 2, text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus nec placerat sem. Morbi eget turpis tincidunt, porttitor odio id, dignissim ante. Aenean id viverra tortor. Cras vehicula sapien sed nisl mattis scelerisque. Proin aliquam mi eros, sit amet ultricies lorem convallis nec. Nulla nec ante ornare nisl interdum lobortis. Vivamus varius accumsan metus in pellentesque. Sed ac nunc odio. Cras quis mauris porta, varius quam ut, ultricies ante. Integer ornare molestie mauris, vitae faucibus justo sollicitudin at. Quisque eget lacinia magna."),
        InstructionModel(index: 3, text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus nec pr odio id, dignissim ante. Aenean id viverra tortor. Cras vehicula sapien sed nisl mattis scelerisque. ")
    ]
    
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
    
    func addIngredientToList() -> Bool {
        validationErrors = []
        resetIgredientValidationFlags()
        validateIngredientForm()
        
        if igredientNameIsError || igredientValueIsError || igredientValueTypeIsError {
            return false
        }
        
        let ingredient = IngredientModel(id: UUID(), value: igredientValue, valueType: igredientValueType, name: igredientName)
        ingredientsList.append(ingredient)
        return true
    }
    
    func removeIngredientFromList(at index: Int) {
        ingredientsList.remove(at: index)
    }
    
    func updateInstructionIndexes() {
        for (index, var instruction) in instructionList.enumerated() {
            instruction.index = index + 1
            instructionList[index] = instruction
        }
    }
    
    func removeInstructionFromList(at index: Int) {
        instructionList.remove(at: index)
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
        delegate?.reloadTable()
        return true
    }

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
    
    /// Validation
    
    private func validateRecipeTitle() {
        if recipeTitle.isEmpty {
            recipeTitleIsError = true
            validationErrors.append(.recipeTitle)
            delegateError(.recipeTitle)
        }
    }
    
    private func validateDifficulty() {
        if difficulty.isEmpty {
            difficultyIsError = true
            validationErrors.append(.difficulty)
        }
    }
    
    private func validateServing() {
        if serving == 0 {
            servingIsError = true
            validationErrors.append(.serving)
        }
    }
    
    private func validatePerpTime() {
        if recipeTitle.isEmpty {
            recipeTitleIsError = true
            validationErrors.append(.prepTime)
        }
    }

    private func validateSpicy() {
        if spicy.isEmpty {
            spicyIsError = true
            validationErrors.append(.spicy)
        }
    }

    private func validateCategory() {
        if category.isEmpty {
            categoryIsError = true
            validationErrors.append(.category)
        }
    }
    
    private func validateIgredientName() {
        if igredientName.isEmpty {
            igredientNameIsError = true
            validationErrors.append(.ingredientName)
        }
    }
    
    private func validateIgredientValue() {
        if igredientValue.isEmpty {
            igredientValueIsError = true
            validationErrors.append(.ingredientValue)
        }
    }
    
    private func validateIgredientValueType() {
        if igredientValueType.isEmpty {
            igredientValueTypeIsError = true
            validationErrors.append(.ingredientValueType)
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
            validationErrors.append(.instruction)
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

extension AddRecipeViewModel: AddRecipeViewModelDelegate {
    func reloadTable() {
        Dispatch.DispatchQueue.main.async {
            self.delegate?.reloadTable()
        }
    }

    func delegateError(_ type: ValidationErrorTypes) {
        DispatchQueue.main.async {
            self.delegate?.delegateError(type)
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
    case ingredientsList
    case instruction
    case instructionList
}
