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
import UIKit
import LifetimeTracker

protocol AddRecipeVCDelegate: AnyObject {
    func loadData()
    func delegateDetailsError(_ type: ValidationErrorTypes)
}

protocol AddRecipeIngredientsVCDelegate: AnyObject {
    func reloadIngredientsTable()
    func delegateIngredientsError(_ type: ValidationErrorTypes)
}

protocol AddIngredientSheetVCDelegate: AnyObject {
    func delegateIngredientError(_ type: ValidationErrorTypes)
}

protocol AddRecipeInstructionsVCDelegate: AnyObject {
    func reloadInstructionTable()
    func delegateInstructionsError(_ type: ValidationErrorTypes)
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
    var recipeID: UUID = .init()
    
    @Published
    var selectedImage: UIImage?
//    
//    @Published
//    var slectedImageView: UIImageView?
    
    @Published
    var recipeTitle: String = ""
    
    @Published
    var difficulty: String = ""
    
    @Published
    var serving: String = ""
    
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
    var ingredientsList: [IngredientModel] = [] {
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
    
    @Published
    var isFavourite: Bool = false
    
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
    var servingRowArray: [Int] {
        return Array(1...36)
    }

    var timeHoursArray: [Int] {
        return Array(0...48)
    }

    var timeMinutesArray: [Int] {
        return Array(0...59)
    }
        
    var spicyRowArray: [RecipeSpicy] = RecipeSpicy.allCases
    
    var categoryRowArray: [RecipeCategory] = RecipeCategory.allCases
    
    var difficultyRowArray: [RecipeDifficulty] = RecipeDifficulty.allCases
    
    lazy var valueTypeArray: [String] = ["Unit", "Grams (g)", "Kilograms (kg)", "Milliliters (ml)", "Liters (L)", "Teaspoons (tsp)", "Tablespoons (Tbsp)", "Cups (c)", "Pinch"]
    
    var didRecipeExist: Bool = false
    
    // MARK: - Initialization
    
    init(repository: DataRepository, existingRecipe: RecipeModel? = nil) {
        self.repository = repository
        
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

        if recipeTitleIsError || servingIsError || difficultyIsError || perpTimeIsError || spicyIsError || categoryIsError || ingredientListIsError || instructionIsError {
            print("DEBUG: Validation failed: Title, serving, difficulty, preparation time, spicy, category, ingredients, instruction error")
            return false
        }
        
        if repository.doesRecipeExist(with: recipeID) {
            return updateRecipe()
        } else {
            return addNewRecipe()
        }
    }

    // MARK: - Private methods
    
    /// Load recipe if exsists - method usued when ViewModel is initializated by editing recipe
    ///
    
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
        
        if recipe.isImageSaved {
            let imageUrl = LocalFileManager.instance.imageUrl(for: recipe.id.uuidString)
            let provider = LocalFileImageDataProvider(fileURL: imageUrl!)
            
            let fetchImageView = UIImageView()
            
//            if slectedImageView == nil {
//                slectedImageView = UIImageView()
//            }

            
//            if selectedImage == nil {
//                selectedImage = UIImageView()
//            }
            
            fetchImageView.kf.setImage(with: provider) { result in
                switch result {
                case .success(let result):
                    print(result.cacheType)
                    print(result.source)
                    self.selectedImage = result.image
                    print("success here")
                case .failure(let error):
                    print(error)
                    print("error here")
                }
            }
        }
    }

    private func addNewRecipe() -> Bool {
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

        repository.addRecipe(recipe: recipe)

        if let image = selectedImage {
            let imageSaved = LocalFileManager.instance.saveImage(with: recipeID.uuidString, image: image)
            if !imageSaved {
                repository.rollbackTransaction()
                return false
            }
        }

        if !repository.save() {
            repository.rollbackTransaction()
            return false
        }

        repository.endTransaction()
        print("DEBUG: New recipe saved successfully")
        return true
    }
    
    private func updateRecipe() -> Bool {
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

        repository.updateRecipe(recipe: recipe)

        if let image = selectedImage {
            let imageSaved = LocalFileManager.instance.updateImage(with: recipeID.uuidString, newImage: image)
            if !imageSaved {
                repository.rollbackTransaction()
                return false
            }
        }

        if !repository.save() {
            repository.rollbackTransaction()
            return false
        }

        repository.endTransaction()
        print(selectedImage?.cgImage)
        print("DEBUG: Recipe updated successfully")
        return true
    }
    
    /// Add selectedImage to FileManager
    
    private func saveSelectedImage() -> Bool {
        guard let image = selectedImage else {
            return false
        }
        return LocalFileManager.instance.saveImage(with: recipeID.uuidString, image: image)
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
        if difficulty.isEmpty {
            difficultyIsError = true
            validationErrors.append(.difficulty)
            delegateDetailsError(.difficulty)
        }
    }
    
    private func validateServing() {
        if serving.isEmpty {
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
            delegateIngredientsError(.ingredientList)
        }
    }
    
    private func validateInstruction() {
        if instruction.isEmpty {
            instructionIsError = true
            delegateInstructionError(.instructionList)
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
    func loadData() {
        if didRecipeExist {
            DispatchQueue.main.async {
                self.delegateDetails?.loadData()
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
