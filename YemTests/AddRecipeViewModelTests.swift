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

    override func setUp() {
        super.setUp()
        mockRepository = MockDataRepository()
        viewModel = AddRecipeViewModel(repository: mockRepository)
    }

    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Add ingredient and instruction to list methods

    func testAddIngredientToListValidation() {
        let scenarios: [(name: String,
                         value: String,
                         valueType: String,
                         expectedNameError: Bool,
                         expectedValueError: Bool,
                         expectedValueTypeError: Bool,
                         expectedResult: Bool)] = [
            ("", "2", "pieces", true, false, false, false),
            ("Tomato", "", "pieces", false, true, false, false),
            ("Tomato", "2", "", false, false, true, false),
            ("", "", "", true, true, true, false)
        ]

        for scenario in scenarios {
            viewModel.ingredientName = scenario.name
            viewModel.ingredientValue = scenario.value
            viewModel.ingredientValueType = scenario.valueType

            let result = viewModel.addIngredientToList()

            XCTAssertEqual(viewModel.ingredientNameIsError, scenario.expectedNameError, "Name validation failed for scenario: \(scenario)")
            XCTAssertEqual(viewModel.ingredientValueIsError, scenario.expectedValueError, "Value validation failed for scenario: \(scenario)")
            XCTAssertEqual(viewModel.ingredientValueTypeIsError, scenario.expectedValueTypeError, "ValueType validation failed for scenario: \(scenario)")

            XCTAssertEqual(result, scenario.expectedResult, "Result failed for scenario: \(scenario)")

            if scenario.expectedResult {
                XCTAssertEqual(viewModel.ingredientsList.count, 1, "Ingredient should be added for scenario: \(scenario)")
            } else {
                XCTAssertEqual(viewModel.ingredientsList.count, 0, "Ingredient should not be added for scenario: \(scenario)")
            }

            // Prepre for next scenario
            viewModel.ingredientsList.removeAll()
        }
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
        let scenarios: [(initialInstructions: [InstructionModel], expectedIndexes: [Int])] = [
            (
                // 1: Unsorted index
                [
                    InstructionModel(id: UUID(), index: 3, text: "Chop the tomatoes."),
                    InstructionModel(id: UUID(), index: 5, text: "Heat the oil."),
                    InstructionModel(id: UUID(), index: 1, text: "Mix the ingredients.")
                ],
                [1, 2, 3] // Expected result
            ),
            (
                // 2: Sorted index
                [
                    InstructionModel(id: UUID(), index: 1, text: "Mix the ingredients."),
                    InstructionModel(id: UUID(), index: 2, text: "Heat the oil."),
                    InstructionModel(id: UUID(), index: 3, text: "Chop the tomatoes.")
                ],
                [1, 2, 3] // Expected result
            ),
            (
                // 3: Same indexes
                [
                    InstructionModel(id: UUID(), index: 2, text: "Chop the tomatoes."),
                    InstructionModel(id: UUID(), index: 2, text: "Heat the oil."),
                    InstructionModel(id: UUID(), index: 2, text: "Mix the ingredients.")
                ],
                [1, 2, 3] // Expected result
            ),
            (
                // 4: Empty list
                [],
                [] // Expected result
            )
        ]

        for scenario in scenarios {
            viewModel.instructionList = scenario.initialInstructions

            viewModel.updateInstructionIndexes()

            for (index, expectedIndex) in scenario.expectedIndexes.enumerated() {
                XCTAssertEqual(viewModel.instructionList[index].index, expectedIndex, "Index failed for scenario with initial instructions: \(scenario.initialInstructions)")
            }

            XCTAssertEqual(viewModel.instructionList.count, scenario.expectedIndexes.count, "Instruction list count failed for scenario with initial instructions: \(scenario.initialInstructions)")
        }
    }

    func testRemoveIngredientFromList() {
        let scenarios: [(initialIngredients: [IngredientModel], removeAtIndex: Int, expectedIngredients: [String])] = [
            (
                // 1: Delete 2nd ingredient
                [
                    IngredientModel(id: UUID(), value: "2", valueType: "pieces", name: "Tomato"),
                    IngredientModel(id: UUID(), value: "3", valueType: "pieces", name: "Ketchup"),
                    IngredientModel(id: UUID(), value: "1", valueType: "cloves", name: "Garlic")
                ],
                1, // Index to delete
                ["Tomato", "Garlic"] // Expected ingredients
            ),
            (
                // 2: Delete 1st ingredient
                [
                    IngredientModel(id: UUID(), value: "2", valueType: "pieces", name: "Tomato"),
                    IngredientModel(id: UUID(), value: "3", valueType: "pieces", name: "Ketchup"),
                    IngredientModel(id: UUID(), value: "1", valueType: "cloves", name: "Garlic")
                ],
                0, // Index to delete
                ["Ketchup", "Garlic"] // Expected ingredients
            ),
            (
                // 3: Delete last ingredient
                [
                    IngredientModel(id: UUID(), value: "2", valueType: "pieces", name: "Tomato"),
                    IngredientModel(id: UUID(), value: "3", valueType: "pieces", name: "Ketchup"),
                    IngredientModel(id: UUID(), value: "1", valueType: "cloves", name: "Garlic")
                ],
                2, // Index to delete
                ["Tomato", "Ketchup"] // Expected ingredients
            ),
            (
                // 4: Delete instruction with incorrect index
                [
                    IngredientModel(id: UUID(), value: "2", valueType: "pieces", name: "Tomato"),
                    IngredientModel(id: UUID(), value: "3", valueType: "pieces", name: "Ketchup")
                ],
                3, // Index to delete
                ["Tomato", "Ketchup"] // Expected ingredients
            ),
            (
                // 5: Removing the only ingredient
                [
                    IngredientModel(id: UUID(), value: "2", valueType: "pieces", name: "Tomato")
                ],
                0, // Index to delete
                [] // // Expected ingredients
            ),
            (
                // 6: Removing ingredient form empty list
                [],
                0, // Index to delete
                [] // // Expected ingredients
            )
        ]

        for scenario in scenarios {
            viewModel.ingredientsList = scenario.initialIngredients

            viewModel.removeIngredientFromList(at: scenario.removeAtIndex)

            XCTAssertEqual(viewModel.ingredientsList.count, scenario.expectedIngredients.count,
                           "Ingredient list count failed for scenario with initial ingredients: \(scenario.initialIngredients) and removeAtIndex: \(scenario.removeAtIndex)")

            for (index, expectedName) in scenario.expectedIngredients.enumerated() {
                XCTAssertEqual(viewModel.ingredientsList[index].name, expectedName,
                               "Ingredient name failed for scenario with initial ingredients: \(scenario.initialIngredients) and removeAtIndex: \(scenario.removeAtIndex)")
            }
        }
    }

    func testRemoveInstructionFromList() {
        let scenarios: [(initialInstructions: [InstructionModel], removeAtIndex: Int, expectedInstructions: [String])] = [
            (
                // 1: Delete first instruction
                [
                    InstructionModel(id: UUID(), index: 1, text: "Chop the tomatoes."),
                    InstructionModel(id: UUID(), index: 2, text: "Heat the oil."),
                    InstructionModel(id: UUID(), index: 3, text: "Mix the ingredients.")
                ],
                0, // Index to delete
                ["Heat the oil.", "Mix the ingredients."] // Expected result
            ),
            (
                // 2: Delete last instruction
                [
                    InstructionModel(id: UUID(), index: 1, text: "Chop the tomatoes."),
                    InstructionModel(id: UUID(), index: 2, text: "Heat the oil."),
                    InstructionModel(id: UUID(), index: 3, text: "Mix the ingredients.")
                ],
                2, // Index to delete
                ["Chop the tomatoes.", "Heat the oil."] // Expected result
            ),
            (
                // 3: Invalid index
                [
                    InstructionModel(id: UUID(), index: 1, text: "Chop the tomatoes."),
                    InstructionModel(id: UUID(), index: 2, text: "Heat the oil.")
                ],
                3, // Index to delete
                ["Chop the tomatoes.", "Heat the oil."] // Expected result
            ),
            (
                // 4: Removing the only instruction
                [
                    InstructionModel(id: UUID(), index: 1, text: "Chop the tomatoes.")
                ],
                0, // Index to delete
                [] // Expected result
            ),
            (
                // 5: Removing instruction from empty list
                [],
                0, // Index to delete
                [] // Expected result
            )
        ]

        for scenario in scenarios {
            viewModel.instructionList = scenario.initialInstructions

            viewModel.removeInstructionFromList(at: scenario.removeAtIndex)

            // Chceck out instructionList with scenario
            XCTAssertEqual(viewModel.instructionList.count, scenario.expectedInstructions.count, "Instruction list count failed for scenario with initial instructions: \(scenario.initialInstructions) and removeAtIndex: \(scenario.removeAtIndex)")

            for (index, expectedText) in scenario.expectedInstructions.enumerated() {
                XCTAssertEqual(viewModel.instructionList[index].text, expectedText, "Instruction text failed for scenario with initial instructions: \(scenario.initialInstructions) and removeAtIndex: \(scenario.removeAtIndex)")
            }
        }
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

    func testSaveRecipe() {
        let scenarios: [(description: String,
                         initialValues: (recipeID: UUID,
                                         title: String,
                                         serving: String,
                                         prepTimeHours: String,
                                         prepTimeMinutes: String,
                                         spicy: String,
                                         category: String,
                                         difficulty: String,
                                         ingredientsList: [IngredientModel],
                                         instructionList: [InstructionModel],
                                         isFavourite: Bool,
                                         selectedImage: UIImage?),
                         expectedResult: Bool,
                         expectedValidationErrorsCount: Int,
                         mockRecipeExists: Bool,
                         mockSaveSuccess: Bool,
                         isAddRecipeCalled: Bool,
                         isUpdateRecipeCalled: Bool)] = [
            (
                // Scenario 1: Validation errors - insufficient information
                "Save Recipe With Validation Errors",
                (
                    recipeID: UUID(),
                    title: "ABC",
                    serving: "",
                    prepTimeHours: "",
                    prepTimeMinutes: "",
                    spicy: "",
                    category: "Easy",
                    difficulty: "",
                    ingredientsList: [],
                    instructionList: [],
                    isFavourite: false,
                    selectedImage: nil
                ),
                false, // Expected function result
                7, // Expected number of validation errors
                false, // Does the recipe exist in the repository?
                false, // Should the save to the repository succeed?
                false, // Should the add recipe method in the repository be called?
                false // Should the update recipe method in the repository be called?
            ),
            (
                // Scenario 2: Successfully saving a new recipe
                "Add New Recipe Successfully",
                (
                    recipeID: UUID(),
                    title: "Test Recipe",
                    serving: "2",
                    prepTimeHours: "0",
                    prepTimeMinutes: "30",
                    spicy: "Mild",
                    category: "Dinner",
                    difficulty: "Easy",
                    ingredientsList: [
                        IngredientModel(id: UUID(), value: "200", valueType: "g", name: "Flour")
                    ],
                    instructionList: [
                        InstructionModel(id: UUID(), index: 1, text: "Mix the ingredients")
                    ],
                    isFavourite: false,
                    selectedImage: nil
                ),
                true, // Expected function result
                0, // Expected number of validation errors
                false, // Does the recipe exist in the repository?
                true, // Should the save to the repository succeed?
                true, // Should the add recipe method in the repository be called?
                false // Should the update recipe method in the repository be called?
            ),
            (
                // Scenario 3: Successfully updating an existing recipe
                "Update Existing Recipe Successfully",
                (
                    recipeID: UUID(), // Unique recipe ID
                    title: "Test Recipe",
                    serving: "2",
                    prepTimeHours: "15",
                    prepTimeMinutes: "30",
                    spicy: "Mild",
                    category: "Dinner",
                    difficulty: "Easy",
                    ingredientsList: [
                        IngredientModel(id: UUID(), value: "200", valueType: "grams", name: "Flour")
                    ],
                    instructionList: [
                        InstructionModel(id: UUID(), index: 1, text: "Mix the ingredients")
                    ],
                    isFavourite: false,
                    selectedImage: nil
                ),
                true, // Expected function result
                0, // Expected number of validation errors
                true, // Does the recipe exist in the repository?
                true, // Should the save to the repository succeed?
                false, // Should the add recipe method in the repository be called?
                true // Should the update recipe method in the repository be called?
            )
        ]

        for scenario in scenarios {
            print("Running scenario: \(scenario.description)")

            viewModel.recipeID = scenario.initialValues.recipeID
            viewModel.recipeTitle = scenario.initialValues.title
            viewModel.serving = scenario.initialValues.serving
            viewModel.prepTimeHours = scenario.initialValues.prepTimeHours
            viewModel.prepTimeMinutes = scenario.initialValues.prepTimeMinutes
            viewModel.spicy = scenario.initialValues.spicy
            viewModel.category = scenario.initialValues.category
            viewModel.difficulty = scenario.initialValues.difficulty
            viewModel.ingredientsList = scenario.initialValues.ingredientsList
            viewModel.instructionList = scenario.initialValues.instructionList
            viewModel.isFavourite = scenario.initialValues.isFavourite
            viewModel.selectedImage = scenario.initialValues.selectedImage

            // Setting up mock repository success or failure simulation
            mockRepository.mockRecipeExists = scenario.mockRecipeExists
            mockRepository.mockSaveSuccess = scenario.mockSaveSuccess

            // Calling the saveRecipe method
            let result = viewModel.saveRecipe()

            // Checking the function result
            XCTAssertEqual(result, scenario.expectedResult, "Failed on scenario: \(scenario.description)")

            // Checking the number of validation errors
            XCTAssertEqual(viewModel.validationErrors.count, scenario.expectedValidationErrorsCount, "Validation error count mismatch on scenario: \(scenario.description)")

            // Checking if the add recipe method in the repository was called
            XCTAssertEqual(mockRepository.isAddRecipeCalled, scenario.isAddRecipeCalled, "Repository method call mismatch on scenario: \(scenario.description)")

            // Checking if the update recipe method in the repository was called
            XCTAssertEqual(mockRepository.isUpdateRecipeCalled, scenario.isUpdateRecipeCalled, "Repository update method call mismatch on scenario: \(scenario.description)")

            // Prepare for the next loop iteration
            mockRepository.mockRecipeExists = false
            mockRepository.mockSaveSuccess = false
            mockRepository.isAddRecipeCalled = false
            mockRepository.isUpdateRecipeCalled = false
        }
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

    func testValidationErrors() {
        let validationScenarios: [(field: String, setError: () -> Void)] = [
            // Empty fields
            ("Title", { self.viewModel.recipeTitle = "" }),
            ("Serving", { self.viewModel.serving = "" }),
            ("PrepTimeHours", { self.viewModel.prepTimeHours = "" }),
            ("PrepTimeMinutes", { self.viewModel.prepTimeMinutes = "" }),
            ("Spicy", { self.viewModel.spicy = "" }),
            ("Category", { self.viewModel.category = "" }),
            ("Difficulty", { self.viewModel.difficulty = "" }),
            ("Ingredients", { self.viewModel.ingredientsList = [] }),
            ("Instructions", { self.viewModel.instructionList = [] }),

//            // Invalid numbers
//            ("Serving - negative", { self.viewModel.serving = "-1" }),
//            ("PrepTimeHours - negative", { self.viewModel.prepTimeHours = "-1" }),
//            ("PrepTimeMinutes - negative", { viewModel.prepTimeMinutes = "-1" }),
//            ("Serving - non-numeric", { viewModel.serving = "abc" }),
//            ("PrepTimeHours - non-numeric", { viewModel.prepTimeHours = "abc" }),
//            ("PrepTimeMinutes - non-numeric", { viewModel.prepTimeMinutes = "abc" }),

//            // Out of range values
//            ("PrepTimeMinutes - over 60", { self.viewModel.prepTimeMinutes = "61" }),
//            ("PrepTimeHours - unrealistic", { self.viewModel.prepTimeHours = "1000" }),

            // Edge cases for Ingredients and Instructions
            ("Ingredients - empty name", {
                self.viewModel.ingredientsList = [
                    IngredientModel(id: UUID(), value: "200", valueType: "g", name: "")
                ]
            }),
            ("Ingredients - negative value", {
                self.viewModel.ingredientsList = [
                    IngredientModel(id: UUID(), value: "-200", valueType: "g", name: "Flour")
                ]
            }),
            ("Ingredients - non-numeric value", {
                self.viewModel.ingredientsList = [
                    IngredientModel(id: UUID(), value: "abc", valueType: "g", name: "Flour")
                ]
            }),
            ("Instructions - empty text", {
                self.viewModel.instructionList = [
                    InstructionModel(id: UUID(), index: 1, text: "")
                ]
            }),

            // Combinations
            ("Title and Serving - both empty", {
                self.viewModel.recipeTitle = ""
                self.viewModel.serving = ""
            }),
            ("Ingredients and Instructions - both invalid", {
                self.viewModel.ingredientsList = [
                    IngredientModel(id: UUID(), value: "-200", valueType: "g", name: "")
                ]
                self.viewModel.instructionList = [
                    InstructionModel(id: UUID(), index: 1, text: "")
                ]
            })
        ]

        for scenario in validationScenarios {
            // Reset ViewModel to valid state
            setupValidRecipe()

            // Apply invalid data
            scenario.setError()

            // Check if validation detects the error
            XCTAssertFalse(viewModel.hasRecipeValidationErrors(), "\(scenario.field) validation failed")
        }
    }
}

extension AddRecipeViewModelTests {
    func setupValidRecipe() {
        viewModel.recipeID = UUID()
        viewModel.recipeTitle = "Burger"
        viewModel.serving = "1"
        viewModel.prepTimeHours = "0"
        viewModel.prepTimeMinutes = "45"
        viewModel.spicy = RecipeSpicy.medium.displayName
        viewModel.category = RecipeCategory.dinner.displayName
        viewModel.difficulty = RecipeDifficulty.easy.displayName
        viewModel.ingredientsList = [IngredientModel(id: UUID(), value: "1", valueType: IngredientValueType.kilograms.displayName, name: "Meat")]
        viewModel.instructionList = [InstructionModel(id: UUID(), index: 1, text: "Do something")]
        viewModel.isFavourite = false
        viewModel.selectedImage = nil
    }
}
