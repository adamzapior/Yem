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

import AVFoundation
import Photos

final class ManageRecipeVM {
    private let repository: DataRepositoryProtocol
    private let localFileManager: LocalFileManagerProtocol
    private let imageFetcherManager: ImageFetcherManagerProtocol

    private var existingRecipe: RecipeModel?
    
    // MARK: Recipe properties

    private var recipeID: UUID = .init()
    @Published var selectedImage: UIImage?
    @Published private var recipeTitle: String = ""
    @Published private var difficulty: String = ""
    @Published private var serving: String = ""
    @Published private var prepTimeHours: String = ""
    @Published private var prepTimeMinutes: String = ""
    @Published private var spicy: String = ""
    @Published private var category: String = ""
    @Published private var ingredientName: String = ""
    @Published private var ingredientValue: String = ""
    @Published private var ingredientValueType: String = ""
    @Published private var instruction: String = ""
    @Published private var isFavourite: Bool = false
    @Published var ingredientsList: [IngredientModel] = []
    @Published var instructionList: [InstructionModel] = []

    // MARK: Error handling properties

    private var recipeTitleIsError: Bool = false
    private var difficultyIsError: Bool = false
    private var servingIsError: Bool = false
    private var prepTimeIsError: Bool = false
    private var spicyIsError: Bool = false
    private var categoryIsError: Bool = false
    private var ingredientNameIsError: Bool = false
    private var ingredientValueIsError: Bool = false
    private var ingredientValueTypeIsError: Bool = false
    private var ingredientListIsError: Bool = false
    private var instructionIsError: Bool = false
    private var instructionListIsError: Bool = false
    
    private var validationErrors: [ErrorType] = []

    // MARK: - Properties
        
    var servingRowArray: [Int] = RecipeModel.servingRowArray
    var timeHoursArray: [Int] = RecipeModel.timeHoursArray
    var timeMinutesArray: [Int] = RecipeModel.timeMinutesArray
    var spicyRowArray: [RecipeSpicyModel] = RecipeSpicyModel.allCases
    var categoryRowArray: [RecipeCategoryModel] = RecipeCategoryModel.allCases
    var difficultyRowArray: [RecipeDifficultyModel] = RecipeDifficultyModel.allCases
    var ingredientValueTypeArray: [IngredientValueTypeModel] = IngredientValueTypeModel.allCases
    
    var didRecipeExist: Bool = false
    
    // MARK: Input events
    
    let inputDetailsFormEvent = PassthroughSubject<DetailsFormInput, Never>()
    let inputIngredientsListEvent = PassthroughSubject<IngredientsListInput, Never>()
    let inputIngredientFormEvent = PassthroughSubject<IngredientFormInput, Never>()
    let inputInstructionsListEvent = PassthroughSubject<InstructionsListInput, Never>()
    let inputInstructionFormEvent = PassthroughSubject<InstructionFormInput, Never>()
    
    // MARK: Input publishers
    
    private var inputDetailsFormEventPublisher: AnyPublisher<DetailsFormInput, Never> {
        inputDetailsFormEvent.eraseToAnyPublisher()
    }

    private var inputIngredientsListEventPublisher: AnyPublisher<IngredientsListInput, Never> {
        inputIngredientsListEvent.eraseToAnyPublisher()
    }

    private var inputIngredientFormEventPublisher: AnyPublisher<IngredientFormInput, Never> {
        inputIngredientFormEvent.eraseToAnyPublisher()
    }

    private var inputInstructionsListPublisher: AnyPublisher<InstructionsListInput, Never> {
        inputInstructionsListEvent.eraseToAnyPublisher()
    }

    private var inputInstructionFormPublisher: AnyPublisher<InstructionFormInput, Never> {
        inputInstructionFormEvent.eraseToAnyPublisher()
    }
    
    // MARK: Output events
    
    private let outputDetailsFormEvent = PassthroughSubject<DetailsFormOutput, Never>()
    private let outputIngredientsListEvent = PassthroughSubject<IngredientsListOutput, Never>()
    private let outputIngredientFormEvent = PassthroughSubject<IngredientFormOutput, Never>()
    private let outputInstructionsListEvent = PassthroughSubject<InstructionsListOutput, Never>()
    private let outputInstructionFormEvent = PassthroughSubject<InstructionFormOutput, Never>()
    
