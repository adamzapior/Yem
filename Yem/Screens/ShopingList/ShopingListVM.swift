//
//  ShopingListVM.swift
//  Yem
//
//  Created by Adam Zapiór on 09/12/2023.
//

import Combine
import Foundation
import LifetimeTracker

protocol ShopingListVMDelegate: AnyObject {
    func reloadTable()
}

protocol ShopingListAddIngredientSheetVCDelegate: AnyObject {
    func delegateIngredientSheetError(_ type: ValidationErrorTypes)
}

final class ShopingListVM {
    private let repository: DataRepositoryProtocol
    private var cancellables: Set<AnyCancellable> = []

    weak var delegate: ShopingListVMDelegate?
    weak var delegateIngredientSheet: ShopingListAddIngredientSheetVCDelegate?

    var uncheckedList: [ShopingListModel] = []
    var checkedList: [ShopingListModel] = []

    @Published var ingredientName: String = ""
    @Published var ingredientValue: String = ""
    @Published var ingredientValueType: String = ""

    @Published var ingredientNameIsError: Bool = false
    @Published var ingredientValueIsError: Bool = false
    @Published var ingredientValueTypeIsError: Bool = false

    var ingredientValueTypeArray: [IngredientValueType] = IngredientValueType.allCases

    init(repository: DataRepositoryProtocol) {
        self.repository = repository

        repository.shopingListPublisher
            .sink(receiveValue: { [weak self] _ in
                Task { [weak self] in
                    self?.loadShopingList()
                }
            })
            .store(in: &cancellables)

#if DEBUG
        trackLifetime()
#endif
    }

    func loadShopingList() {
        uncheckedList = repository.fetchShopingList(isChecked: false).successOrEmpty()
        checkedList = repository.fetchShopingList(isChecked: true).successOrEmpty()
        reloadTable()
    }

    func updateIngredientCheckStatus(ingredient: inout ShopingListModel) {
        if let index = uncheckedList.firstIndex(where: { $0.id == ingredient.id }) {
            uncheckedList.remove(at: index)
            ingredient.isChecked = true
            checkedList.append(ingredient)
        } else if let index = checkedList.firstIndex(where: { $0.id == ingredient.id }) {
            checkedList.remove(at: index)
            ingredient.isChecked = false
            uncheckedList.append(ingredient)
        }

        repository.updateShopingList(shopingList: ingredient)
        reloadTable()
    }

    func addIngredientToList() -> Bool {
        resetIngredientValidationFlags()
        validateIngredientForm()

        if hasIngredientValidationErrors() {
            print("failed")
            return false
        }

        repository.addIngredientsToShopingList(ingredients: [IngredientModel(id: UUID(), value: ingredientValue, valueType: ingredientValueType, name: ingredientName)])

        clearIngredientProperties()
        return true
    }

    func clearShopingList() {
        repository.clearShopingList()
        reloadTable()
    }

    func hasIngredientValidationErrors() -> Bool {
        return ingredientNameIsError || ingredientValueIsError || ingredientValueTypeIsError
    }

    // MARK: - Validation

    private func validateIngredientForm() {
        validateIngredientName()
        validateIngredientValue()
        validateIngredientValueType()
    }

    private func resetIngredientValidationFlags() {
        ingredientNameIsError = false
        ingredientValueIsError = false
        ingredientValueTypeIsError = false
    }

    private func validateIngredientName() {
        if ingredientName.isEmpty {
            ingredientNameIsError = true
            delegateIngredientSheetError(.ingredientName)
        }
    }

    private func validateIngredientValue() {
        let numberRegex = "^[0-9]+(\\.[0-9]{1,2})?$"
        if ingredientValue.isEmpty || !NSPredicate(format: "SELF MATCHES %@", numberRegex).evaluate(with: ingredientValue) {
            ingredientValueIsError = true
            delegateIngredientSheetError(.ingredientValue)
        }
    }

    private func validateIngredientValueType() {
        if ingredientValueType.isEmpty || !ingredientValueTypeArray.contains(where: { $0.displayName == ingredientValueType }) {
            ingredientValueTypeIsError = true
            delegateIngredientSheetError(.ingredientValueType)
        }
    }

    private func clearIngredientProperties() {
        ingredientName = ""
        ingredientValue = ""
        ingredientValueType = ""
    }
}

// MARK: - ViewModel Delegates

extension ShopingListVM: ShopingListAddIngredientSheetVCDelegate {
    func delegateIngredientSheetError(_ type: ValidationErrorTypes) {
        DispatchQueue.main.async {
            self.delegateIngredientSheet?.delegateIngredientSheetError(type)
        }
    }
}

extension ShopingListVM: ShopingListVMDelegate {
    func reloadTable() {
        DispatchQueue.main.async {
            self.delegate?.reloadTable()
        }
    }
}

enum ShopingListType: Int, CaseIterable {
    case unchecked
    case checked
}

// MARK: - Result extension

extension Result where Success == [ShopingListModel], Failure == Error {
    func successOrEmpty() -> [ShopingListModel] {
        switch self {
        case .success(let result):
            return result
        case .failure(let error):
            print("DEBUG: Error loading recipes: \(error)")
            return []
        }
    }
}

#if DEBUG
extension ShopingListVM: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewModels")
    }
}
#endif
