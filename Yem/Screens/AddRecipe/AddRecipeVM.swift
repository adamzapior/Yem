//
//  AddRecipeVM.swift
//  Yem
//
//  Created by Adam Zapiór on 09/12/2023.
//

import Combine
import CoreData
import Foundation
import Kingfisher
import LifetimeTracker
import UIKit

protocol AddRecipeVCDelegate: AnyObject {
    func loadDataToEditor()
    func delegateDetailsError(_ type: ValidationErrorTypes)
}

protocol AddRecipeIngredientsVCDelegate: AnyObject {
    func reloadIngredientsTable()
    func delegateIngredientsError(_ type: ValidationErrorTypes)
}

protocol AddIngredientSheetVCDelegate: AnyObject {
    func delegateIngredientSheetError(_ type: ValidationErrorTypes)
}

protocol AddRecipeInstructionsVCDelegate: AnyObject {
    func reloadInstructionTable()
    func delegateInstructionsError(_ type: ValidationErrorTypes)
}

protocol AddInstructionSheetVCDelegate: AnyObject {
    func delegateInstructionError(_ type: ValidationErrorTypes)
}

final class AddRecipeViewModel {
    var repository: DataRepositoryProtocol
    let localFileManager: LocalFileManagerProtocol
    let imageFetcherManager: ImageFetcherManagerProtocol
    
    weak var delegateDetails: AddRecipeVCDelegate?
    weak var delegateIngredients: AddRecipeIngredientsVCDelegate?
    weak var delegateIngredientSheet: AddIngredientSheetVCDelegate?
    weak var delegateInstructions: AddRecipeInstructionsVCDelegate?
    weak var delegateInstructionSheet: AddInstructionSheetVCDelegate?
        
    // MARK: - Observable properties
    
    /// Recipe properties
    var recipeID: UUID = .init()
    
    var selectedImage: UIImage?
    
    @Published var recipeTitle: String = ""
    
    @Published var difficulty: String = ""
    
    @Published var serving: String = ""
    
    @Published var prepTimeHours: String = ""
    
    @Published var prepTimeMinutes: String = ""
    
    @Published var spicy: String = ""
    
    @Published var category: String = ""
    
    var ingredientsList: [IngredientModel] = [] {
        didSet {
            reloadIngredientsTable()
        }
    }
    
    @Published var ingredientName: String = ""
    
    @Published var ingredientValue: String = ""
    
    @Published var ingredientValueType: String = ""
    
    var instructionList: [InstructionModel] = [] {
        didSet {
            reloadInstructionTable()
        }
    }
    
    @Published var instruction: String = ""
    
    var isFavourite: Bool = false
    
    /// Error handling
    var recipeTitleIsError: Bool = false
    
    var difficultyIsError: Bool = false
    
    var servingIsError: Bool = false
    
    var prepTimeIsError: Bool = false
    
    var spicyIsError: Bool = false
    
    var categoryIsError: Bool = false
    
    var ingredientNameIsError: Bool = false
    
    var ingredientValueIsError: Bool = false
    
    var ingredientValueTypeIsError: Bool = false
    
    var ingredientListIsError: Bool = false
    
    var instructionIsError: Bool = false
    
    var instructionListIsError: Bool = false
    
    var validationErrors: [ValidateRecipeErrors] = []

    // MARK: - Properties
        
    var servingRowArray: [Int] {
        return RecipeModel.servingRowArray
    }

    var timeHoursArray: [Int] {
        return RecipeModel.timeHoursArray
    }

    var timeMinutesArray: [Int] {
        return RecipeModel.timeMinutesArray
    }
    
    var spicyRowArray: [RecipeSpicy] = RecipeSpicy.allCases
    
    var categoryRowArray: [RecipeCategory] = RecipeCategory.allCases
    
    var difficultyRowArray: [RecipeDifficulty] = RecipeDifficulty.allCases
    
    var ingredientValueTypeArray: [IngredientValueType] = IngredientValueType.allCases
    
    var didRecipeExist: Bool = false
    
    // MARK: - Initialization
    
    init(
        repository: DataRepositoryProtocol,
        localFileManager: LocalFileManagerProtocol,
        imageFetcherManager: ImageFetcherManagerProtocol,
        existingRecipe: RecipeModel? = nil
    ) {
        self.repository = repository
        self.localFileManager = localFileManager
        self.imageFetcherManager = imageFetcherManager
        
        if let recipe = existingRecipe {
            loadRecipeData(recipe)
            didRecipeExist = true
            print("DEBUG: loadRecipeData called with existing recipe")
        } else {
            print("DEBUG: existingRecipe is nil")
        }
        
#if DEBUG
        trackLifetime()
#endif
    }
    
