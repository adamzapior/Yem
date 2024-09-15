//
//  CookingModeViewModel_Tests.swift
//  YemTests
//
//  Created by Adam Zapiór on 24/08/2024.
//

import Combine
import Foundation
import XCTest

@testable import Yem

class CookingModeViewModelTests: XCTestCase {
    var viewModel: CookingModeViewModel!
    var mockRepository: MockDataRepository!

    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()

        mockRepository = MockDataRepository()

        let sampleRecipe = RecipeModel(
            id: UUID(),
            name: "Spicy Vegan Tacos",
            serving: "4",
            prepTimeHours: "0",
            prepTimeMinutes: "45",
            spicy: .hot,
            category: .vegan,
            difficulty: .medium,
            ingredientList: [
                IngredientModel(id: UUID(), name: "Avocado", value: "2", valueType: IngredientValueTypeModel.unit),
                IngredientModel(id: UUID(), name: "Black Beans", value: "200", valueType: IngredientValueTypeModel.grams),
                IngredientModel(id: UUID(), name: "Corn", value: "150", valueType: IngredientValueTypeModel.grams),
                IngredientModel(id: UUID(), name: "Onion", value: "1", valueType: IngredientValueTypeModel.unit),
                IngredientModel(id: UUID(), name: "Olive Oil", value: "2", valueType: IngredientValueTypeModel.tablespoons),
                IngredientModel(id: UUID(), name: "Cumin", value: "1", valueType: IngredientValueTypeModel.pinch),
                IngredientModel(id: UUID(), name: "Chili Powder", value: "1", valueType: IngredientValueTypeModel.pinch),
                IngredientModel(id: UUID(), name: "Taco Shells", value: "8", valueType: IngredientValueTypeModel.unit),
                IngredientModel(id: UUID(), name: "Lime", value: "1", valueType: IngredientValueTypeModel.unit),
                IngredientModel(id: UUID(), name: "Salt", value: "1", valueType: IngredientValueTypeModel.pinch)
            ],
            instructionList: [
                InstructionModel(id: UUID(), index: 1, text: "Chop the avocado, onion, and prepare other ingredients."),
                InstructionModel(id: UUID(), index: 2, text: "Heat olive oil in a pan over medium heat."),
                InstructionModel(id: UUID(), index: 3, text: "Add chopped onion and sauté until translucent. Add chopped onion and sauté until translucent. Add chopped onion and sauté until translucent. Add chopped onion and sauté until translucent. Add chopped onion and sauté until translucent. Add chopped onion and sauté until translucent."),
                InstructionModel(id: UUID(), index: 4, text: "Add black beans, corn, cumin, and chili powder. Stir well."),
                InstructionModel(id: UUID(), index: 5, text: "Cook for 10 minutes until the flavors blend together."),
                InstructionModel(id: UUID(), index: 6, text: "Warm the taco shells in the oven or microwave."),
                InstructionModel(id: UUID(), index: 7, text: "Fill the taco shells with the cooked mixture."),
                InstructionModel(id: UUID(), index: 8, text: "Top with avocado slices and a squeeze of lime."),
                InstructionModel(id: UUID(), index: 9, text: "Serve immediately with additional lime wedges on the side.")
            ],
            isImageSaved: true,
            isFavourite: false
        )

        viewModel = CookingModeViewModel(recipe: sampleRecipe, repository: mockRepository)
    }

    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        cancellables.removeAll()

        super.tearDown()
    }

    // TODO: to fix

    func testStartTimerWithValidTime() {
        let expectation = self.expectation(description: "Timer should start")

        viewModel.hours = 0
        viewModel.minutes = 1
        viewModel.seconds = 30

        viewModel.startTimer()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(self.viewModel.timerPublisher)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testStartTimerWithZeroTime() {
        let expectation = self.expectation(description: "Timer shouldn't start")

        viewModel.hours = 0
        viewModel.minutes = 0
        viewModel.seconds = 0

        viewModel.startTimer()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNil(self.viewModel.timerPublisher)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testTimerFinishedAndPublisherCalled() {
        let cookingModeScreenExpectation = expectation(description: "Timer in main cooking mode screen should be stopped")
        let cookingIngredientsListSheetExpectation = expectation(description: "Timer in main cooking mode screen should be stopped")
        let cookingTimerSheetExpectation = expectation(description: "Timer in main cooking mode screen should be stopped")

        // Set up publisher
        // In that case we need to test 3 publishers for every screen in cooking mode

        viewModel.outputCookingModePublisher
            .sink { event in
                if case .timerStopped = event {
                    cookingModeScreenExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.outputCookingIngredientsListSheetPublisher
            .sink { event in
                if case .timerStopped = event {
                    cookingIngredientsListSheetExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.outputCookingTimerSheetPublisher
            .sink { event in
                if case .timerStopped = event {
                    cookingTimerSheetExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Start tested method
        viewModel.startTimer(with: 3)

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testClearPickerVariablesResetsTime() {
        viewModel.hours = 2
        viewModel.minutes = 30
        viewModel.seconds = 45

        viewModel.clearPickerVariables()

        XCTAssertEqual(viewModel.hours, 0)
        XCTAssertEqual(viewModel.minutes, 0)
        XCTAssertEqual(viewModel.seconds, 0)
    }

    func testUpdateIngredientCheckStatusMovesToChecked() {
        let expectation = self.expectation(description: "ReloadTable should be called")

        // Set up ingredient
        var ingredient = ShopingListModel(
            id: UUID(),
            isChecked: false,
            name: "Sugar",
            value: "1",
            valueType: "kg"
        )

        viewModel.uncheckedList = [ingredient]
        viewModel.checkedList = []

        // Set up publisher
        viewModel.outputCookingIngredientsListSheetPublisher
            .sink { event in
                if case .reloadIngredientTable = event {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Call tested method
        viewModel.updateIngredientCheckStatus(ingredient: &ingredient)

        // Test result
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            XCTAssertTrue(ingredient.isChecked, "Ingredient should be checked")
            XCTAssertTrue(
                self.viewModel.checkedList.contains(where: { $0.id == ingredient.id }),
                "Ingredient should be moved to checked list"
            )
            XCTAssertFalse(
                viewModel.uncheckedList.contains(where: { $0.id == ingredient.id }),
                "Ingredient should be removed from unchecked list"
            )
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testUpdateIngredientCheckStatusMovesToUnchecked() {
        let expectation = self.expectation(description: "ReloadTable should be called")

        // Set up ingredient
        var ingredient = ShopingListModel(
            id: UUID(),
            isChecked: false,
            name: "Sugar",
            value: "1",
            valueType: "kg"
        )

        viewModel.checkedList = [ingredient]
        viewModel.uncheckedList = []

        // Set up publisher
        viewModel.outputCookingIngredientsListSheetPublisher
            .sink { event in
                if case .reloadIngredientTable = event {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Call tested method
        viewModel.updateIngredientCheckStatus(ingredient: &ingredient)

        // Test result
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            XCTAssertFalse(ingredient.isChecked, "Ingredient should be checked")
            XCTAssertTrue(
                self.viewModel.uncheckedList.contains(where: { $0.id == ingredient.id }),
                "Ingredient should be moved to unchecked list"
            )
            XCTAssertFalse(
                viewModel.checkedList.contains(where: { $0.id == ingredient.id }),
                "Ingredient should be removed from checked list"
            )
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
