//
//  RecipesListVM_Tests.swift
//  YemTests
//
//  Created by Adam Zapiór on 11/08/2024.
//

import Combine
import XCTest
@testable import Yem

final class RecipesListVM_Tests: XCTestCase {
    private var viewModel: RecipesListVM!
    private var mockRepository: MockDataRepository!
    private var mockLocalFileManager: MockLocalFileManager!
    private var mockImageFetcherManager: MockImageFetcherManager!
    
    private let unsavedImageRecipeModel = RecipeModel(
        id: UUID(),
        name: "Cola",
        serving: "1",
        perpTimeHours: "1",
        perpTimeMinutes: "0",
        spicy: RecipeSpicy(rawValue: RecipeSpicy.mild.displayName) ?? .medium,
        category: RecipeCategory(rawValue: RecipeCategory.appetizers.displayName) ?? .notSelected,
        difficulty: RecipeDifficulty(rawValue: RecipeDifficulty.medium.displayName) ?? .medium,
        ingredientList: [IngredientModel(id: UUID(), value: "200", valueType: "g", name: "Flour")],
        instructionList: [InstructionModel(id: UUID(), index: 1, text: "Mix the ingredients")],
        isImageSaved: false,
        isFavourite: true
    )

    private let savedImageRecipeModel = RecipeModel(
        id: UUID(),
        name: "Burger",
        serving: "1",
        perpTimeHours: "1",
        perpTimeMinutes: "0",
        spicy: RecipeSpicy(rawValue: RecipeSpicy.mild.displayName) ?? .medium,
        category: RecipeCategory(rawValue: RecipeCategory.dinner.displayName) ?? .notSelected,
        difficulty: RecipeDifficulty(rawValue: RecipeDifficulty.medium.displayName) ?? .medium,
        ingredientList: [IngredientModel(id: UUID(), value: "200", valueType: "g", name: "Flour")],
        instructionList: [InstructionModel(id: UUID(), index: 1, text: "Mix the ingredients")],
        isImageSaved: true,
        isFavourite: true
    )
    
    private let isNotFavouriteRecipeModel = RecipeModel(
        id: UUID(),
        name: "Pizza",
        serving: "1",
        perpTimeHours: "1",
        perpTimeMinutes: "0",
        spicy: RecipeSpicy(rawValue: RecipeSpicy.mild.displayName) ?? .medium,
        category: RecipeCategory(rawValue: RecipeCategory.sideDishes.displayName) ?? .notSelected,
        difficulty: RecipeDifficulty(rawValue: RecipeDifficulty.medium.displayName) ?? .medium,
        ingredientList: [IngredientModel(id: UUID(), value: "200", valueType: "g", name: "Flour")],
        instructionList: [InstructionModel(id: UUID(), index: 1, text: "Mix the ingredients")],
        isImageSaved: true,
        isFavourite: false
    )

    override func setUp() {
        super.setUp()
        
        mockRepository = MockDataRepository()
        mockLocalFileManager = MockLocalFileManager()
        mockImageFetcherManager = MockImageFetcherManager(stubbedImage: UIImage.testImage())
        
        viewModel = RecipesListVM(
            repository: mockRepository,
            localFileManager: mockLocalFileManager,
            imageFetcherManager: mockImageFetcherManager
        )
    }

    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        mockLocalFileManager = nil
        mockImageFetcherManager = nil
        
        super.tearDown()
    }

    func testLoadRecipesSuccess() {
        let expectation = self.expectation(description: "Reload table")
        
        let mockRecipes = [
            unsavedImageRecipeModel,
            savedImageRecipeModel,
            isNotFavouriteRecipeModel
        ]
        mockRepository.mockRecipes = mockRecipes
        
        viewModel.loadRecipes()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.viewModel.recipes.count, mockRecipes.count)
            XCTAssertEqual(self.viewModel.sections.count, 3)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFilterRecipes() {
        let expectation = self.expectation(description: "Reload table")

        let mockRecipes = [
            unsavedImageRecipeModel,
            savedImageRecipeModel,
            isNotFavouriteRecipeModel
        ]
        mockRepository.mockRecipes = mockRecipes
        
        viewModel.loadRecipes()
        
        viewModel.filterRecipes(query: "Bur")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.viewModel.filteredRecipes.count, 1)
            XCTAssertEqual(self.viewModel.filteredRecipes.first?.name, "Burger")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testGroupRecipesByCategory() {
        let expectation = self.expectation(description: "Reload table")

        let mockRecipes = [
            unsavedImageRecipeModel,
            savedImageRecipeModel,
            isNotFavouriteRecipeModel
        ]
        mockRepository.mockRecipes = mockRecipes
        
        viewModel.loadRecipes()
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let uniqueCategories = Set(mockRecipes.map { $0.category })
            XCTAssertEqual(self.viewModel.sections.count, uniqueCategories.count)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testReloadTableDelegate() {
        let expectation = self.expectation(description: "Delegate should reload table")
        
        let mockDelegate = MockReloadTableDelegate()
        mockDelegate.onReloadData = {
            expectation.fulfill()
        }
        
        viewModel.delegate = mockDelegate
        viewModel.loadRecipes()
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testReloadSearchableTableDelegate() {
        let expectation = self.expectation(description: "Delegate should reload searchable table")

        let mockSearchResultDelegate = MockSearchResultDelegate()
        mockSearchResultDelegate.onReloadData = {
            expectation.fulfill()
        }
        
        viewModel.delegateRecipesSearchResult = mockSearchResultDelegate
        viewModel.filterRecipes(query: "Bur")
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}

private class MockReloadTableDelegate: RecipesListVMDelegate {
    var onReloadData: (() -> Void)?

    func reloadTable() {
        onReloadData?()
    }
}

private class MockSearchResultDelegate: RecipesSearchResultDelegate {
    var onReloadData: (() -> Void)?

    func reloadTable() {
        onReloadData?()
    }
}
