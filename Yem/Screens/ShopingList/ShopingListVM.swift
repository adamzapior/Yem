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

final class ShopingListVM: IngredientViewModel {
    var delegateIngredients: (any AddRecipeIngredientsVCDelegate)?

    weak var delegateIngredientSheet: AddIngredientSheetVCDelegate?

    weak var delegate: ShopingListVMDelegate?
    let repository: DataRepository

    var uncheckedList: [ShopingListModel] = []
    var checkedList: [ShopingListModel] = []

    @Published
    var ingredientName: String = ""

    @Published
    var ingredientValue: String = ""

    @Published
    var ingredientValueType: String = ""

    @Published
    var ingredientNameIsError: Bool = false

    @Published
    var ingredientValueIsError: Bool = false

    @Published
    var ingredientValueTypeIsError: Bool = false

    var valueTypeArray: [String] {
        return IngredientValueType.allCases.map { $0.displayName }
    }

    private var cancellables: Set<AnyCancellable> = []

    init(repository: DataRepository) {
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

    // MARK: - Public methods

    func loadShopingList() {
        let uncheckedResult = repository.fetchShopingList(isChecked: false)
        let checkedResult = repository.fetchShopingList(isChecked: true)

        switch uncheckedResult {
        case .success(let result):
            uncheckedList = result
        case .failure(let error):
            print("DEBUG: Error loading recipes: \(error)")
        }

        switch checkedResult {
        case .success(let result):
            checkedList = result
        case .failure(let error):
            print("DEBUG: Error loading recipes: \(error)")
        }

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

        if ingredientNameIsError || ingredientValueIsError || ingredientValueTypeIsError {
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

    // MARK: - Private methods

    private func resetIngredientValidationFlags() {
        ingredientNameIsError = false
        ingredientValueIsError = false
        ingredientValueTypeIsError = false
    }

    private func validateIngredientForm() {
        validateIngredientName()
        validateIngredientValue()
        validateIngredientValueType()
    }

    private func validateIngredientName() {
        if ingredientName.isEmpty {
            ingredientNameIsError = true
            delegateIngredientSheetError(.ingredientName)
        }
    }

    private func validateIngredientValue() {
        if ingredientValue.isEmpty {
            ingredientValueIsError = true
            delegateIngredientSheetError(.ingredientValue)
        }
    }

    private func validateIngredientValueType() {
        if ingredientValueType.isEmpty {
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

extension ShopingListVM: AddIngredientSheetVCDelegate {
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

#if DEBUG
extension ShopingListVM: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewModels")
    }
}
#endif
