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

// Mock Delegates
class MockCookingModeVCDelegate: CookingModeVCDelegate {
    var timerStartedCalled = false
    var timerStoppedCalled = false

    func timerStarted() {
        timerStartedCalled = true
    }

    func timerStopped() {
        timerStoppedCalled = true
    }
}

class MockCookingIngredientsListSheetVCDelegate: CookingIngredientsListSheetVCDelegate {
    var reloadTableCalled = false
    var timerStoppedWhenIngredientSheetOpenCalled = false

    func reloadTable() {
        reloadTableCalled = true
    }

    func timerStoppedWhenIngredientSheetOpen() {
        timerStoppedWhenIngredientSheetOpenCalled = true
    }
}

class MockCookingTimerSheetVCDelegate: CookingTimerSheetVCDelegate {
    var timerStoppedWhenTimerSheetOpenCalled = false

    func timerStoppedWhenTimerSheetOpen() {
        timerStoppedWhenTimerSheetOpenCalled = true
    }
}

class CookingModeViewModelTests: XCTestCase {
    var viewModel: CookingModeViewModel!
    var mockDelegate: MockCookingModeVCDelegate!
    var mockIngredientDelegate: MockCookingIngredientsListSheetVCDelegate!
    var mockTimerDelegate: MockCookingTimerSheetVCDelegate!
    var mockRepository: MockDataRepository!

    override func setUp() {
        super.setUp()
        mockDelegate = MockCookingModeVCDelegate()
        mockIngredientDelegate = MockCookingIngredientsListSheetVCDelegate()
        mockTimerDelegate = MockCookingTimerSheetVCDelegate()
        mockRepository = MockDataRepository()

        let sampleRecipe = RecipeModel(
            id: UUID(),
            name: "Spicy Vegan Tacos",
            serving: "4",
            perpTimeHours: "0",
            perpTimeMinutes: "45",
            spicy: .hot,
            category: .vegan,
            difficulty: .medium,
            ingredientList: [
                IngredientModel(id: UUID(), value: "2", valueType: IngredientValueType.unit.rawValue, name: "Avocado"),
                IngredientModel(id: UUID(), value: "200", valueType: IngredientValueType.grams.rawValue, name: "Black Beans"),
                IngredientModel(id: UUID(), value: "150", valueType: IngredientValueType.grams.rawValue, name: "Corn"),
                IngredientModel(id: UUID(), value: "1", valueType: IngredientValueType.unit.rawValue, name: "Onion"),
                IngredientModel(id: UUID(), value: "2", valueType: IngredientValueType.tablespoons.rawValue, name: "Olive Oil"),
                IngredientModel(id: UUID(), value: "1", valueType: IngredientValueType.teaspoons.rawValue, name: "Cumin"),
                IngredientModel(id: UUID(), value: "1", valueType: IngredientValueType.teaspoons.rawValue, name: "Chili Powder"),
                IngredientModel(id: UUID(), value: "8", valueType: IngredientValueType.unit.rawValue, name: "Taco Shells"),
                IngredientModel(id: UUID(), value: "1", valueType: IngredientValueType.unit.rawValue, name: "Lime"),
                IngredientModel(id: UUID(), value: "A pinch", valueType: IngredientValueType.pinch.rawValue, name: "Salt")
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
        viewModel.delegate = mockDelegate
        viewModel.delegateIngredientSheet = mockIngredientDelegate
        viewModel.delegateTimerSheet = mockTimerDelegate
    }

    override func tearDown() {
        viewModel = nil
        mockDelegate = nil
        mockIngredientDelegate = nil
        mockTimerDelegate = nil
        mockRepository = nil
        super.tearDown()
    }

    func testStartTimerWithValidTime() {
        let expectation = self.expectation(description: "Timer should start")

        viewModel.hours = 0
        viewModel.minutes = 1
        viewModel.seconds = 30

        viewModel.startTimer()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.mockDelegate.timerStartedCalled)

            XCTAssertNotNil(self.viewModel.timerPublisher)

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testStartTimerWithZeroTime() {
        viewModel.hours = 0
        viewModel.minutes = 0
        viewModel.seconds = 0

        viewModel.startTimer()

        XCTAssertFalse(mockDelegate.timerStartedCalled)
        XCTAssertNil(viewModel.timer)
    }

    func testUpdateTimerFinishesAndNotifiesDelegates() {
        let expectation = self.expectation(description: "Timer should be stopped")

        viewModel.startTimer(with: 1)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            XCTAssertTrue(self.mockDelegate.timerStartedCalled)
            XCTAssertTrue(self.mockDelegate.timerStoppedCalled)
            XCTAssertTrue(self.mockIngredientDelegate.timerStoppedWhenIngredientSheetOpenCalled)
            XCTAssertTrue(self.mockTimerDelegate.timerStoppedWhenTimerSheetOpenCalled)

            expectation.fulfill()
        }

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
        // Given
        var ingredient = ShopingListModel(
            id: UUID(),
            isChecked: false,
            name: "Sugar",
            value: "1",
            valueType: "kg"
        )

        viewModel.uncheckedList = [ingredient]
        viewModel.checkedList = []

        // When
        viewModel.updateIngredientCheckStatus(ingredient: &ingredient)

        // Then
        let expectation = self.expectation(description: "reloadTable should be called")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            XCTAssertTrue(ingredient.isChecked, "Ingredient should be checked")
            XCTAssertTrue(
                self.viewModel.checkedList.contains(where: { $0.id == ingredient.id }),
                "Ingredient should be moved to checked list"
            )
            XCTAssertFalse(
                viewModel.uncheckedList.contains(where: { $0.id == ingredient.id }),
                "Ingredient should be removed from unchecked list"
            )
            XCTAssertTrue(self.mockIngredientDelegate.reloadTableCalled)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testUpdateIngredientCheckStatusMovesToUnchecked() {
        // Given
        var ingredient = ShopingListModel(
            id: UUID(),
            isChecked: false,
            name: "Sugar",
            value: "1",
            valueType: "kg"
        )

        viewModel.checkedList = [ingredient]
        viewModel.uncheckedList = []

        // When
        viewModel.updateIngredientCheckStatus(ingredient: &ingredient)

        // Then
        let expectation = self.expectation(description: "reloadTable should be called")
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
            XCTAssertTrue(self.mockIngredientDelegate.reloadTableCalled)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