    // MARK: Output publishers
    
    var outputDetailsFormEventPublisher: AnyPublisher<DetailsFormOutput, Never> {
        outputDetailsFormEvent.eraseToAnyPublisher()
    }

    var outputIngredientsListEventPublisher: AnyPublisher<IngredientsListOutput, Never> {
        outputIngredientsListEvent.eraseToAnyPublisher()
    }

    var outputIngredientFormEventPublisher: AnyPublisher<IngredientFormOutput, Never> {
        outputIngredientFormEvent.eraseToAnyPublisher()
    }

    var outputInstructionsListPublisher: AnyPublisher<InstructionsListOutput, Never> {
        outputInstructionsListEvent.eraseToAnyPublisher()
    }

    var outputInstructionFormPublisher: AnyPublisher<InstructionFormOutput, Never> {
        outputInstructionFormEvent.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    init(
        repository: DataRepositoryProtocol,
        localFileManager: LocalFileManagerProtocol,
        imageFetcherManager: ImageFetcherManagerProtocol,
        existingRecipe: RecipeModel? = nil)
    {
        self.repository = repository
        self.localFileManager = localFileManager
        self.imageFetcherManager = imageFetcherManager
        
        if let recipe = existingRecipe {
            self.existingRecipe = recipe
            
            loadRecipeData(recipe)
            didRecipeExist = true
            print("DEBUG: loadRecipeData called with existing recipe")
            inputDetailsFormEvent.send(.sendDetailsValues(.recipeTitle(recipe.name)))
        } else {
            print("DEBUG: existingRecipe is nil")
        }
        
        observeInput()
        observeProperties()
#if DEBUG
        trackLifetime()
#endif
    }
    
    // MARK: Photo & Camera access

    func requestPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            outputDetailsFormEvent.send(.openPhotoLibrary)
        case .denied, .restricted: break
        // Handle restricted access here or inform ViewController to show an alert
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async { [weak self] in
                    if status == .authorized {
                        self?.outputDetailsFormEvent.send(.openPhotoLibrary)
                    } else {
                        // Handle unauthorized access here or inform ViewController to show an alert
                    }
                }
            }
        default:
            break
        }
    }

    func requestCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            outputDetailsFormEvent.send(.openCamera)
        case .denied, .restricted: break
        // Handle restricted access here or inform ViewController to show an alert
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { [weak self] in
                    if granted {
                        self?.outputDetailsFormEvent.send(.openCamera)
                    } else {
                        // Handle unauthorized access here or inform ViewController to show an alert
                    }
                }
            }
        @unknown default:
            break
        }
    }
  
    // MARK: IngredientList operations

    func addIngredientToList() throws {
        validationErrors = []
        ingredientNameIsError = false
        ingredientValueIsError = false
        ingredientValueTypeIsError = false
        
        validateIgredientName()
        validateIgredientValue()
        validateIgredientValueType()
        
        if ingredientNameIsError || ingredientValueIsError || ingredientValueTypeIsError {
            sendValidationOutput()
            throw ValidationError.upsertError("Add ingredient to list failed")
        }
        
        let ingredient = IngredientModel(id: UUID(),
                                         name: ingredientName,
                                         value: ingredientValue,
                                         valueType: IngredientValueTypeModel(name: ingredientValueType))
        
        ingredientsList.append(ingredient)
        outputIngredientsListEvent.send(.reloadTable)
        clearIngredientProperties()
    }
    
    func removeIngredientFromList(at index: Int) {
        guard index >= 0, index < ingredientsList.count else { return }
        ingredientsList.remove(at: index)
    }
    
    // MARK: InstructionList operations
  
    func addInstructionToList() throws {
        validationErrors = []
        instructionIsError = false
        instructionListIsError = false
        
        validateInstruction()
        
        if instructionIsError {
            sendValidationOutput()
            throw ValidationError.upsertError("Add instruction to list failed")
        }
        
        let count = instructionList.count
        let index = count + 1
        let instruction = InstructionModel(id: UUID(),
                                           index: index,
                                           text: instruction)
        
        instructionList.append(instruction)
        outputInstructionsListEvent.send(.reloadTable)
        clearInstructionProperties()
    }
    
    func updateInstructionIndexes() {
        for (index, var instruction) in instructionList.enumerated() {
            instruction.index = index + 1
            instructionList[index] = instruction
        }
    }
    
    func removeInstructionFromList(at index: Int) {
        guard index >= 0, index < instructionList.count else { return }
        instructionList.remove(at: index)
    }

    // MARK: Add or update recipe methods
    
    func saveRecipe() throws {
        validationErrors = []
        validateForms()
        
        // Check if there are validation errors
        if hasRecipeValidationErrors() {
            sendValidationOutput()
            throw ValidationError.multiple(validationErrors)
        }
        
        let recipe = RecipeModel(id: recipeID,
                                 name: recipeTitle,
                                 serving: serving.description,
                                 perpTimeHours: prepTimeHours,
                                 perpTimeMinutes: prepTimeMinutes,
                                 spicy: RecipeSpicyModel(value: spicy),
                                 category: RecipeCategoryModel(value: category),
                                 difficulty: RecipeDifficultyModel(value: difficulty),
                                 ingredientList: ingredientsList,
                                 instructionList: instructionList,
                                 isImageSaved: selectedImage != nil,
                                 isFavourite: isFavourite)
        
        let doesExist = doesRecipeExist(id: recipeID)
        print("DEBUG: Does recipe exist? \(doesExist)")
        
        do {
            if doesExist {
                try upsertRecipe(insertType: .update, recipe: recipe)
            } else {
                try upsertRecipe(insertType: .add, recipe: recipe)
            }
        } catch {
            try handleSaveRecipeError(error)
        }
    }

    private func handleSaveRecipeError(_ error: Error) throws {
        print("DEBUG: Repository save failed: \(error.localizedDescription)")

        // Spróbuj usunąć obraz, jeśli został zapisany wcześniej
        if selectedImage != nil, case .failure(let deleteError) = localFileManager.deleteImage(with: recipeID.uuidString) {
            print("DEBUG: Error deleting image: \(deleteError.localizedDescription)")
            throw UpsertRecipeError.imageDeleteFailed(deleteError)
        }

        throw UpsertRecipeError.repositorySaveFailed
    }
    
    private func doesRecipeExist(id: UUID) -> Bool {
        return repository.doesRecipeExist(with: id)
    }
    
    private func upsertRecipe(insertType: InsertMethodType, recipe: RecipeModel) throws {
        repository.beginTransaction()
        
        do {
            try saveImageIfNeeded()
            
            switch insertType {
            case .add:
                try repository.addRecipe(recipe: recipe)
            case .update:
                try repository.updateRecipe(recipe: recipe)
            }
                        
            try repository.commitTransaction()
            
        } catch let error as UpsertRecipeError {
            repository.rollbackTransaction()
            throw error
        } catch {
            repository.rollbackTransaction()
            throw error
        }
    }
    
    private func saveImageIfNeeded() throws {
        guard let image = selectedImage else { return }
        // Próba zapisu obrazu
        if case .failure(let error) = localFileManager.saveImage(with: recipeID.uuidString, image: image) {
            print("DEBUG: Error saving image: \(error.localizedDescription)")
            throw UpsertRecipeError.imageSaveFailed(error)
        }
    }
    
    private func sendValidationOutput() {
        for error in validationErrors {
            switch error {
            case .details(let detailError):
                switch detailError {
                case .recipeTitle:
                    outputDetailsFormEvent.send(.validationError(.recipeTitle))
                case .difficulty:
                    outputDetailsFormEvent.send(.validationError(.difficulty))
                case .servings:
                    outputDetailsFormEvent.send(.validationError(.servings))
                case .prepTime:
                    outputDetailsFormEvent.send(.validationError(.prepTime))
                case .spicy:
                    outputDetailsFormEvent.send(.validationError(.spicy))
                case .category:
                    outputDetailsFormEvent.send(.validationError(.category))
                }
                
            case .ingredients(let ingredientError):
                switch ingredientError {
                case .ingredientName:
                    outputIngredientFormEvent.send(.validationError(.ingredientName))
                case .ingredientValue:
                    outputIngredientFormEvent.send(.validationError(.ingredientValue))
                case .ingredientValueType:
                    outputIngredientFormEvent.send(.validationError(.ingredientValueType))
                case .ingredientsList:
                    outputIngredientsListEvent.send(.validationError(.ingredientsList))
                }
                
            case .instructions(let instructionError):
                switch instructionError {
                case .instruction:
                    outputInstructionFormEvent.send(.validationError(.instruction))
                case .instructionList:
                    outputInstructionsListEvent.send(.validationError(.instructionList))
                }
            }
        }
    }
}

