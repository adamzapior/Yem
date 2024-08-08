//
//  AddRecipeViewModelTests.swift
//  YemTests
//
//  Created by Adam Zapiór on 05/08/2024.
//

import XCTest
@testable import Yem

class AddRecipeViewModelTests: XCTestCase {
    var viewModel: AddRecipeViewModel!
    var mockRepository: MockDataRepository!
//    var fileManagerMock: LocalFileManagerMock!

    let recipe = Yem.RecipeModel(id: UUID(),
                                 name: "Hamburger",
                                 serving: "1",
                                 perpTimeHours: "1",
                                 perpTimeMinutes: "0",
                                 spicy: RecipeSpicy(rawValue: "Hot") ?? .medium,
                                 category: RecipeCategory(rawValue: "Dishes") ?? .notSelected,
                                 difficulty: RecipeDifficulty(rawValue: "Easy") ?? .medium,
                                 ingredientList: [Yem.IngredientModel(id: UUID(), value: "1", valueType: "kg", name: "sugar")],
                                 instructionList: [Yem.InstructionModel(id: UUID(), index: 1, text: "Do smth")],
                                 isImageSaved: false,
                                 isFavourite: false)

    override func setUp() {
        super.setUp()
        mockRepository = MockDataRepository()
//        fileManagerMock = LocalFileManagerMock()
        viewModel = AddRecipeViewModel(repository: mockRepository)
    }

    override func tearDown() {
        viewModel = nil
        mockRepository = nil
//        fileManagerMock = nil
        super.tearDown()
    }

    // MARK: - Add ingredient and instruction to list methods

    func testAddIngredientToListSuccess() {
        viewModel.ingredientName = "Tomato"
        viewModel.ingredientValue = "2"
        viewModel.ingredientValueType = "pieces"

        let ingredientNameValidation = viewModel.ingredientNameIsError
        let ingredientValueValidation = viewModel.ingredientValueIsError
        let ingredientValueTypeValidation = viewModel.ingredientValueTypeIsError

        let result = viewModel.addIngredientToList()

        XCTAssertFalse(ingredientNameValidation)
        XCTAssertFalse(ingredientValueValidation)
        XCTAssertFalse(ingredientValueTypeValidation)

        XCTAssertTrue(result)
        XCTAssertEqual(viewModel.ingredientsList.count, 1)
        XCTAssertEqual(viewModel.ingredientsList.first!.name, "Tomato")
        XCTAssertEqual(viewModel.ingredientsList.first!.value, "2")
        XCTAssertEqual(viewModel.ingredientsList.first!.valueType, "pieces")
    }

