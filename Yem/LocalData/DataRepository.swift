//
//  DataRepository.swift
//  Yem
//
//  Created by Adam Zapiór on 17/01/2024.
//

import Combine
import CoreData
import Foundation
import LifetimeTracker

protocol DataRepositoryProtocol {
    // Publishers
    var recipesInsertedPublisher: PassthroughSubject<ObjectChange, Never> { get }
    var recipesDeletedPublisher: PassthroughSubject<ObjectChange, Never> { get }
    var recipesUpdatedPublisher: PassthroughSubject<ObjectChange, Never> { get }
    var shopingListPublisher: PassthroughSubject<ObjectChange, Never> { get }

    // Transaction managment
    func beginTransaction()
    func endTransaction()
    func rollbackTransaction()
    
    // Saving methods
    func commitTransaction() throws 

    // Recipe operations
    func doesRecipeExist(with id: UUID) -> Bool
    func addRecipe(recipe: RecipeModel) throws
    func updateRecipe(recipe: RecipeModel) throws
    func updateRecipeFavouriteStatus(recipeId: UUID, isFavourite: Bool) throws
    func deleteRecipe(withId id: UUID) throws

    // Fetch data
    func fetchAllRecipes() throws -> [RecipeModel]
    func fetchRecipesWithName(_ name: String) throws -> [RecipeModel]?
    func fetchShopingList(isChecked: Bool) throws -> [ShopingListModel]

    // Shoping list operations
    func updateShopingList(shopingList: ShopingListModel) throws
    func clearShopingList() throws
    func addIngredientsToShopingList(ingredients: [IngredientModel]) throws
}

final class DataRepository: DataRepositoryProtocol {
    let moc: CoreDataManagerProtocol

    var recipesInsertedPublisher = PassthroughSubject<ObjectChange, Never>()
    var recipesDeletedPublisher = PassthroughSubject<ObjectChange, Never>()
    var recipesUpdatedPublisher = PassthroughSubject<ObjectChange, Never>()
    var shopingListPublisher = PassthroughSubject<ObjectChange, Never>()

    var cancellables = Set<AnyCancellable>()

    init(moc: CoreDataManagerProtocol) {
        self.moc = moc

        observeCoreDateChanges()

#if DEBUG
        trackLifetime()
#endif
    }

    // MARK: - Transaction Management

    func beginTransaction() {
        moc.beginTransaction()
    }

    func endTransaction() {
        moc.endTransaction()
    }

    func rollbackTransaction() {
        moc.rollbackTransaction()
    }

    // MARK: - Recipe operations

    func doesRecipeExist(with id: UUID) -> Bool {
        let fetchRequest: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1

        do {
            let count = try moc.context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("DEBUG: Error checking if recipe exists: \(error)")
            return false
        }
    }

    func addRecipe(recipe: RecipeModel) throws {
        let data = RecipeEntity(context: moc.context)
        data.id = recipe.id
        data.name = recipe.name
        data.servings = recipe.serving
        data.prepTimeHours = recipe.prepTimeHours
        data.prepTimeMinutes = recipe.prepTimeMinutes
        data.spicy = recipe.spicy.displayName
        data.category = recipe.category.displayName
        data.difficulty = recipe.difficulty.displayName
        data.isImageSaved = recipe.isImageSaved
        data.isFavourite = recipe.isFavourite

        let ingredientEntities = recipe.ingredientList.map { ingredientModel -> IngredientEntity in
            let ingredientEntity = IngredientEntity(context: moc.context)
            ingredientEntity.id = ingredientModel.id
            ingredientEntity.name = ingredientModel.name
            ingredientEntity.value = ingredientModel.value
            ingredientEntity.valueType = ingredientModel.valueType.name
            return ingredientEntity
        }

        data.ingredients = Set(ingredientEntities)

        let instructionEntities = recipe.instructionList.map { instructionModel -> InstructionEntity in
            let entity = InstructionEntity(context: moc.context)
            entity.id = UUID()
            entity.indexPath = instructionModel.index
            entity.text = instructionModel.text
            return entity
        }

        data.instructions = Set(instructionEntities)
    }

