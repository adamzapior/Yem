//
//  ShopingListVM_Tests.swift
//  YemTests
//
//  Created by Adam Zapiór on 10/08/2024.
//

import Combine
import XCTest
@testable import Yem

final class ShopingListVM_Tests: XCTestCase {
    var viewModel: ShopingListVM!
    var mockRepository: MockDataRepository!

    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        mockRepository = MockDataRepository()
        viewModel = ShopingListVM(repository: mockRepository)
    }

    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        cancellables.removeAll()
        super.tearDown()
    }

    func testLoadShopingList_LoadsDataAndReloadsTable() async {
        let expectation = expectation(description: "Load shopping list")
        expectation.expectedFulfillmentCount = 2 // We expect two events: initialDataFetched and reloadTable

        let testableUUID = UUID(uuidString: "12345678-1234-1234-1234-1234567890ab")!

        // Given data
        let uncheckedItems = [
            ShopingListModel(id: testableUUID, isChecked: false, name: "Milk", value: "1", valueType: "L")
        ]
        let checkedItems = [
            ShopingListModel(id: testableUUID, isChecked: true, name: "Bread", value: "2", valueType: "pcs")
        ]

        // Set up mock repository
        mockRepository.uncheckedItems = uncheckedItems
        mockRepository.checkedItems = checkedItems

        // Set up event listener
        viewModel.outputPublisher
            .sink { event in
                switch event {
                case .initialDataFetched, .reloadTable:
                    expectation.fulfill()
                default:
                    break
                }
            }
            .store(in: &cancellables)

        // Tested method
        viewModel.loadShopingList()

        await fulfillment(of: [expectation], timeout: 5.0)

        XCTAssertEqual(viewModel.uncheckedList.count, uncheckedItems.count)
        XCTAssertEqual(viewModel.checkedList.count, checkedItems.count)

        for (index, item) in viewModel.uncheckedList.enumerated() {
            XCTAssertEqual(item.id, uncheckedItems[index].id)
            XCTAssertEqual(item.isChecked, uncheckedItems[index].isChecked)
            XCTAssertEqual(item.name, uncheckedItems[index].name)
            XCTAssertEqual(item.value, uncheckedItems[index].value)
            XCTAssertEqual(item.valueType, uncheckedItems[index].valueType)
        }

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
        let expectation = XCTestExpectation(description: "List should be empty")
        // Given
        mockRepository.uncheckedItems = [ShopingListModel(id: UUID(), isChecked: false, name: "Milk", value: "1", valueType: "L")]
        mockRepository.checkedItems = [ShopingListModel(id: UUID(), isChecked: true, name: "Bread", value: "2", valueType: "pcs")]

        viewModel.clearShopingList()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }

        // Then
        XCTAssertTrue(viewModel.uncheckedList.isEmpty, "Unchecked list should be empty")
        XCTAssertTrue(viewModel.checkedList.isEmpty, "Checked list should be empty")

        // Result
        wait(for: [expectation], timeout: 1.0) // Wait for the async call
    }
}