    // MARK: - Public methods
    
    /// Add methods:

    func addIngredientToList() -> Bool {
        resetIngredientValidationFlags()
        
        validateIgredientName()
        validateIgredientValue()
        validateIgredientValueType()
        
        if ingredientNameIsError || ingredientValueIsError || ingredientValueTypeIsError {
            return false
        }
        
        let ingredient = IngredientModel(id: UUID(), value: ingredientValue, valueType: ingredientValueType, name: ingredientName)
        ingredientsList.append(ingredient)
        clearIngredientProperties()
        return true
    }
    
    func addInstructionToList() -> Bool {
        resetInstructionValidationFlags()
        validateInstruction()
        
        if instructionIsError {
            return false
        }
        
        let count = instructionList.count
        let index = count + 1
        let instruction = InstructionModel(id: UUID(), index: index, text: instruction)
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

    /// Delete methods:
    
    func removeIngredientFromList(at index: Int) {
        guard index >= 0, index < ingredientsList.count else { return }
        ingredientsList.remove(at: index)
    }

    func removeInstructionFromList(at index: Int) {
        guard index >= 0, index < instructionList.count else { return }
        instructionList.remove(at: index)
    }
    
    func doesRecipeExist(id: UUID) -> Bool {
        return repository.doesRecipeExist(with: id)
    }
    
    /// Validation and save methods:
    
    func hasRecipeValidationErrors() -> Bool {
        return recipeTitleIsError || servingIsError || difficultyIsError || prepTimeIsError || spicyIsError || categoryIsError || ingredientListIsError || instructionListIsError
    }

    func saveRecipe() -> Bool {
        validationErrors = []
        validateForms()

        if hasRecipeValidationErrors() {
            print("DEBUG: Recipe validation failed")
            return false
        }
        
        let doesExist = doesRecipeExist(id: recipeID)
        print("DEBUG: Does recipe exist? \(doesExist)")

        return doesRecipeExist(id: recipeID) ? upsertRecipe(isUpdate: true) : upsertRecipe(isUpdate: false)
    }

    // MARK: - Private methods
    
    /// Load recipe if exsists - method usued when ViewModel is initializated by editing recipe
    private func loadRecipeData(_ recipe: RecipeModel) {
        recipeID = recipe.id
        recipeTitle = recipe.name
        serving = recipe.serving
        prepTimeHours = recipe.perpTimeHours
        prepTimeMinutes = recipe.perpTimeMinutes
        spicy = recipe.spicy.displayName
        category = recipe.category.displayName
        difficulty = recipe.difficulty.displayName
        ingredientsList = recipe.ingredientList
        instructionList = recipe.instructionList
        isFavourite = recipe.isFavourite
        
        instructionList.sort { $0.index < $1.index }
        
        if recipe.isImageSaved {
            let imageUrl = localFileManager.imageUrl(for: recipe.id.uuidString)
            
            guard let validImageUrl = imageUrl else {
                return
            }
            
            imageFetcherManager.fetchImage(from: validImageUrl) { [weak self] image in
                guard let self = self else { return }
                if let fetchedImage = image {
                    self.selectedImage = fetchedImage
                } else {}
            }
        }
    }

    private func upsertRecipe(isUpdate: Bool) -> Bool {
        repository.beginTransaction()

        let isImageSaved = selectedImage != nil
        let recipe = RecipeModel(id: recipeID,
                                 name: recipeTitle,
                                 serving: serving.description,
                                 perpTimeHours: prepTimeHours,
                                 perpTimeMinutes: prepTimeMinutes,
                                 spicy: RecipeSpicy(rawValue: spicy) ?? .medium,
                                 category: RecipeCategory(rawValue: category) ?? .notSelected,
                                 difficulty: RecipeDifficulty(rawValue: difficulty) ?? .medium,
                                 ingredientList: ingredientsList,
                                 instructionList: instructionList,
                                 isImageSaved: isImageSaved,
                                 isFavourite: isFavourite)

        if let image = selectedImage {
            let imageSaved = localFileManager.saveImage(with: recipeID.uuidString, image: image)
            if !imageSaved {
                repository.rollbackTransaction()
                return false
            }
        }

        if isUpdate {
            repository.updateRecipe(recipe: recipe)
        } else {
            repository.addRecipe(recipe: recipe)
        }

        if !repository.save() {
            if isImageSaved {
                localFileManager.deleteImage(with: recipeID.uuidString)
            }
            repository.rollbackTransaction()
            return false
        }

        repository.endTransaction()
        print("DEBUG: Recipe \(isUpdate ? "updated" : "saved") successfully")
        return true
    }
    
    /// Prepare variables to reuse (ingredient & instruction)
    
    private func clearIngredientProperties() {
        ingredientName = ""
        ingredientValue = ""
        ingredientValueType = ""
    }
    
    private func clearInstructionProperties() {
        instruction = ""
    }

    /// Validation
    
    private func validateRecipeTitle() {
        if recipeTitle.isEmpty {
            recipeTitleIsError = true
            validationErrors.append(.recipeTitle)
            delegateDetailsError(.recipeTitle)
        }
    }

    private func validateDifficulty() {
        if difficulty.isEmpty || !difficultyRowArray.contains(where: { $0.displayName == difficulty }) {
            difficultyIsError = true
            validationErrors.append(.difficulty)
            delegateDetailsError(.difficulty)
        }
    }
    
    private func validateServing() {
        if serving.isEmpty || !servingRowArray.contains(where: { $0.description == serving }) {
            servingIsError = true
            validationErrors.append(.serving)
            delegateDetailsError(.servings)
        }
    }
    
    private func validatePerpTime() {
        if prepTimeHours.isEmpty, prepTimeMinutes.isEmpty {
            recipeTitleIsError = true
            validationErrors.append(.prepTime)
            delegateDetailsError(.prepTime)
        }
    }

    private func validateSpicy() {
        if spicy.isEmpty || !spicyRowArray.contains(where: { $0.displayName == spicy }) {
            spicyIsError = true
            validationErrors.append(.spicy)
            delegateDetailsError(.spicy)
        }
    }
    
    private func validateCategory() {
        if category.isEmpty || !categoryRowArray.contains(where: { $0.displayName == category }) {
            categoryIsError = true
            validationErrors.append(.category)
            delegateDetailsError(.category)
        }
    }
    
    private func validateIgredientName() {
        if ingredientName.isEmpty {
            ingredientNameIsError = true
            delegateIngredientSheetError(.ingredientName)
        }
    }
    
    private func validateIgredientValue() {
        if ingredientValue.isEmpty {
            ingredientValueIsError = true
            delegateIngredientSheetError(.ingredientValue)
        }
    }
    
    private func validateIgredientValueType() {
        if ingredientValueType.isEmpty {
            ingredientValueTypeIsError = true
            delegateIngredientSheetError(.ingredientValueType)
        }
    }
    
    private func validateIngredientList() {
        if ingredientsList.isEmpty {
            ingredientListIsError = true
            validationErrors.append(.ingredientsList)
            delegateIngredientsError(.ingredientList)
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
            delegateInstructionsError(.instructionList)
        }
    }
    
    private func validateForms() {
        recipeTitleIsError = false
        difficultyIsError = false
        servingIsError = false
        prepTimeIsError = false
        spicyIsError = false
        categoryIsError = false
        ingredientListIsError = false
        instructionListIsError = false
        
        validateRecipeTitle()
        validateDifficulty()
        validateServing()
        validatePerpTime()
        validateSpicy()
        validateCategory()
        validateIngredientList()
        validateInstructionList()
    }

    private func resetIngredientValidationFlags() {
        ingredientNameIsError = false
        ingredientValueIsError = false
        ingredientValueTypeIsError = false
    }
    
    private func resetInstructionValidationFlags() {
        instructionIsError = false
        instructionListIsError = false
    }
}

// MARK: - Delegate methods

extension AddRecipeViewModel: AddRecipeVCDelegate {
    func loadDataToEditor() {
        if didRecipeExist {
            DispatchQueue.main.async {
                self.delegateDetails?.loadDataToEditor()
            }
            print("DEBUG: loadData() from AddRecipeViewModel celled")
        }
    }
    
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
    
    func delegateIngredientsError(_ type: ValidationErrorTypes) {
        DispatchQueue.main.async {
            self.delegateIngredients?.delegateIngredientsError(type)
        }
    }
}

extension AddRecipeViewModel: AddIngredientSheetVCDelegate {
    func delegateIngredientSheetError(_ type: ValidationErrorTypes) {
        DispatchQueue.main.async {
            self.delegateIngredientSheet?.delegateIngredientSheetError(type)
        }
    }
}

extension AddRecipeViewModel: AddRecipeInstructionsVCDelegate {
    func reloadInstructionTable() {
        DispatchQueue.main.async {
            self.delegateInstructions?.reloadInstructionTable()
        }
    }
    
    func delegateInstructionsError(_ type: ValidationErrorTypes) {
        DispatchQueue.main.async {
            self.delegateInstructions?.delegateInstructionsError(type)
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
    case ingredientList
    case instruction
    case instructionList
}

#if DEBUG
extension AddRecipeViewModel: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewModels")
    }
}
#endif