    func testAddIngredientToListFailureEmptyName() {
        viewModel.ingredientName = ""
        viewModel.ingredientValue = "2"
        viewModel.ingredientValueType = "pieces"

        let result = viewModel.addIngredientToList()

        let ingredientNameValidation = viewModel.ingredientNameIsError
        let ingredientValueValidation = viewModel.ingredientValueIsError
        let ingredientValueTypeValidation = viewModel.ingredientValueTypeIsError

        XCTAssertTrue(ingredientNameValidation)
        XCTAssertFalse(ingredientValueValidation)
        XCTAssertFalse(ingredientValueTypeValidation)

        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.ingredientsList.count, 0)
    }

    func testAddIngredientToListFailureEmptyValue() {
        viewModel.ingredientName = "Tomato"
        viewModel.ingredientValue = ""
        viewModel.ingredientValueType = "pieces"

        let result = viewModel.addIngredientToList()

        let ingredientNameValidation = viewModel.ingredientNameIsError
        let ingredientValueValidation = viewModel.ingredientValueIsError
        let ingredientValueTypeValidation = viewModel.ingredientValueTypeIsError

        XCTAssertFalse(ingredientNameValidation)
        XCTAssertTrue(ingredientValueValidation)
        XCTAssertFalse(ingredientValueTypeValidation)

        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.ingredientsList.count, 0)
    }

    func testAddIngredientToListFailureEmptyValueType() {
        viewModel.ingredientName = "Tomato"
        viewModel.ingredientValue = "2"
        viewModel.ingredientValueType = ""

        let result = viewModel.addIngredientToList()

        let ingredientNameValidation = viewModel.ingredientNameIsError
        let ingredientValueValidation = viewModel.ingredientValueIsError
        let ingredientValueTypeValidation = viewModel.ingredientValueTypeIsError

        XCTAssertFalse(ingredientNameValidation)
        XCTAssertFalse(ingredientValueValidation)
        XCTAssertTrue(ingredientValueTypeValidation)

        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.ingredientsList.count, 0)
    }

    func testAddIngredientToListFailureAllEmpty() {
        viewModel.ingredientName = ""
        viewModel.ingredientValue = ""
        viewModel.ingredientValueType = ""

        let result = viewModel.addIngredientToList()

        let ingredientNameValidation = viewModel.ingredientNameIsError
        let ingredientValueValidation = viewModel.ingredientValueIsError
        let ingredientValueTypeValidation = viewModel.ingredientValueTypeIsError

        XCTAssertTrue(ingredientNameValidation)
        XCTAssertTrue(ingredientValueValidation)
        XCTAssertTrue(ingredientValueTypeValidation)

        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.ingredientsList.count, 0)
    }

    func testAddInstructiontoListSuccess() {
        viewModel.instruction = "Do smth"

        let result = viewModel.addInstructionToList()

        let instructionValidation = viewModel.instructionIsError

        XCTAssertFalse(instructionValidation)

        XCTAssertTrue(result)
        XCTAssertEqual(viewModel.instructionList.count, 1)
    }

    func testAddInstructiontoListFailure() {
        viewModel.instruction = ""

        let result = viewModel.addInstructionToList()

        let instructionValidation = viewModel.instructionIsError

        XCTAssertTrue(instructionValidation)

        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.instructionList.count, 0)
    }

    func testUpdateInstructionIndexes() {
        viewModel.instructionList = [
            InstructionModel(id: UUID(), index: 3, text: "Chop the tomatoes."),
            InstructionModel(id: UUID(), index: 5, text: "Heat the oil."),
            InstructionModel(id: UUID(), index: 1, text: "Mix the ingredients.")
        ]

        viewModel.updateInstructionIndexes()

        XCTAssertEqual(viewModel.instructionList[0].index, 1)
        XCTAssertEqual(viewModel.instructionList[1].index, 2)
        XCTAssertEqual(viewModel.instructionList[2].index, 3)
    }

    func testRemoveIngredientFromList() {
        viewModel.ingredientsList = [
            IngredientModel(id: UUID(), value: "2", valueType: "pieces", name: "Tomato"),
            IngredientModel(id: UUID(), value: "3", valueType: "pieces", name: "Ketchup"),
            IngredientModel(id: UUID(), value: "1", valueType: "cloves", name: "Garlic")
        ]

        viewModel.removeIngredientFromList(at: 1)

        XCTAssertEqual(viewModel.ingredientsList.count, 2)
        XCTAssertEqual(viewModel.ingredientsList[0].name, "Tomato")
        XCTAssertEqual(viewModel.ingredientsList[1].name, "Garlic")
    }

    func testRemoveIngredientFromListInvalidIndex() {
        viewModel.ingredientsList = [
            IngredientModel(id: UUID(), value: "2", valueType: "pieces", name: "Tomato"),
            IngredientModel(id: UUID(), value: "3", valueType: "pieces", name: "Ketchup")
        ]

        viewModel.removeIngredientFromList(at: 3)

        XCTAssertEqual(viewModel.ingredientsList.count, 2)
    }

    func testRemoveInstructionFromList() {
        // Przygotowanie listy instrukcji
        viewModel.instructionList = [
            InstructionModel(id: UUID(), index: 1, text: "Chop the tomatoes."),
            InstructionModel(id: UUID(), index: 2, text: "Heat the oil."),
            InstructionModel(id: UUID(), index: 3, text: "Mix the ingredients.")
        ]

        viewModel.removeInstructionFromList(at: 0)

        XCTAssertEqual(viewModel.instructionList.count, 2)
        XCTAssertEqual(viewModel.instructionList[0].text, "Heat the oil.")
        XCTAssertEqual(viewModel.instructionList[1].text, "Mix the ingredients.")
    }

    func testRemoveInstructionFromListInvalidIndex() {
        viewModel.instructionList = [
            InstructionModel(id: UUID(), index: 1, text: "Chop the tomatoes."),
            InstructionModel(id: UUID(), index: 2, text: "Heat the oil.")
        ]

        viewModel.removeInstructionFromList(at: 3)

        XCTAssertEqual(viewModel.instructionList.count, 2)
    }

    // MARK: Recipe validation and saving methods

    func testDoesRecipeExist_ExistingRecipe_ReturnsTrue() {
        let existingId = UUID()
        mockRepository.mockRecipeExists = true

        let result = viewModel.doesRecipeExist(id: existingId)

        XCTAssertTrue(result)
    }

    func testDoesRecipeExist_NonExistingRecipe_ReturnsFalse() {
        let nonExistingId = UUID()
        mockRepository.mockRecipeExists = false

        let result = viewModel.doesRecipeExist(id: nonExistingId)

        XCTAssertFalse(result)
    }

    func testSaveRecipe_WithValidationErrors_ReturnsFalse() {
        viewModel.recipeTitle = "ABC"
        viewModel.category = "Easy"

        let result = viewModel.saveRecipe()

        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.validationErrors.count, 6)

