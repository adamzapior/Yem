//
//  RecipeDetailsVM_Tests.swift
//  YemTests
//
//  Created by Adam Zapiór on 11/08/2024.
//

import Combine
import XCTest
@testable import Yem

final class RecipeDetailsVM_Tests: XCTestCase {
    var viewModel: RecipeDetailsVM!
    var mockRepository: MockDataRepository!
    var mockLocalFileManager: MockLocalFileManager!
    var imageFetcher: MockImageFetcherManager!

    var cancellables = Set<AnyCancellable>()

    private let unsavedImageRecipeModel = RecipeModel(
        id: UUID(),
        name: "Burger",
        serving: "1",
        prepTimeHours: "1",
        prepTimeMinutes: "0",
        spicy: RecipeSpicyModel(value: RecipeSpicyModel.mild.displayName),
        category: RecipeCategoryModel(value: RecipeCategoryModel.appetizers.displayName),
        difficulty: RecipeDifficultyModel(value: RecipeDifficultyModel.medium.displayName),
        ingredientList: [IngredientModel(id: UUID(), name: "Flour", value: "200", valueType: IngredientValueTypeModel.grams)],
        instructionList: [InstructionModel(id: UUID(), index: 1, text: "Mix the ingredients")],
        isImageSaved: false,
        isFavourite: true
    )

    private let savedImageRecipeModel = RecipeModel(
        id: UUID(),
        name: "Burger",
        serving: "1",
        prepTimeHours: "1",
        prepTimeMinutes: "0",
        spicy: RecipeSpicyModel(value: RecipeSpicyModel.mild.displayName),
        category: RecipeCategoryModel(value: RecipeCategoryModel.appetizers.displayName),
        difficulty: RecipeDifficultyModel(value: RecipeDifficultyModel.medium.displayName),
        ingredientList: [IngredientModel(id: UUID(), name: "Flour", value: "200", valueType: IngredientValueTypeModel.grams)],
        instructionList: [InstructionModel(id: UUID(), index: 1, text: "Mix the ingredients")],
        isImageSaved: true,
        isFavourite: true
    )

    private let isNotFavouriteRecipeModel = RecipeModel(
        id: UUID(),
        name: "Burger",
        serving: "1",
        prepTimeHours: "1",
        prepTimeMinutes: "0",
        spicy: RecipeSpicyModel(value: RecipeSpicyModel.mild.displayName),
        category: RecipeCategoryModel(value: RecipeCategoryModel.appetizers.displayName),
        difficulty: RecipeDifficultyModel(value: RecipeDifficultyModel.medium.displayName),
        ingredientList: [IngredientModel(id: UUID(), name: "Flour", value: "200", valueType: IngredientValueTypeModel.grams)],
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

    func testToggleFavouriteStatus() {
        let expectation = XCTestExpectation(description: "Favourite status should toggle")
        viewModel.recipe = isNotFavouriteRecipeModel

        // Tested method
        viewModel.toggleFavouriteStatus()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }

        // Result
        wait(for: [expectation], timeout: 1.0) // Wait for the async call
        XCTAssertTrue(viewModel.recipe.isFavourite)
    }

    // MARK: - addIngredientsToShopingList

    func testAddIngredientsToShopingList() {
        XCTAssertTrue(mockRepository.uncheckedItems.isEmpty)

        viewModel.recipe = unsavedImageRecipeModel

        viewModel.addIngredientsToShopingList()

        XCTAssertEqual(mockRepository.uncheckedItems.count, 1)
        XCTAssertEqual(mockRepository.uncheckedItems.first?.name, "Flour")
    }

    // MARK: - deleteRecipe

    func testDeleteRecipe() {
        mockRepository.mockRecipes.append(unsavedImageRecipeModel)

        viewModel.deleteRecipe()

        XCTAssertTrue(mockRepository.mockRecipes.isEmpty)
    }
}

// MARK: - Helper Methods

extension RecipeDetailsVM_Tests {
    func createTemporaryImageFile() -> URL {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let testImageURL = documentsDirectory.appendingPathComponent("testImage.jpg")

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
