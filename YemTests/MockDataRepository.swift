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

    // Example mock data
    private var mockRecipes: [RecipeModel] = []

    // Variables for testing purposes
    var mockRecipeExists: Bool = false
    var mockSaveSuccess: Bool = true
    var isAddRecipeCalled: Bool = false
    var isUpdateRecipeCalled: Bool = false

    func save() -> Bool {
        return mockSaveSuccess
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

    func addRecipe(recipe: RecipeModel) {
        isAddRecipeCalled = true
        mockRecipes.append(recipe)
        
        
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

    func fetchAllRecipes() -> Result<[RecipeModel], Error> {
        return .success(mockRecipes)
    }

    func fetchRecipesWithName(_ name: String) -> Result<[RecipeModel]?, Error> {
        let filteredRecipes = mockRecipes.filter { $0.name.contains(name) }
        return .success(filteredRecipes)
    }

    func updateRecipeFavouriteStatus(recipeId: UUID, isFavourite: Bool) {
        // TO DO
    }

    func fetchShopingList(isChecked: Bool) -> Result<[Yem.ShopingListModel], any Error> {
        // TO DO
        let shopingList: [Yem.ShopingListModel] = [
            ShopingListModel(id: UUID(), isChecked: false, name: "Sugar", value: "1", valueType: "kg")
        ]
        return .success(shopingList)
    }

    func updateShopingList(shopingList: Yem.ShopingListModel) {
        // TO DO
    }

    func clearShopingList() {
        // TO DO
    }

    func addIngredientsToShopingList(ingredients: [Yem.IngredientModel]) {
        // TO DO
    }
}
