//
//  ShopingListVM_Tests.swift
//  YemTests
//
//  Created by Adam Zapiór on 10/08/2024.
//

import XCTest
@testable import Yem

final class ShopingListVM_Tests: XCTestCase {
    var viewModel: ShopingListVM!
    var mockRepository: MockDataRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockDataRepository()
        viewModel = ShopingListVM(repository: mockRepository)
    }

    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }

    func testLoadShopingList_LoadsDataAndReloadsTable() {
        let testableUUID = UUID(uuidString: "12345678-1234-1234-1234-1234567890ab")!

        // Given data
        let uncheckedItems = [
            ShopingListModel(id: testableUUID, isChecked: false, name: "Milk", value: "1", valueType: "L")
        ]
        let checkedItems = [
            ShopingListModel(id: testableUUID, isChecked: true, name: "Bread", value: "2", valueType: "pcs")
        ]

        // When
        mockRepository.uncheckedItems = uncheckedItems
        mockRepository.checkedItems = checkedItems

        viewModel.loadShopingList()

        // Then
        XCTAssertEqual(viewModel.uncheckedList.count, uncheckedItems.count)
        for (index, item) in viewModel.uncheckedList.enumerated() {
            XCTAssertEqual(item.id, uncheckedItems[index].id)
            XCTAssertEqual(item.isChecked, uncheckedItems[index].isChecked)
            XCTAssertEqual(item.name, uncheckedItems[index].name)
            XCTAssertEqual(item.value, uncheckedItems[index].value)
            XCTAssertEqual(item.valueType, uncheckedItems[index].valueType)
        }

        XCTAssertEqual(viewModel.checkedList.count, checkedItems.count)
        for (index, item) in viewModel.checkedList.enumerated() {
            XCTAssertEqual(item.id, checkedItems[index].id)
            XCTAssertEqual(item.isChecked, checkedItems[index].isChecked)
            XCTAssertEqual(item.name, checkedItems[index].name)
            XCTAssertEqual(item.value, checkedItems[index].value)
            XCTAssertEqual(item.valueType, checkedItems[index].valueType)
        }
    }

    func testUpdateIngredientCheckStatus_UpdatesCheckStatusAndReloadsTable() {
        // Given
        var ingredient = ShopingListModel(id: UUID(), isChecked: false, name: "Sugar", value: "1", valueType: "kg")

        viewModel.uncheckedList = [ingredient]
        viewModel.checkedList = []

        // When
        viewModel.updateIngredientCheckStatus(ingredient: &ingredient)

        // Then
        XCTAssertTrue(ingredient.isChecked, "Ingredient should be checked")
        XCTAssertTrue(viewModel.checkedList.contains(where: { $0.id == ingredient.id }), "Ingredient should be moved to checked list")
        XCTAssertFalse(viewModel.uncheckedList.contains(where: { $0.id == ingredient.id }), "Ingredient should be removed from unchecked list")
    }

    func testClearShopingList_ClearsListAndReloadsTable() {
        // Given
        viewModel.uncheckedList = [ShopingListModel(id: UUID(), isChecked: false, name: "Milk", value: "1", valueType: "L")]
        viewModel.checkedList = [ShopingListModel(id: UUID(), isChecked: true, name: "Bread", value: "2", valueType: "pcs")]

        // When
//        viewModel.uncheckedList = []
//        viewModel.checkedList = []
        viewModel.clearShopingList()

        // Then
//        XCTAssertTrue(viewModel.uncheckedList.isEmpty, "Unchecked list should be empty")
//        XCTAssertTrue(viewModel.checkedList.isEmpty, "Checked list should be empty")
        XCTAssertTrue(mockRepository.clearShopingListCalled, "clearShopingList should be called on the repository")
    }

    func testHasIngredientValidationErrors_ReturnsTrue() {
        viewModel.ingredientNameIsError = false
        viewModel.ingredientValueIsError = false
        viewModel.ingredientValueTypeIsError = false

        let result = viewModel.hasIngredientValidationErrors()

        XCTAssertFalse(result)
    }

    func testHasIngredientValidationErrors_ReturnsFalse() {
        let scenarios: [(description: String,
                         initialValues: (ingredientNameIsError: Bool,
                                         ingredientValueIsError: Bool,
                                         ingredientValueTypeIsError: Bool),
                         expectedResult: Bool)] = [
            (
                "1: All errors are false",
                (
                    ingredientNameIsError: false,
                    ingredientValueIsError: false,
                    ingredientValueTypeIsError: false
                ),
                expectedResult: false
            ),
            (
                "2: Only ingredientNameIsError is true",
                (
                    ingredientNameIsError: true,
                    ingredientValueIsError: false,
                    ingredientValueTypeIsError: false
                ),
                expectedResult: true
            ),
            (
                "3: Only ingredientValueIsError is true",
                (
                    ingredientNameIsError: false,
                    ingredientValueIsError: true,
                    ingredientValueTypeIsError: false
                ),
                expectedResult: true
            ),
            (
                "4: Only ingredientValueTypeIsError is true",
                (
                    ingredientNameIsError: false,
                    ingredientValueIsError: false,
                    ingredientValueTypeIsError: true
                ),
                expectedResult: true
            )
        ]

        for scenario in scenarios {
            print("Running scenario: \(scenario.description)")

            viewModel.ingredientNameIsError = scenario.initialValues.ingredientNameIsError
            viewModel.ingredientValueIsError = scenario.initialValues.ingredientValueIsError
            viewModel.ingredientValueTypeIsError = scenario.initialValues.ingredientValueTypeIsError

            let result = viewModel.hasIngredientValidationErrors()

            XCTAssertEqual(result, scenario.expectedResult, "Unexpected result for scenario: \(scenario.description)")
        }
    }

    func testAddIngredientToList() {
        let scenarios: [(name: String,
                         value: String,
                         valueType: String,
                         expectedNameError: Bool,
                         expectedValueError: Bool,
                         expectedValueTypeError: Bool,
                         expectedResult: Bool)] = [
            ("", "2", "Unit", true, false, false, false),
            ("Tomato", "", "pieces", false, true, true, false),
            ("Tomato", "2", "", false, false, true, false),
            ("", "", "", true, true, true, false),
            ("Milk", "1", "Unit", false, false, false, true),
            ("Bread", "2", "Cups (c)", false, false, false, true)
        ]

        for scenario in scenarios {
            viewModel.ingredientName = scenario.name
            viewModel.ingredientValue = scenario.value
            viewModel.ingredientValueType = scenario.valueType

            let result = viewModel.addIngredientToList()
            viewModel.loadShopingList()

            print("DEBUG: Walidacja flag - Name: \(viewModel.ingredientNameIsError), Value: \(viewModel.ingredientValueIsError), ValueType: \(viewModel.ingredientValueTypeIsError), Result: \(result)")
            print("DEBUG: Lista nieprzeczekanych składników: \(viewModel.uncheckedList)")

            XCTAssertEqual(viewModel.ingredientNameIsError, scenario.expectedNameError, "Name validation failed for scenario: \(scenario)")
            XCTAssertEqual(viewModel.ingredientValueIsError, scenario.expectedValueError, "Value validation failed for scenario: \(scenario)")
            XCTAssertEqual(viewModel.ingredientValueTypeIsError, scenario.expectedValueTypeError, "ValueType validation failed for scenario: \(scenario)")

            XCTAssertEqual(result, scenario.expectedResult, "Result failed for scenario: \(scenario)")

            for list in viewModel.uncheckedList {
                print(list.name)
            }

            if scenario.expectedResult {
                XCTAssertEqual(viewModel.uncheckedList.count, 1, "Ingredient should be added for scenario: \(scenario)")
            } else {
                XCTAssertEqual(viewModel.uncheckedList.count, 0, "Ingredient should not be added for scenario: \(scenario)")
            }

            // Prepre for next scenario
            mockRepository.uncheckedItems.removeAll()
        }
    }
}
