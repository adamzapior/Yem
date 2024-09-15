//
//  ShopingListAddSheetVM.swift
//  Yem
//
//  Created by Adam Zapiór on 30/08/2024.
//

import Combine
import Foundation
import LifetimeTracker

final class ShopingListAddItemSheetVM {
    private let repository: DataRepositoryProtocol

    @Published var ingredientName: String = ""
    @Published var ingredientValue: String = ""
    @Published var ingredientValueType: String = ""

    var ingredientNameIsError: Bool = false
    var ingredientValueIsError: Bool = false
    var ingredientValueTypeIsError: Bool = false

    private var validationErrors: [ValidationError] = []

    var ingredientValueTypeArray: [IngredientValueTypeModel] = IngredientValueTypeModel.allCases

    let inputEvent = PassthroughSubject<Input, Never>()
    private var inputPublisher: AnyPublisher<Input, Never> {
        inputEvent.eraseToAnyPublisher()
    }

    private let outputEvent = PassthroughSubject<Output, Never>()
    var outputPublisher: AnyPublisher<Output, Never> {
        outputEvent.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle

    init(repository: DataRepositoryProtocol) {
        self.repository = repository

        observeInput()
        observeIngredientValues()
#if DEBUG
        trackLifetime()
#endif
    }

    // MARK: - Public methods
    
    func addIngredientToShoppingList() throws {
        validationErrors = []
        ingredientNameIsError = false
        ingredientValueIsError = false
        ingredientValueTypeIsError = false
        
        let ingredient = IngredientModel(id: UUID(), name: ingredientName, value: ingredientValue, valueType: .init(name: ingredientValueType))
        
        validateIngredient(ingredient)
        
        if hasValidationErrors() {
            sendValidationOutput()
            throw ValidationErrors(errors: validationErrors)
        }
        
        do {
            try repository.addIngredientsToShopingList(ingredients: [ingredient])
        } catch {
            throw error
        }
    }
    
    func hasValidationErrors() -> Bool {
        return ingredientNameIsError || ingredientValueIsError || ingredientValueTypeIsError
    }

    // MARK: - Private methods

    // Validation

    private func resetIngredientValidationFlags() {
        ingredientNameIsError = false
        ingredientValueIsError = false
        ingredientValueTypeIsError = false
    }

    private func validateIngredientName() -> Bool {
        if ingredientName.isEmpty {
            ingredientNameIsError = true
            return false
        }
        return true
    }

    private func validateIngredientValue() -> Bool {
        let numberRegex = "^[0-9]+(\\.[0-9]{1,2})?$"
        if ingredientValue.isEmpty || !NSPredicate(format: "SELF MATCHES %@", numberRegex).evaluate(with: ingredientValue) {
            ingredientValueIsError = true
            return false
        }
        return true
    }

    private func validateIngredientValueType() -> Bool {
        if ingredientValueType.isEmpty || !ingredientValueTypeArray.contains(where: { $0.name == ingredientValueType }) {
            ingredientValueTypeIsError = true
            return false
        }
        return true
    }

    private func validateIngredient(_ ingredient: IngredientModel) {
        validationErrors.removeAll()

        if !validateIngredientName() {
            validationErrors.append(.invalidName)
        }
        if !validateIngredientValue() {
            validationErrors.append(.invalidValue)
        }
        if !validateIngredientValueType() {
            validationErrors.append(.invalidValueType)
        }
    }
    

}

// MARK: - Observed Input & Handling

extension ShopingListAddItemSheetVM {
    private func observeInput() {
        inputPublisher
            .sink { [unowned self] event in
                self.handleInput(event: event)
            }
            .store(in: &cancellables)
    }

    private func handleInput(event: Input) {
        switch event {
        case .valueChanged(let type):
            switch type {
            case .ingredientName(value: let value):
                let newValue = value
                ingredientName = newValue
            case .ingredientValue(value: let value):
                ingredientValue = value
            case .ingredientValueType(value: let value):
                ingredientValueType = value.name
            }
        }
    }
}

// MARK: - Handle output method

extension ShopingListAddItemSheetVM {
    private func sendValidationOutput() {
        for error in self.validationErrors {
            switch error {
            case .invalidName:
                outputEvent.send(.validationError(.invalidName))
            case .invalidValue:
                outputEvent.send(.validationError(.invalidValue))
            case .invalidValueType:
                outputEvent.send(.validationError(.invalidValueType))

            }
        }
    }
}

// MARK: -  Observed properties

extension ShopingListAddItemSheetVM {
    private func observeIngredientValues() {
        $ingredientName
            .sink { [unowned self] newName in
                self.outputEvent.send(.updateField(.ingredientName(value: newName)))
            }
            .store(in: &cancellables)

        $ingredientValue
            .map { $0.filter { "0123456789".contains($0) } }
            .sink { [unowned self] newValue in
                self.outputEvent.send(.updateField(.ingredientValue(value: newValue)))
            }
            .store(in: &cancellables)

        $ingredientValueType
            .sink { [unowned self] newValueType in
                self.outputEvent.send(.updateField(.ingredientValueType(value: .init(name: newValueType))))
            }
            .store(in: &cancellables)
    }
}

// MARK: - Input & Output Definitions

extension ShopingListAddItemSheetVM {
    enum Input {
        case valueChanged(for: IngredientField)
    }

    enum Output {
        case updateField(IngredientField)
        case validationError(ValidationError)
    }

    enum IngredientField {
        case ingredientName(value: String)
        case ingredientValue(value: String)
        case ingredientValueType(value: IngredientValueTypeModel)
    }
}

// MARK: - Error handling

extension ShopingListAddItemSheetVM {
    enum ValidationError: Error {
        case invalidName
        case invalidValue
        case invalidValueType
    }

    struct ValidationErrors: Error {
        let errors: [ValidationError]
    }
}

// MARK: - Accessibility

extension ShopingListAddItemSheetVM {
    enum AccessibilityElement {
        case ingredientNameTextField
        case ingredientValueTextField
        case ingredientValueTypePicker
    }
}

// MARK: - LifetimeTracker

#if DEBUG
extension ShopingListAddItemSheetVM: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewModels")
    }
}
#endif
