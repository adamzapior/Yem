//
//  CoreDataManager_Tests.swift
//  YemTests
//
//  Created by Adam Zapiór on 25/08/2024.
//

import CoreData
import XCTest
@testable import Yem

final class CoreDataManagerTests: XCTestCase {
    var coreDataManager: CoreDataManager!
    var testStack: CoreDataTestStack!

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

    override func setUp() {
        super.setUp()
        testStack = CoreDataTestStack()
        coreDataManager = CoreDataManager(persistentContainer: testStack.persistentContainer)
    }

    override func tearDown() {
        coreDataManager = nil
        testStack = nil
    
        super.tearDown()
    }

    func testBeginTransaction() {
        coreDataManager.beginTransaction()
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let undoManager = self.coreDataManager.context.undoManager
           
            XCTAssertNotNil(undoManager, "Undo manager should be set")
            XCTAssertTrue(undoManager!.isUndoing, "Undo grouping should have started")
        }
    }

    func testRollbackTransaction() {
        coreDataManager.beginTransaction()
    
        coreDataManager.rollbackTransaction()
        let undoManager = coreDataManager.context.undoManager
    
        XCTAssertNil(undoManager, "Undo manager should be nil after rollback")
    }

    func testEndTransaction() {
        coreDataManager.beginTransaction()
    
        coreDataManager.endTransaction()
        let undoManager = coreDataManager.context.undoManager
    
        XCTAssertNil(undoManager, "Undo manager should be nil after ending transaction")
    }

    func testSaveRecipe() throws {
        // Given
        let recipe = RecipeEntity(using: testStack.context)
        print("Recipe Entity: \(recipe)")
    
        recipe.name = sampleRecipe.name
        recipe.id = sampleRecipe.id
        recipe.prepTimeHours = sampleRecipe.perpTimeHours
        recipe.prepTimeMinutes = sampleRecipe.perpTimeMinutes
        recipe.servings = sampleRecipe.serving
        recipe.spicy = sampleRecipe.spicy.rawValue
        recipe.category = sampleRecipe.category.rawValue
        recipe.difficulty = sampleRecipe.difficulty.rawValue
        recipe.isImageSaved = sampleRecipe.isImageSaved
        recipe.isFavourite = sampleRecipe.isFavourite
    
        // Add ingredients
        for ingredient in sampleRecipe.ingredientList {
            let ingredientEntity = IngredientEntity(using: testStack.context)
            ingredientEntity.id = ingredient.id
            ingredientEntity.name = ingredient.name
            ingredientEntity.value = ingredient.value
            ingredientEntity.valueType = ingredient.valueType
            recipe.addToIngredients(ingredientEntity)
        }
    
        // Add instructions
        for instruction in sampleRecipe.instructionList {
            let instructionEntity = InstructionEntity(using: testStack.context)
            instructionEntity.id = instruction.id
            instructionEntity.indexPath = instruction.index
            instructionEntity.text = instruction.text
            recipe.addToInstructions(instructionEntity)
        }
    
        print("Recipe Entity: \(recipe)")

        // Zapis do kontekstu
        do {
            try testStack.context.save()
        } catch {
            XCTFail("Failed to save context: \(error)")
        }

        let fetchRequest: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        let fetchedRecipes = try testStack.context.fetch(fetchRequest)
    
        // Verify that the saved recipe exists in the fetched results
        XCTAssertEqual(fetchedRecipes.count, 1, "There should be exactly one recipe in the database")
        guard let fetchedRecipe = fetchedRecipes.first else {
            XCTFail("No recipes were fetched")
            return
        }
    
        XCTAssertEqual(fetchedRecipe.name, sampleRecipe.name, "The recipe name should match")
        XCTAssertEqual(fetchedRecipe.prepTimeHours, sampleRecipe.perpTimeHours, "The preparation hours should match")
        XCTAssertEqual(fetchedRecipe.prepTimeMinutes, sampleRecipe.perpTimeMinutes, "The preparation minutes should match")
        XCTAssertEqual(fetchedRecipe.servings, sampleRecipe.serving, "The servings should match")
        XCTAssertEqual(fetchedRecipe.spicy, sampleRecipe.spicy.rawValue, "The spiciness level should match")
        XCTAssertEqual(fetchedRecipe.category, sampleRecipe.category.rawValue, "The category should match")
        XCTAssertEqual(fetchedRecipe.difficulty, sampleRecipe.difficulty.rawValue, "The difficulty level should match")
        XCTAssertEqual(fetchedRecipe.isImageSaved, sampleRecipe.isImageSaved, "The image saved flag should match")
        XCTAssertEqual(fetchedRecipe.isFavourite, sampleRecipe.isFavourite, "The favourite flag should match")
    }

    func testFetchRecipesWithName() {
        guard let context = testStack.context else {
            XCTFail("Context is not available")
            return
        }

        let recipe = RecipeEntity(context: context)
        recipe.name = "Unique Recipe"
        recipe.id = sampleRecipe.id
        recipe.prepTimeHours = sampleRecipe.perpTimeHours
        recipe.prepTimeMinutes = sampleRecipe.perpTimeMinutes
        recipe.servings = sampleRecipe.serving
        recipe.spicy = sampleRecipe.spicy.rawValue
        recipe.category = sampleRecipe.category.rawValue
        recipe.difficulty = sampleRecipe.difficulty.rawValue
        recipe.isImageSaved = sampleRecipe.isImageSaved
        recipe.isFavourite = sampleRecipe.isFavourite
    
        for ingredient in sampleRecipe.ingredientList {
            let ingredientEntity = IngredientEntity(context: context)
            ingredientEntity.id = ingredient.id
            ingredientEntity.name = ingredient.name
            ingredientEntity.value = ingredient.value
            ingredientEntity.valueType = ingredient.valueType
            recipe.addToIngredients(ingredientEntity)
        }
    
        for instruction in sampleRecipe.instructionList {
            let instructionEntity = InstructionEntity(context: context)
            instructionEntity.id = instruction.id
            instructionEntity.indexPath = instruction.index
            instructionEntity.text = instruction.text
            recipe.addToInstructions(instructionEntity)
        }
    
        do {
            try testStack.context.save()
        } catch {
            XCTFail("Failed to save context: \(error)")
        }

        let recipes = try? coreDataManager.fetchRecipesWithName("Unique Recipe")
    
        XCTAssertEqual(recipes?.count, 1, "There should be exactly one recipe with the name 'Unique Recipe'")
    }

    func testFetchShopingList() {
        let item = ShopingListEntity(using: testStack.context)
        item.name = "Test Item"
        item.isChecked = true
        item.id = UUID()
        item.value = "1"
        item.valueType = "kg"
    
        coreDataManager.saveContext()

        let items = try? coreDataManager.fetchShopingList(isChecked: true)
    
        XCTAssertEqual(items?.count, 1, "There should be exactly one item in the shopping list with isChecked = true")
    }
}