// MARK: - Observed Input

extension ManageRecipeVM {
    private func observeInput() {
        inputDetailsFormEvent
            .sink { [unowned self] event in
                switch event {
                case .viewDidLoad:
                    guard let existingRecipe else { return }
                    loadRecipeData(existingRecipe)
                case .sendDetailsValues(let type):
                    switch type {
                    case .recipeTitle(let value):
                        recipeTitle = value
                    case .difficulty(let value):
                        difficulty = value
                    case .servings(let value):
                        serving = value
                    case .prepTime(let type):
                        switch type {
                        case .hours(let value): prepTimeHours = value
                        case .minutes(let value): prepTimeMinutes = value
                        case .fullTime: break
                        }
                    case .spicy(let value):
                        spicy = value
                    case .category(let value):
                        category = value
                    }
                case .requestPhotoLibrary:
                    requestPhotoLibraryPermission()
                case .requestCamera:
                    requestCameraPermission()
                }
            }
            .store(in: &cancellables)

        inputIngredientFormEvent
            .sink { [unowned self] event in
                switch event {
                case .viewDidLoad:
                    break
                case .sendIngredientValues(let type):
                    switch type {
                    case .ingredientName(let value):
                        ingredientName = value
                    case .ingredientValue(let value):
                        ingredientValue = value
                    case .ingredientValueType(let value):
                        ingredientValueType = value
                    }
                }
            }
            .store(in: &cancellables)

        inputIngredientsListEvent
            .sink { [unowned self] event in
                switch event {
                case .viewDidLoad:
                    self.outputIngredientsListEvent.send(.updateListStatus(isEmpty: ingredientsList.isEmpty))
                }
            }
            .store(in: &cancellables)

        inputInstructionFormEvent
            .sink { [unowned self] event in
                switch event {
                case .viewDidLoad:
                    break
                case .sendInstructionValue(let value):
                    instruction = value
                }
            }
            .store(in: &cancellables)

        inputInstructionsListEvent
            .sink { [unowned self] event in
                switch event {
                case .viewDidLoad:
                    self.outputInstructionsListEvent.send(.updateListStatus(isEmpty: instructionList.isEmpty))
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Validation methods

extension ManageRecipeVM {
    private func hasRecipeValidationErrors() -> Bool {
        return recipeTitleIsError || servingIsError || difficultyIsError || prepTimeIsError || spicyIsError || categoryIsError || ingredientListIsError || instructionListIsError
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

    private func validateRecipeTitle() {
        if recipeTitle.isEmpty {
            recipeTitleIsError = true
            validationErrors.append(.details(.recipeTitle))
        }
    }

    private func validateDifficulty() {
        if difficulty.isEmpty || !difficultyRowArray.contains(where: { $0.displayName == difficulty }) {
            difficultyIsError = true
            validationErrors.append(.details(.difficulty))
        }
    }
    
    private func validateServing() {
        if serving.isEmpty || !servingRowArray.contains(where: { $0.description == serving }) {
            servingIsError = true
            validationErrors.append(.details(.servings))
        }
    }
    
    private func validatePerpTime() {
        if prepTimeHours.isEmpty, prepTimeMinutes.isEmpty {
            recipeTitleIsError = true
            validationErrors.append(.details(.prepTime))
        }
    }

    private func validateSpicy() {
        if spicy.isEmpty || !spicyRowArray.contains(where: { $0.displayName == spicy }) {
            spicyIsError = true
            validationErrors.append(.details(.spicy))
        }
    }
    
    private func validateCategory() {
        if category.isEmpty || !categoryRowArray.contains(where: { $0.displayName == category }) {
            categoryIsError = true
            validationErrors.append(.details(.category))
        }
    }
    
    private func validateIgredientName() {
        if ingredientName.isEmpty {
            ingredientNameIsError = true
            validationErrors.append(.ingredients(.ingredientName))
        }
    }
    
    private func validateIgredientValue() {
        if ingredientValue.isEmpty {
            ingredientValueIsError = true
            validationErrors.append(.ingredients(.ingredientValue))
        }
    }
    
    private func validateIgredientValueType() {
        if ingredientValueType.isEmpty {
            ingredientValueTypeIsError = true
            validationErrors.append(.ingredients(.ingredientValueType))
        }
    }
    
    private func validateIngredientList() {
        if ingredientsList.isEmpty {
            ingredientListIsError = true
            validationErrors.append(.ingredients(.ingredientsList))
        }
    }
    
    private func validateInstruction() {
        if instruction.isEmpty {
            instructionIsError = true
            validationErrors.append(.instructions(.instruction))
        }
    }
    
    private func validateInstructionList() {
        if instructionList.isEmpty {
            instructionListIsError = true
            validationErrors.append(.instructions(.instructionList))
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
    
    private func filterNumericInput(_ text: String?) -> String {
        return text?.filter { "0123456789".contains($0) } ?? ""
    }
    
    private func formatPrepTime(hours: String, minutes: String) -> String {
        var formattedHours = ""
        var formattedMinutes = ""
            
        if hours != "0" && hours != "1" && !hours.isEmpty {
            formattedHours = "\(hours) hours"
        }
            
        if hours == "1" {
            formattedHours = "\(hours) hour"
        }
            
        if minutes != "0" && !minutes.isEmpty {
            formattedMinutes = "\(minutes) min"
        }
            
        if hours == "0" && minutes == "0" {
            return "Select prep time*"
        } else {
            return "\(formattedHours) \(formattedMinutes)".trimmingCharacters(in: .whitespaces)
        }
    }
}

// MARK: - Observed properties

extension ManageRecipeVM {
    private func observeProperties() {
        $selectedImage
            .sink { [unowned self] image in
                guard let image else { return }
                self.outputDetailsFormEvent.send(.updateImage(image))
            }
            .store(in: &cancellables)
        
        $recipeTitle
            .map { $0.prefix(32) }
            .map { String($0) }
            .sink { [unowned self] value in
                self.outputDetailsFormEvent.send(
                    .updateDetailsField(
                        .recipeTitle(value)))
            }
            .store(in: &cancellables)
        
        $difficulty
            .sink { [unowned self] value in
                self.outputDetailsFormEvent.send(
                    .updateDetailsField(
                        .difficulty(value)))
            }
            .store(in: &cancellables)
        
        $serving
            .sink { [unowned self] value in
                self.outputDetailsFormEvent.send(
                    .updateDetailsField(
                        .servings(value)))
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest($prepTimeHours, $prepTimeMinutes)
            .sink { [unowned self] hours, minutes in
                
                let formattedPrepTime = formatPrepTime(hours: hours, minutes: minutes)
   
                self.outputDetailsFormEvent.send(
                    .updateDetailsField(
                        .prepTime(
                            .fullTime(formattedPrepTime))))
            }
            .store(in: &cancellables)
        
        $spicy
            .sink { [unowned self] value in
                self.outputDetailsFormEvent.send(
                    .updateDetailsField(
                        .spicy(value)))
            }
            .store(in: &cancellables)

        $category
            .sink { [unowned self] value in
                self.outputDetailsFormEvent.send(
                    .updateDetailsField(
                        .category(value)))
            }
            .store(in: &cancellables)
        
        $ingredientName
            .sink { [unowned self] value in
                self.outputIngredientFormEvent.send(
                    .updateIngredientForm(
                        .ingredientName(value)))
            }
            .store(in: &cancellables)

        $ingredientValue
            .sink { [unowned self] value in
                let filteredValue = self.filterNumericInput(value)
                /// Only send if the filtered value is different or updated
                if filteredValue != value {
                    self.ingredientValue = filteredValue
                } else {
                    self.outputIngredientFormEvent.send(.updateIngredientForm(.ingredientValue(value)))
                }
            }
            .store(in: &cancellables)

        $ingredientValueType
            .sink { [unowned self] value in
                self.outputIngredientFormEvent.send(
                    .updateIngredientForm(
                        .ingredientValueType(value)))
            }
            .store(in: &cancellables)
        
        $ingredientsList
            .sink { [unowned self] list in
                self.outputIngredientsListEvent.send(.updateListStatus(isEmpty: list.isEmpty))
                self.outputIngredientsListEvent.send(.reloadTable)
            }
            .store(in: &cancellables)
        
        $instruction
            .sink { [unowned self] value in
                self.outputInstructionFormEvent.send(.updateInstructionValue(value))
            }
            .store(in: &cancellables)
        
        $instructionList
            .sink { [unowned self] list in
                self.outputInstructionsListEvent.send(.updateListStatus(isEmpty: list.isEmpty))
                self.outputInstructionsListEvent.send(.reloadTable)
            }
            .store(in: &cancellables)
    }
}

// MARK: Load recipe data if exsist method

extension ManageRecipeVM {
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
            
            if let imageUrl = localFileManager.imageUrl(for: recipe.id.uuidString) {
                imageFetcherManager.fetchImage(from: imageUrl) { [weak self] image in
                        guard let self = self else { return }
                        selectedImage = image
    //                    self.recipeImage.image = image
    //                    self.recipeImage.isHidden = (image == nil)
                    }
                }
            
            
//            var url: URL?
//            
//            let getURL = localFileManager.imageUrl(for: recipe.getStringForURL())
//            switch getURL {
//            case .success(let result):
//                url = result
//            case .failure(let error):
//                print("Error fetching image: \(error.localizedDescription)")
//            }
//            
//            guard let url else { return }
//            
//            imageFetcherManager.fetchImage(from: url) { [weak self] result in
//                switch result {
//                case .success(let image):
//                    self?.selectedImage = image
//                case .failure(let error):
//                    print("Error fetching image: \(error.localizedDescription)")
//                }
//            }
        }
    }
}

// MARK: - Input & Output - ManageRecipeDetailsFromVC

extension ManageRecipeVM {
    enum DetailsFormInput {
        case viewDidLoad
        case requestPhotoLibrary
        case requestCamera
        case sendDetailsValues(Details)
    }
    
    enum DetailsFormOutput {
        case updateImage(UIImage)
        case openPhotoLibrary
        case openCamera
        case updateDetailsField(Details)
        case validationError(ErrorType.Details)
    }
}

// MARK: - Input & Output - ManageRecipeIngredientsListVC

extension ManageRecipeVM {
    enum IngredientsListInput {
        case viewDidLoad
    }
    
    enum IngredientsListOutput {
        case reloadTable
        case updateListStatus(isEmpty: Bool)
        case validationError(ErrorType.Ingredients)
    }
}

// MARK: - Input & Output - ManageRecipeIngredientFormVC

extension ManageRecipeVM {
    enum IngredientFormInput {
        case viewDidLoad
        case sendIngredientValues(IngredientForm)
    }
    
    enum IngredientFormOutput {
        case updateIngredientForm(IngredientForm)
        case validationError(ErrorType.Ingredients)
    }
}

// MARK: - Input & Output - ManageRecipeInstructionsListVC

extension ManageRecipeVM {
    enum InstructionsListInput {
        case viewDidLoad
    }
    
    enum InstructionsListOutput {
        case reloadTable
        case updateListStatus(isEmpty: Bool)
        case validationError(ErrorType.Instructions)
    }
}

// MARK: - Input & Output - ManageRecipeInstructionFormVC

extension ManageRecipeVM {
    enum InstructionFormInput {
        case viewDidLoad
        case sendInstructionValue(String)
    }
    
    enum InstructionFormOutput {
        case updateInstructionValue(String)
        case validationError(ErrorType.Instructions)
    }
}

// MARK: - Validation Errors

extension ManageRecipeVM {
    // Enum representing validation errors with associated messages
    enum ValidationError: Error {
        case multiple([ErrorType])
        case upsertError(String)
        
        var localizedDescription: String {
            switch self {
            case .multiple(let errors):
                return errors.map { $0.description }.joined(separator: "\n")
            case .upsertError(let message):
                return message
            }
        }
    }
    
    // Enum describing different types of errors in the recipe management
    enum ErrorType: Error, CustomStringConvertible {
        case details(Details)
        case ingredients(Ingredients)
        case instructions(Instructions)
        
        var description: String {
            switch self {
            case .details(let detailError):
                return detailError.description
            case .ingredients(let ingredientError):
                return ingredientError.description
            case .instructions(let instructionError):
                return instructionError.description
            }
        }
        
        // MARK: - Nested Error Types
        
        // Enum for errors related to details
        enum Details {
            case recipeTitle
            case difficulty
            case servings
            case prepTime
            case spicy
            case category
            
            var description: String {
                switch self {
                case .recipeTitle:
                    return "Recipe title is required."
                case .difficulty:
                    return "Invalid difficulty level selected."
                case .servings:
                    return "Number of servings must be specified."
                case .prepTime:
                    return "Invalid preparation time format."
                case .spicy:
                    return "Spiciness level must be specified."
                case .category:
                    return "Recipe category is required."
                }
            }
        }
        
        // Enum for errors related to ingredients
        enum Ingredients {
            case ingredientName
            case ingredientValue
            case ingredientValueType
            case ingredientsList
            
            var description: String {
                switch self {
                case .ingredientName:
                    return "Ingredient name is required."
                case .ingredientValue:
                    return "Ingredient value must be specified."
                case .ingredientValueType:
                    return "Ingredient value type must be specified."
                case .ingredientsList:
                    return "At least one ingredient is required."
                }
            }
        }
        
        // Enum for errors related to instructions
        enum Instructions {
            case instruction
            case instructionList
            
            var description: String {
                switch self {
                case .instruction:
                    return "Invalid instruction provided."
                case .instructionList:
                    return "At least one instruction is required."
                }
            }
        }
    }
}

// MARK: - Details Field Types

extension ManageRecipeVM {
    // Enum describing the types of fields in the details section of a recipe
    enum DetailsFieldType {
        case recipeTitle(String)
        case difficulty(String)
        case serving(String)
        case prepTime(PrepTimeType)
        case spicy(String)
        case category(String)
    }
    
    // Enum representing the preparation time format
    enum PrepTimeType {
        case hours(String)
        case minutes(String)
        case fullTime(String)
    }
}

// MARK: - Ingredient Field Types

extension ManageRecipeVM {
    // Enum describing the fields in the ingredient section
    enum IngredientFieldType {
        case ingredientName(String)
        case ingredientValue(String)
        case ingredientValueType(String)
        case ingredientsList
    }
}

// MARK: - Form Enums

extension ManageRecipeVM {
    // Enum for details input form values
    enum Details {
        case recipeTitle(String)
        case difficulty(String)
        case servings(String)
        case prepTime(PrepTimeType)
        case spicy(String)
        case category(String)
    }
    
    // Enum for input fields of an ingredient form
    enum IngredientForm {
        case ingredientName(String)
        case ingredientValue(String)
        case ingredientValueType(String)
    }
    
    // Enum for instruction form inputs
    enum InstructionField {
        case instruction(String)
        case instructionsList
    }
}

// MARK: - Accessibility Elements

extension ManageRecipeVM {
    // Grouping enums related to accessibility elements of the recipe form
    enum AccessibilityElement {
        enum Details {
            case recipeTitle
            case difficulty
            case servings
            case prepTime
            case spicy
            case category
        }
        
        enum Ingredients {
            case ingredientName
            case ingredientValue
            case ingredientValueType
            case ingredientsList
        }

        enum Instructions {
            case instruction
            case instructionList
        }
    }
}

// MARK: - Helper enums

private enum InsertMethodType {
    case add
    case update
}

enum UpsertRecipeError: Error {
    case imageSaveFailed(Error)
    case imageDeleteFailed(Error)
    case repositorySaveFailed
}

// MARK: - LifetimeTracker

#if DEBUG
extension ManageRecipeVM: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewModels")
    }
}
#endif
