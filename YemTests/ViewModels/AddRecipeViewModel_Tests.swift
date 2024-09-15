//
//  AddRecipeViewModelTests.swift
//  YemTests
//
//  Created by Adam Zapiór on 05/08/2024.
//

import Combine
import XCTest
@testable import Yem

class AddRecipeViewModel_Tests: XCTestCase {
    var viewModel: ManageRecipeVM!
    var mockRepository: MockDataRepository!
    var mockLocalFileManager: MockLocalFileManager!
    var mockImageFetcherManager: MockImageFetcherManager!

    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        mockRepository = MockDataRepository()
        mockLocalFileManager = MockLocalFileManager()
        mockImageFetcherManager = MockImageFetcherManager(stubbedImage: nil)
        viewModel = ManageRecipeVM(
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
        cancellables.removeAll()
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
                         shouldThrow: Bool)] = [
            ("", "2", "pieces", true, false, false, true),
            ("Tomato", "", "pieces", false, true, false, true),
            ("Tomato", "2", "", false, false, true, true),
            ("", "", "", true, true, true, true),
            ("Tomato", "2", "pieces", false, false, false, false)
        ]

        for scenario in scenarios {
            viewModel.ingredientName = scenario.name
            viewModel.ingredientValue = scenario.value
            viewModel.ingredientValueType = scenario.valueType

            if scenario.shouldThrow {
                XCTAssertThrowsError(try viewModel.addIngredientToList()) { error in
                    XCTAssertTrue(error is ManageRecipeVM.ValidationError, "Unexpected error type: \(type(of: error))")
                }
            } else {
                XCTAssertNoThrow(try viewModel.addIngredientToList())
            }

            XCTAssertEqual(viewModel.ingredientNameIsError, scenario.expectedNameError, "Name validation failed for scenario: \(scenario)")
            XCTAssertEqual(viewModel.ingredientValueIsError, scenario.expectedValueError, "Value validation failed for scenario: \(scenario)")
            XCTAssertEqual(viewModel.ingredientValueTypeIsError, scenario.expectedValueTypeError, "ValueType validation failed for scenario: \(scenario)")

            if !scenario.shouldThrow {
                XCTAssertEqual(viewModel.ingredientsList.count, 1, "Ingredient should be added for scenario: \(scenario)")
            } else {
                XCTAssertEqual(viewModel.ingredientsList.count, 0, "Ingredient should not be added for scenario: \(scenario)")
            }

            viewModel.ingredientsList.removeAll()
        }
    }

    func testAddInstructiontoListSuccess() {
        // Przygotowanie
        viewModel.instruction = "Do something"

        // Działanie
        XCTAssertNoThrow(try viewModel.addInstructionToList(), "Adding instruction should not throw an error")

        // Sprawdzenie
        XCTAssertFalse(viewModel.instructionIsError, "Instruction should not have validation errors")
        XCTAssertEqual(viewModel.instructionList.count, 1, "Instruction list should have one item")

        if let addedInstruction = viewModel.instructionList.first {
            XCTAssertEqual(addedInstruction.text, "Do something", "Added instruction should have correct text")
            XCTAssertEqual(addedInstruction.index, 1, "Added instruction should have correct index")
        } else {
            XCTFail("Instruction was not added to the list")
        }

        // Sprawdzenie, czy właściwości zostały wyczyszczone
        XCTAssertTrue(viewModel.instruction.isEmpty, "Instruction property should be cleared after adding")
    }

    func testAddInstructiontoListFailure() {
        viewModel.instruction = "" // Pusty string powinien spowodować błąd walidacji

        XCTAssertThrowsError(try viewModel.addInstructionToList()) { error in
            XCTAssertTrue(error is ManageRecipeVM.ValidationError, "Unexpected error type: \(type(of: error))")
            if let validationError = error as? ManageRecipeVM.ValidationError {
                XCTAssertEqual(validationError.localizedDescription, "Add instruction to list failed")
            }
        }

        XCTAssertTrue(viewModel.instructionIsError)
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
                    IngredientModel(id: UUID(), name: "Tomato", value: "2", valueType: IngredientValueTypeModel(name: "pieces")),
                    IngredientModel(id: UUID(), name: "Ketchup", value: "3", valueType: IngredientValueTypeModel(name: "pieces")),
                    IngredientModel(id: UUID(), name: "Garlic", value: "1", valueType: IngredientValueTypeModel(name: "cloves"))
                ],
                1, // Index to delete
                ["Tomato", "Garlic"] // Expected ingredients
            ),
            (
                // 2: Delete 1st ingredient
                [
                    IngredientModel(id: UUID(), name: "Tomato", value: "2", valueType: IngredientValueTypeModel(name: "pieces")),
                    IngredientModel(id: UUID(), name: "Ketchup", value: "3", valueType: IngredientValueTypeModel(name: "pieces")),
                    IngredientModel(id: UUID(), name: "Garlic", value: "1", valueType: IngredientValueTypeModel(name: "cloves"))
                ],
                0, // Index to delete
                ["Ketchup", "Garlic"] // Expected ingredients
            ),
            (
                // 3: Delete last ingredient
                [
                    IngredientModel(id: UUID(), name: "Tomato", value: "2", valueType: IngredientValueTypeModel(name: "pieces")),
                    IngredientModel(id: UUID(), name: "Ketchup", value: "3", valueType: IngredientValueTypeModel(name: "pieces")),
                    IngredientModel(id: UUID(), name: "Garlic", value: "1", valueType: IngredientValueTypeModel(name: "cloves"))
                ],
                2, // Index to delete
                ["Tomato", "Ketchup"] // Expected ingredients
            ),
            (
                // 4: Delete instruction with incorrect index
                [
                    IngredientModel(id: UUID(), name: "Tomato", value: "2", valueType: IngredientValueTypeModel(name: "pieces")),
                    IngredientModel(id: UUID(), name: "Ketchup", value: "3", valueType: IngredientValueTypeModel(name: "pieces"))
                ],
                3, // Index to delete
                ["Tomato", "Ketchup"] // Expected ingredients
            ),
            (
                // 5: Removing the only ingredient
                [
                    IngredientModel(id: UUID(), name: "Tomato", value: "2", valueType: IngredientValueTypeModel(name: "pieces"))
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
                        IngredientModel(id: UUID(), name: "Flour", value: "200", valueType: IngredientValueTypeModel(name: "grams"))
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
                        IngredientModel(id: UUID(), name: "Flour", value: "200", valueType: IngredientValueTypeModel.grams)
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

            do {
                try viewModel.saveRecipe()
            } catch {
                // Checking the number of validation errors
                if scenario.expectedValidationErrorsCount > 0 {
                    XCTAssertEqual(viewModel.validationErrors.count, scenario.expectedValidationErrorsCount, "Validation error count mismatch on scenario: \(scenario.description)")
                } else {
                    XCTFail("Unexpected error occurred during \(scenario.description): \(error)")
                }
            }

            // Checking the number of validation errors
            XCTAssertEqual(viewModel.validationErrors.count, scenario.expectedValidationErrorsCount, "Validation error count mismatch on scenario: \(scenario.description)")

            // Checking if the add recipe method in the repository was called
            // Checking if the update recipe method in the repository was called
            XCTAssertEqual(mockRepository.isAddRecipeCalled, scenario.isAddRecipeCalled, "Repository method call mismatch on scenario: \(scenario.description)")
            XCTAssertEqual(mockRepository.isUpdateRecipeCalled, scenario.isUpdateRecipeCalled, "Repository update method call mismatch on scenario: \(scenario.description)")

            // Prepare for the next loop iteration
            mockRepository.mockRecipeExists = false
            mockRepository.mockSaveSuccess = false
            mockRepository.isAddRecipeCalled = false
            mockRepository.isUpdateRecipeCalled = false
        }
    }

    // **Scenario**
    /// Test only validation properties without validation, in default properties should be set to false
    func testHasValidationErrors_AllFieldsValid_ReturnsFalse() {
        let result = viewModel.hasRecipeValidationErrors()

        XCTAssertFalse(result)
    }

    /// **Scenario**
    /// Test only validation properties without validation, in default properties should be set to false
    /// In that case one of properties is set to true and result should return true
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
            ("Serving - negative", { self.viewModel.serving = "-1" }),
            ("PrepTimeHours - negative", { self.viewModel.prepTimeHours = "-1" }),
            ("PrepTimeMinutes - negative", { self.viewModel.prepTimeMinutes = "-1" }),
            ("Serving - non-numeric", { self.viewModel.serving = "abc" }),
            ("PrepTimeHours - non-numeric", { self.viewModel.prepTimeHours = "abc" }),
            ("PrepTimeMinutes - non-numeric", { self.viewModel.prepTimeMinutes = "abc" }),

            // Out of range values
            ("PrepTimeMinutes - over 60", { self.viewModel.prepTimeMinutes = "61" }),
            ("PrepTimeHours - unrealistic", { self.viewModel.prepTimeHours = "1000" }),

            // Edge cases for Ingredients and Instructions
            ("Ingredients - empty name", {
                self.viewModel.ingredientsList = [
                    IngredientModel(id: UUID(), name: "", value: "200", valueType: IngredientValueTypeModel(name: "g"))
                ]
            }),
            ("Ingredients - negative value", {
                self.viewModel.ingredientsList = [
                    IngredientModel(id: UUID(), name: "Flour", value: "-200", valueType: IngredientValueTypeModel(name: "g"))
                ]
            }),
            ("Ingredients - non-numeric value", {
                self.viewModel.ingredientsList = [
                    IngredientModel(id: UUID(), name: "Flour", value: "abc", valueType: IngredientValueTypeModel(name: "g"))
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
                    IngredientModel(id: UUID(), name: "", value: "-200", valueType: IngredientValueTypeModel(name: "g"))
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

    // MARK: - Test observe input & output

    /// **Scenario**
    /// Test input and output for recipe properties
    /// RecipeTitle should be trimed to max 32 characters
    func testRecipePropertiesForInputAndOutput() {
        // Expectations
        let expectationRecipeTitle = XCTestExpectation(description: "Wait for recipe title update")
        let expectationDifficulty = XCTestExpectation(description: "Wait for difficulty update")
        let expectationServings = XCTestExpectation(description: "Wait for servings update")
        let expectationPrepTime = XCTestExpectation(description: "Wait for prep time update")
        let expectationSpicy = XCTestExpectation(description: "Wait for spicy update")
        let expectationCategory = XCTestExpectation(description: "Wait for category update")

        let expectationIngredientName = XCTestExpectation(description: "Wait for ingredient name update")
        let expectationIngredientValue = XCTestExpectation(description: "Wait for ingredient value update")
        let expectationIngredientValueType = XCTestExpectation(description: "Wait ingredient value type update")

        let expectationInstruction = XCTestExpectation(description: "Wait for instruction update")

        let testedModel = RecipeModel(
            id: UUID(),
            name: "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.",
            serving: "1",
            perpTimeHours: "1",
            perpTimeMinutes: "2",
            spicy: .mild,
            category: .breakfast,
            difficulty: .easy,
            ingredientList: [IngredientModel(id: UUID(), name: "Egg", value: "1", valueType: IngredientValueTypeModel.unit)],
            instructionList: [InstructionModel(id: UUID(), index: 1, text: "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.")],
            isImageSaved: false,
            isFavourite: false
        )

        // Observed properties
        var observedRecipeTitle = ""
        var observedDifficulty = ""
        var observedServings = ""
        var observedPrepTime = ""
        var observedSpicy = ""
        var observedCategory = ""

        var observedIngredientName = ""
        var observedIngredientValue = ""
        var observedIngredientValueType = ""

        var observedInstruction = ""

        // Observe output
        viewModel.outputDetailsFormEventPublisher
            .sink { event in
                if case .updateDetailsField(let details) = event {
                    switch details {
                    case .recipeTitle(let value):
                        observedRecipeTitle = value
                        expectationRecipeTitle.fulfill()
                    case .difficulty(let value):
                        observedDifficulty = value
                        expectationDifficulty.fulfill()
                    case .servings(let value):
                        observedServings = value
                        expectationServings.fulfill()
                    case .prepTime(let prepTime):
                        switch prepTime {
                        case .hours: break
                        case .minutes: break
                        case .fullTime(let value):
                            observedPrepTime = value
                            expectationPrepTime.fulfill()
                        }
                    case .spicy(let value):
                        observedSpicy = value
                        expectationSpicy.fulfill()
                    case .category(let value):
                        observedCategory = value
                        expectationCategory.fulfill()
                    }
                }
            }
            .store(in: &cancellables)

        viewModel.outputIngredientFormEventPublisher
            .sink { event in
                if case .updateIngredientForm(let form) = event {
                    switch form {
                    case .ingredientName(let value):
                        observedIngredientName = value
                        expectationIngredientName.fulfill()
                    case .ingredientValue(let value):
                        observedIngredientValue = value
                        expectationIngredientValue.fulfill()
                    case .ingredientValueType(let value):
                        observedIngredientValueType = value
                        expectationIngredientValueType.fulfill()
                    }
                }
            }
            .store(in: &cancellables)

        viewModel.outputInstructionFormPublisher
            .sink { event in
                if case .updateInstructionValue(let string) = event {
                    observedInstruction = string
                    expectationInstruction.fulfill()
                }
            }
            .store(in: &cancellables)

        // Send input
        viewModel.inputDetailsFormEvent.send(.sendDetailsValues(.recipeTitle(testedModel.name)))
        viewModel.inputDetailsFormEvent.send(.sendDetailsValues(.difficulty(testedModel.difficulty.displayName)))

        viewModel.inputDetailsFormEvent.send(.sendDetailsValues(.prepTime(.hours(testedModel.perpTimeHours))))
        viewModel.inputDetailsFormEvent.send(.sendDetailsValues(.prepTime(.minutes(testedModel.perpTimeMinutes))))

        viewModel.inputDetailsFormEvent.send(.sendDetailsValues(.servings(testedModel.serving)))
        viewModel.inputDetailsFormEvent.send(.sendDetailsValues(.spicy(testedModel.spicy.displayName)))
        viewModel.inputDetailsFormEvent.send(.sendDetailsValues(.category(testedModel.category.displayName)))

        viewModel.inputIngredientFormEvent.send(.sendIngredientValues(.ingredientName(testedModel.ingredientList.first!.name)))
        viewModel.inputIngredientFormEvent.send(.sendIngredientValues(.ingredientValue(testedModel.ingredientList.first!.value)))
        viewModel.inputIngredientFormEvent.send(.sendIngredientValues(.ingredientValueType(testedModel.ingredientList.first!.valueType.name)))

        viewModel.inputInstructionFormEvent.send(.sendInstructionValue(testedModel.instructionList.first!.text))

        let formattedRecipeTitle = String(testedModel.name.prefix(32))
        let formattedPrepTime = RecipeModel.getPerpTimeString(testedModel)

        wait(for: [expectationRecipeTitle,
                   expectationDifficulty,
                   expectationPrepTime,
                   expectationServings,
                   expectationSpicy,
                   expectationCategory,
                   expectationIngredientName,
                   expectationIngredientValue,
                   expectationIngredientValueType,
                   expectationInstruction],
             timeout: 1.0)

        XCTAssertEqual(observedRecipeTitle, formattedRecipeTitle, "Recipe title should be trimmed to 32 characters")
        XCTAssertEqual(observedDifficulty, testedModel.difficulty.displayName, "Difficulty value is not valid")
        XCTAssertEqual(observedPrepTime, formattedPrepTime(), "Difficulty value is not valid")
        XCTAssertEqual(observedServings, testedModel.serving, "Servings value is not valid")
        XCTAssertEqual(observedSpicy, testedModel.spicy.displayName, "Spicy value is not valid")
        XCTAssertEqual(observedCategory, testedModel.category.displayName, "Category value is not valid")
        XCTAssertEqual(observedIngredientName, testedModel.ingredientList.first?.name, "Ingredient name is not valid")
        XCTAssertEqual(observedIngredientValue, testedModel.ingredientList.first?.value, "Ingredient value is not valid")
        XCTAssertEqual(observedIngredientValueType, testedModel.ingredientList.first?.valueType.name, "Ingredient value type is not valid")
        XCTAssertEqual(observedInstruction, testedModel.instructionList.first?.text, "Instruction value is not valid")
    }
}

extension AddRecipeViewModel_Tests {
    func setupValidRecipe() {
        viewModel.recipeID = UUID()
        viewModel.recipeTitle = "Burger"
        viewModel.serving = "1"
        viewModel.prepTimeHours = "0"
        viewModel.prepTimeMinutes = "45"
        viewModel.spicy = RecipeSpicyModel.medium.displayName
        viewModel.category = RecipeCategoryModel.dinner.displayName
        viewModel.difficulty = RecipeDifficultyModel.easy.displayName
        viewModel.ingredientsList = [IngredientModel(id: UUID(), name: "Meat", value: "1", valueType: IngredientValueTypeModel.grams)]
        viewModel.instructionList = [InstructionModel(id: UUID(), index: 1, text: "Do something")]
        viewModel.isFavourite = false
        viewModel.selectedImage = nil
    }
}
