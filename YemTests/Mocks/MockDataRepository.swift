//
//  MockDataRepository.swift
//  YemTests
//
//  Created by Adam Zapiór on 04/08/2024.
//

@testable import Yem

import Combine
import Foundation

final class MockDataRepository: DataRepositoryProtocol {
    var recipesInsertedPublisher = PassthroughSubject<ObjectChange, Never>()
    var recipesDeletedPublisher = PassthroughSubject<ObjectChange, Never>()
    var recipesUpdatedPublisher = PassthroughSubject<ObjectChange, Never>()
    var shopingListPublisher = PassthroughSubject<ObjectChange, Never>()

    var mockRecipes: [RecipeModel] = []

    var mockRecipeExists: Bool = false
    var mockSaveSuccess: Bool = false
    var isAddRecipeCalled: Bool = false
    var isUpdateRecipeCalled: Bool = false
    var clearShopingListCalled: Bool = false

    var uncheckedItems: [ShopingListModel] = []
    var checkedItems: [ShopingListModel] = []

    init() {}

    func save() -> Bool {
        return mockSaveSuccess
    }

    func commitTransaction() throws {
        mockSaveSuccess = true
    }

    func beginTransaction() {
        // No-op for mock
    }

    func endTransaction() {
        // No-op for mock
    }

    func rollbackTransaction() {
        // No-op for mock
    }

    func doesRecipeExist(with id: UUID) -> Bool {
        return mockRecipeExists
    }

    // MARK: Fetch

    func fetchAllRecipes() throws -> [Yem.RecipeModel] {
        return mockRecipes
    }

    func fetchRecipesWithName(_ name: String) throws -> [Yem.RecipeModel]? {
        let filteredRecipes = mockRecipes.filter { $0.name.contains(name) }
        return filteredRecipes
    }

    func fetchShopingList(isChecked: Bool) throws -> [Yem.ShopingListModel] {
        if isChecked {
            return checkedItems
        } else {
            return uncheckedItems
        }
    }

    // MARK: Operations

    func addRecipe(recipe: RecipeModel) {
        isAddRecipeCalled = true
        mockRecipes.append(recipe)
    }

    func addIngredientsToShopingList(ingredients: [Yem.IngredientModel]) throws {
        let newItem = ShopingListModel(id: ingredients.first!.id,
                                       isChecked: false,
                                       name: ingredients.first!.name,
                                       value: ingredients.first!.value,
                                       valueType: ingredients.first!.valueType.name)
        uncheckedItems.append(newItem)
        shopingListPublisher.send(completion: .finished)
    }

    func updateRecipe(recipe: RecipeModel) {
        isUpdateRecipeCalled = true
        if let index = mockRecipes.firstIndex(where: { $0.id == recipe.id }) {
            mockRecipes[index] = recipe
        }
    }

    func deleteRecipe(withId id: UUID) {
        if let index = mockRecipes.firstIndex(where: { $0.id == id }) {
            mockRecipes.remove(at: index)
        }
    }

    func updateRecipeFavouriteStatus(recipeId: UUID, isFavourite: Bool) {
        isUpdateRecipeCalled = true
    }

    func updateShopingList(shopingList: Yem.ShopingListModel) {
        // no-op 
    }

    func clearShopingList() {
        clearShopingListCalled = true
    }
}