    func updateRecipe(recipe: RecipeModel) throws {
        let fetchRequest: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", recipe.id as CVarArg)

        do {
            let results = try moc.context.fetch(fetchRequest)
            guard let recipeToUpdate = results.first else {
                throw DataRepositoryError.entityNotFound
            }

            recipeToUpdate.name = recipe.name
            recipeToUpdate.servings = recipe.serving
            recipeToUpdate.prepTimeHours = recipe.prepTimeHours
            recipeToUpdate.prepTimeMinutes = recipe.prepTimeMinutes
            recipeToUpdate.spicy = recipe.spicy.displayName
            recipeToUpdate.category = recipe.category.displayName
            recipeToUpdate.difficulty = recipe.difficulty.displayName
            recipeToUpdate.isImageSaved = recipe.isImageSaved
            recipeToUpdate.isFavourite = recipe.isFavourite

            recipeToUpdate.ingredients = Set(recipe.ingredientList.map { ingredientModel -> IngredientEntity in
                let ingredientEntity = IngredientEntity(context: moc.context)
                ingredientEntity.id = ingredientModel.id
                ingredientEntity.name = ingredientModel.name
                ingredientEntity.value = ingredientModel.value
                ingredientEntity.valueType = ingredientModel.valueType.name
                return ingredientEntity
            })

            recipeToUpdate.instructions = Set(recipe.instructionList.map { instructionModel -> InstructionEntity in
                let entity = InstructionEntity(context: moc.context)
                entity.id = UUID()
                entity.indexPath = instructionModel.index
                entity.text = instructionModel.text
                return entity
            })
//
//            try saveContext()
//        } catch let error as DataRepositoryError {
//            throw error
//        } catch {
//            throw DataRepositoryError.failedToFetchData(error)
        }
    }
    
    func commitTransaction() throws {
        do {
            try saveContext()
        } catch {
            throw error
        }
    }

    func updateRecipeFavouriteStatus(recipeId: UUID, isFavourite: Bool) throws {
        let fetchRequest: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", recipeId as CVarArg)

        guard let recipeToUpdate = try moc.context.fetch(fetchRequest).first else {
            print("DEBUG: No RecipeEntity found with the specified ID to update.")
            return
        }

        recipeToUpdate.isFavourite = isFavourite
        try saveContext()
    }

    // MARK: ShopingList operations

    func addIngredientsToShopingList(ingredients: [IngredientModel]) throws {
        let data = ShopingListEntity(context: moc.context)
        data.id = UUID()
        data.isChecked = false

        for ingredient in ingredients {
            data.name = ingredient.name
            data.value = ingredient.value
            data.valueType = ingredient.valueType.name
        }

        do {
            try moc.context.save()
            print("DEBUG: Ingredients added to shopping list and context saved.")
        } catch {
            print("DEBUG: Error adding ingredients to shopping list: \(error)")
        }
    }

    func updateShopingList(shopingList: ShopingListModel) throws {
        let fetchRequest: NSFetchRequest<ShopingListEntity> = ShopingListEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", shopingList.id as CVarArg)

        guard let shopingListToUpdate = try moc.context.fetch(fetchRequest).first else {
            print("DEBUG: No ShopingListEntity found with the specified ID to update.")
            return
        }

        shopingListToUpdate.name = shopingList.name
        shopingListToUpdate.value = shopingList.value
        shopingListToUpdate.valueType = shopingList.valueType
        shopingListToUpdate.isChecked = shopingList.isChecked

        try saveContext()
    }

    func clearShopingList() throws {
        let fetchRequest: NSFetchRequest<ShopingListEntity> = ShopingListEntity.fetchRequest()

        do {
            let results = try moc.context.fetch(fetchRequest)
            for object in results {
                moc.context.delete(object)
            }
            try moc.context.save()
            print("DEBUG: All objects removed from ShopingListEntity and context saved.")
        } catch {
            print("DEBUG: Error clearing shopping list: \(error)")
        }
    }

    // MARK: Delete methods

    func deleteRecipe(withId id: UUID) throws {
        let fetchRequest: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        guard let recipeToDelete = try moc.context.fetch(fetchRequest).first else {
            print("DEBUG: No RecipeEntity found with the specified ID.")
            return
        }

        moc.context.delete(recipeToDelete)
        try saveContext()
    }

    // MARK: - Fetch Methods