//        for i in viewModel.validationErrors {
//            print(i.description)
//        }
    }

    func testSaveRecipe_AddNewRecipe_Success() {
        viewModel.recipeID = UUID() // Unique recipe ID
        viewModel.recipeTitle = "Test Recipe"
        viewModel.serving = "2"
        viewModel.prepTimeHours = "0"
        viewModel.prepTimeMinutes = "30"
        viewModel.spicy = "Mild"
        viewModel.category = "Main Course"
        viewModel.difficulty = "Easy"
        viewModel.ingredientsList = [
            IngredientModel(id: UUID(), value: "200", valueType: "g", name: "Flour")
        ]
        viewModel.instructionList = [
            InstructionModel(id: UUID(), index: 1, text: "Mix the ingredients")
        ]
        viewModel.isFavourite = false
        viewModel.selectedImage = nil

        mockRepository.mockSaveSuccess = true

        let result = viewModel.saveRecipe()

        XCTAssertTrue(result)
        XCTAssertTrue(mockRepository.isAddRecipeCalled)
    }

    func testSaveRecipe_UpdateRecipe_Success() {
        viewModel.recipeID = UUID() // Unique recipe ID
        viewModel.recipeTitle = "Test Recipe"
        viewModel.serving = "2"
        viewModel.prepTimeHours = "0"
        viewModel.prepTimeMinutes = "30"
        viewModel.spicy = "Mild"
        viewModel.category = "Main Course"
        viewModel.difficulty = "Easy"
        viewModel.ingredientsList = [
            IngredientModel(id: UUID(), value: "200", valueType: "g", name: "Flour")
        ]
        viewModel.instructionList = [
            InstructionModel(id: UUID(), index: 1, text: "Mix the ingredients")
        ]
        viewModel.isFavourite = false
        viewModel.selectedImage = nil

        mockRepository.mockRecipeExists = true
        mockRepository.mockSaveSuccess = true

        let result = viewModel.saveRecipe()

        XCTAssertTrue(result)
        XCTAssertTrue(mockRepository.isUpdateRecipeCalled)
    }

    func testHasValidationErrors_AllFieldsValid_ReturnsFalse() {
        let result = viewModel.hasRecipeValidationErrors()

        XCTAssertFalse(result)
    }

    func testHasValidationErrors_WithErrors_ReturnsTrue() {
        viewModel.recipeTitleIsError = true
        let result = viewModel.hasRecipeValidationErrors()

        XCTAssertTrue(result)
    }
}
