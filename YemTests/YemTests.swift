//
//  YemTests.swift
//  YemTests
//
//  Created by Adam Zapiór on 05/12/2023.
//

import XCTest
@testable import Yem

final class YemTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

//class MockDataRepository: DataRepositoryProtocol {
//    func fetchAllRecipes() async -> Result<[Yem.RecipeEntity], Yem.DataRepositoryError> {
//        //
//    }
//    
//    func searchByQuery() {
//        //
//    }
//    
//    func delete() {
//        //
//    }
//    
//    var saveShouldSucceed = true
//    var didCallSave = false
//    var didCallBeginTransaction = false
//    var didCallEndTransaction = false
//    var didCallRollbackTransaction = false
//
//    func save() {
//        didCallSave = true
//        if !saveShouldSucceed {
////            throw DataRepositoryError.saveError
//        }
//    }
//
//    func beginTransaction() {
//        didCallBeginTransaction = true
//    }
//    
//    func endTransaction() {
//        didCallEndTransaction = true
//    }
//
//    func rollbackTransaction() {
//        didCallRollbackTransaction = true
//    }
//
//    // Implementacja pozostałych metod interfejsu...
//}
//
//
//
//class AddRecipeViewModelTests: XCTestCase {
//    var viewModel: AddRecipeViewModel!
//    var mockRepository: MockDataRepository!
//
//    override func setUp() {
//        super.setUp()
//        mockRepository = MockDataRepository()
//        viewModel = AddRecipeViewModel(repository: mockRepository)
//    }
//
//    override func tearDown() {
//        viewModel = nil
//        mockRepository = nil
//        super.tearDown()
//    }
//
//    func testSaveRecipeSuccess() {
//        mockRepository.saveShouldSucceed = true
//        viewModel.recipeTitle = "Test Recipe" // Ustaw pozostałe właściwości, jeśli są wymagane
//
//        viewModel.saveRecipe()
//
//        XCTAssertTrue(mockRepository.didCallSave, "Save should be called")
//        XCTAssertTrue(mockRepository.didCallBeginTransaction, "Begin transaction should be called")
//        XCTAssertTrue(mockRepository.didCallEndTransaction, "End transaction should be called")
//        XCTAssertFalse(mockRepository.didCallRollbackTransaction, "Rollback transaction should not be called")
//    }
//
//    func testSaveRecipeFailure() {
//        mockRepository.saveShouldSucceed = false
//        viewModel.recipeTitle = "Test Recipe" // Ustaw pozostałe właściwości, jeśli są wymagane
//
//        viewModel.saveRecipe()
//
//        XCTAssertTrue(mockRepository.didCallSave, "Save should be called")
//        XCTAssertTrue(mockRepository.didCallBeginTransaction, "Begin transaction should be called")
//        XCTAssertFalse(mockRepository.didCallEndTransaction, "End transaction should not be called")
//        XCTAssertTrue(mockRepository.didCallRollbackTransaction, "Rollback transaction should be called")
//    }
//}