    func fetchAllRecipes() throws -> [RecipeModel] {
        let fetchRequest: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()

        let entities = try moc.context.fetch(fetchRequest)
        return entities.map { mapRecipeEntityToModel($0) }
    }

    func fetchRecipesWithName(_ name: String) throws -> [RecipeModel]? {
        let fetchRequest: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", name)

        let entities = try moc.context.fetch(fetchRequest)
        return entities.map { mapRecipeEntityToModel($0) }
    }

    func fetchShopingList(isChecked: Bool) throws -> [ShopingListModel] {
        let fetchRequest: NSFetchRequest<ShopingListEntity> = ShopingListEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isChecked == %@", NSNumber(value: isChecked))

        let entities = try moc.context.fetch(fetchRequest)
        return entities.map { mapShopingEntityToModel($0) }
    }


    private func saveContext() throws {
        if moc.context.hasChanges {
            do {
                try moc.context.save()
            } catch {
                throw DataRepositoryError.failedToSaveContext(error)
            }
        }
    }
}

// MARK: - Helper methods

extension DataRepository {
    func mapRecipeEntityToModel(_ recipeEntity: RecipeEntity) -> RecipeModel {
        return RecipeModel(
            id: recipeEntity.id,
            name: recipeEntity.name,
            serving: recipeEntity.servings,
            prepTimeHours: recipeEntity.prepTimeHours,
            prepTimeMinutes: recipeEntity.prepTimeMinutes,
            spicy: RecipeSpicyModel(value: recipeEntity.spicy),
            category: RecipeCategoryModel(value: recipeEntity.category),
            difficulty: RecipeDifficultyModel(value: recipeEntity.difficulty),
            ingredientList: recipeEntity.ingredients.map { ingredient in
                IngredientModel(
                    id: ingredient.id,
                    name: ingredient.name, value: ingredient.value,
                    valueType: IngredientValueTypeModel.from(name: ingredient.valueType))
            },
            instructionList: recipeEntity.instructions.map { instruction in
                InstructionModel(
                    id: instruction.id,
                    index: instruction.indexPath,
                    text: instruction.text)
            },
            isImageSaved: recipeEntity.isImageSaved,
            isFavourite: recipeEntity.isFavourite)
    }

    func mapShopingEntityToModel(_ shopingEntity: ShopingListEntity) -> ShopingListModel {
        return ShopingListModel(
            id: shopingEntity.id,
            isChecked: shopingEntity.isChecked,
            name: shopingEntity.name,
            value: shopingEntity.value,
            valueType: shopingEntity.valueType)
    }
}

// MARK: - Observed CoreData publishers

extension DataRepository {
    func observeCoreDateChanges() {
        moc.allRecipesPublisher()
            .sink(receiveValue: { [weak self] recipeChange in
                Task { [weak self] in
                    if let recipeChange = recipeChange {
                        switch recipeChange {
                        case .inserted(let insertedRecipe):
                            self?.recipesInsertedPublisher.send(.inserted(insertedRecipe))
                        case .deleted(let deletedRecipe):
                            self?.recipesDeletedPublisher.send(.deleted(deletedRecipe))
                        case .updated(let updatedRecipe):
                            self?.recipesUpdatedPublisher.send(.updated(updatedRecipe))
                        }
                    }
                }
            })
            .store(in: &cancellables)

        moc.shopingListPublisher()
            .sink(receiveValue: { [weak self] recipeChange in
                Task { [weak self] in
                    if let recipeChange = recipeChange {
                        switch recipeChange {
                        case .inserted(let insertedRecipe):
                            self?.shopingListPublisher.send(.inserted(insertedRecipe))
                        case .deleted(let deletedRecipe):
                            self?.shopingListPublisher.send(.deleted(deletedRecipe))
                        case .updated(let updatedRecipe):
                            self?.shopingListPublisher.send(.updated(updatedRecipe))
                        }
                    }
                }
            })
            .store(in: &cancellables)
    }
}

// MARK: - Error handling

extension DataRepository {
    private enum DataRepositoryError: Error {
        case entityNotFound
        case failedToFetchData(Error)
        case failedToSaveContext(Error)
        case failedToDeleteEntity
        case transactionFailure(String)
    }
}

#if DEBUG
extension DataRepository: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "DataRepository")
    }
}
#endif
