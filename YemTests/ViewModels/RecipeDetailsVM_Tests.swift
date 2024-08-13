//
//  RecipeDetailsVM_Tests.swift
//  YemTests
//
//  Created by Adam Zapiór on 11/08/2024.
//

import XCTest
@testable import Yem

final class RecipeDetailsVM_Tests: XCTestCase {
    var viewModel: RecipeDetailsVM!
    var mockRepository: MockDataRepository!
    var mockLocalFileManager: MockLocalFileManager!
    var imageFetcher: MockImageFetcherManager!

    private let unsavedImageRecipeModel = RecipeModel(
        id: UUID(),
        name: "Burger",
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
        category: RecipeCategory(rawValue: RecipeCategory.appetizers.displayName) ?? .notSelected,
        difficulty: RecipeDifficulty(rawValue: RecipeDifficulty.medium.displayName) ?? .medium,
        ingredientList: [IngredientModel(id: UUID(), value: "200", valueType: "g", name: "Flour")],
        instructionList: [InstructionModel(id: UUID(), index: 1, text: "Mix the ingredients")],
        isImageSaved: true,
        isFavourite: true
    )
    
    private let isNotFavouriteRecipeModel = RecipeModel(
        id: UUID(),
        name: "Burger",
        serving: "1",
        perpTimeHours: "1",
        perpTimeMinutes: "0",
        spicy: RecipeSpicy(rawValue: RecipeSpicy.mild.displayName) ?? .medium,
        category: RecipeCategory(rawValue: RecipeCategory.appetizers.displayName) ?? .notSelected,
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
        imageFetcher = MockImageFetcherManager(stubbedImage: UIImage.testImage())

        viewModel = RecipeDetailsVM(
            recipe: unsavedImageRecipeModel,
            repository: mockRepository,
            localFileManager: mockLocalFileManager,
            imageFetcher: imageFetcher
        )
    }

    override func tearDown() {
        super.tearDown()

        // Delete file created in testLoadRecipeImage_WhenImageIsSavedAndUrlIsValid_ShouldFetchImage
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let testImageURL = documentsDirectory.appendingPathComponent("testImage.jpg")

        if fileManager.fileExists(atPath: testImageURL.path) {
            try? fileManager.removeItem(at: testImageURL)
        }
        
        mockRepository = nil
        mockLocalFileManager = nil
        imageFetcher = nil
        viewModel = nil
    }
    
    // MARK: - loadRecipeImage

    func testLoadRecipeImage_WhenImageIsNotSaved_ShouldReturnNil() {
        let recipe = unsavedImageRecipeModel
        let expectation = self.expectation(description: "Image load completion")

        viewModel.loadRecipeImage(recipe: recipe) { image in
            XCTAssertNil(image)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testLoadRecipeImage_WhenImageIsSavedAndUrlIsValid_ShouldFetchImage() {
        // Create a temporary file
        let stubbedImageURL = createTemporaryImageFile()

        // Set the URL in the mock
        mockLocalFileManager.testImageUrl = stubbedImageURL

        // Assign the stubbed image to the fetcher
        let stubbedImage = UIImage.testImage()
        imageFetcher.stubbedImage = stubbedImage

        let expectation = self.expectation(description: "Image load completion")

        viewModel.loadRecipeImage(recipe: savedImageRecipeModel) { image in
            let actualImageData = image?.pngData()
            let expectedImageData = stubbedImage.pngData()

            XCTAssertEqual(actualImageData, expectedImageData)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testLoadRecipeImage_WhenImageUrlIsNil_ShouldReturnNil() {
        let recipe = unsavedImageRecipeModel
        mockLocalFileManager.testImageUrl = nil

        let expectation = self.expectation(description: "Image load completion")

        viewModel.loadRecipeImage(recipe: recipe) { image in
            XCTAssertNil(image)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // MARK: - toggleFavouriteStatus

    
    func testToggleFavouriteStatus() {
        // Given
        viewModel.recipe = isNotFavouriteRecipeModel
        
        // When
        viewModel.toggleFavouriteStatus()
        
        // Then
        XCTAssertTrue(viewModel.isFavourite)
        XCTAssertTrue(mockRepository.isUpdateRecipeCalled)
    }

    
    // MARK: - addIngredientsToShopingList

    func testAddIngredientsToShopingList() {
        // Given
        XCTAssertTrue(mockRepository.uncheckedItems.isEmpty)
       
        viewModel.recipe = unsavedImageRecipeModel
        
        // When
        viewModel.addIngredientsToShopingList()
        
        // Then
        XCTAssertEqual(mockRepository.uncheckedItems.count, 1)
        XCTAssertEqual(mockRepository.uncheckedItems.first?.name, "Flour")
    }
    
    // MARK: - deleteRecipe
    
    func testDeleteRecipe() {
        // Given
        mockRepository.mockRecipes.append(unsavedImageRecipeModel)
        
        // When
        viewModel.deleteRecipe()
        
        // Then
        XCTAssertTrue(mockRepository.mockRecipes.isEmpty)
    }

    
}

    // MARK: - Helper Methods

extension RecipeDetailsVM_Tests {
    func createTemporaryImageFile() -> URL {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let testImageURL = documentsDirectory.appendingPathComponent("testImage.jpg")

        // Tworzenie i zapisywanie tymczasowego pliku
        let testImage = UIImage.testImage()
        if let data = testImage.jpegData(compressionQuality: 0.5) {
            try? data.write(to: testImageURL)
        }

        return testImageURL
    }
}

extension UIImage {
    static func testImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 100, height: 100))
        UIColor.red.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
