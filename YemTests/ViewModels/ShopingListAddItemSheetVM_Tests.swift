//
//  ShopingListAddItemSheetVM_Tests.swift
//  YemTests
//
//  Created by Adam Zapiór on 14/09/2024.
//

import Foundation

import Combine
import XCTest
@testable import Yem

final class ShopingListAddItemSheetVM_Tests: XCTestCase {
    var viewModel: ShopingListAddItemSheetVM!
    var mockRepository: MockDataRepository!

    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        mockRepository = MockDataRepository()
        viewModel = ShopingListAddItemSheetVM(repository: mockRepository)
    }

    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    func testHasIngredientValidationErrors() {
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
            print("DEBUG: Running scenario: \(scenario.description)")

            viewModel.ingredientNameIsError = scenario.initialValues.ingredientNameIsError
            viewModel.ingredientValueIsError = scenario.initialValues.ingredientValueIsError
            viewModel.ingredientValueTypeIsError = scenario.initialValues.ingredientValueTypeIsError

            let result = viewModel.hasValidationErrors()

            XCTAssertEqual(result, scenario.expectedResult, "Unexpected result for scenario: \(scenario.description)")
        }
    }
    
    
    func testAddIngredientToShoppingList() {
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

            do {
                try viewModel.addIngredientToShoppingList()

                XCTAssertEqual(viewModel.ingredientNameIsError, scenario.expectedNameError, "Name validation failed for scenario: \(scenario)")
                XCTAssertEqual(viewModel.ingredientValueIsError, scenario.expectedValueError, "Value validation failed for scenario: \(scenario)")
                XCTAssertEqual(viewModel.ingredientValueTypeIsError, scenario.expectedValueTypeError, "ValueType validation failed for scenario: \(scenario)")
                
                XCTAssertEqual(mockRepository.uncheckedItems.first?.name, viewModel.ingredientName)
                XCTAssertEqual(mockRepository.uncheckedItems.first?.value, viewModel.ingredientValue)
                XCTAssertEqual(mockRepository.uncheckedItems.first?.valueType, viewModel.ingredientValueType)
                
            } catch let error as ShopingListAddItemSheetVM.ValidationErrors {
                print("DEBUG: Caught validation error: \(error.errors)")
                XCTAssertEqual(error.errors.contains(.invalidName), scenario.expectedNameError, "Name validation error mismatch for scenario: \(scenario)")
                XCTAssertEqual(error.errors.contains(.invalidValue), scenario.expectedValueError, "Value validation error mismatch for scenario: \(scenario)")
                XCTAssertEqual(error.errors.contains(.invalidValueType), scenario.expectedValueTypeError, "ValueType validation error mismatch for scenario: \(scenario)")
            } catch {
                XCTFail("Unexpected error: \(error)")
            }

            mockRepository.uncheckedItems.removeAll()
        }
    }
}
