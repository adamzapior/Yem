//
//  DataRepository.swift
//  Yem
//
//  Created by Adam Zapiór on 17/01/2024.
//

import Combine
import CoreData
import Foundation

//protocol DataRepositoryProtocol {
//    func save()
//    func fetchAllRecipes() async -> Result<[RecipeEntity], DataRepositoryError>
//    func searchByQuery()
//    func delete()
//}

final class DataRepository {
    let moc = CoreDataManager.shared
    var cancellables = Set<AnyCancellable>()

    var recipesInsertedPublisher = PassthroughSubject<ObjectChange, Never>()

    var recipesDeletedPublisher = PassthroughSubject<ObjectChange, Never>()

    var recipesUpdatedPublisher = PassthroughSubject<ObjectChange, Never>()

    var shopingListPublisher = PassthroughSubject<ObjectChange, Never>()


    init() {
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

    func save() -> Bool {
        moc.saveContext()
        return true
    }

    func beginTransaction() {
        moc.beginTransaction()
    }

    func endTransaction() {
        moc.endTransaction()
    }

    func rollbackTransaction() {
        moc.rollbackTransaction()
    }

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

    func addRecipe(recipe: RecipeModel) {
        let data = RecipeEntity(context: moc.context)
        data.id = recipe.id
        data.name = recipe.name
        data.servings = recipe.serving
        data.prepTimeHours = recipe.perpTimeHours
        data.prepTimeMinutes = recipe.perpTimeMinutes
        data.spicy = recipe.spicy.rawValue
        data.category = recipe.category.rawValue
        data.difficulty = recipe.difficulty.rawValue
        data.isImageSaved = recipe.isImageSaved
        data.isFavourite = recipe.isFavourite

        var ingredientEntities = Set<IngredientEntity>()
        for ingredientModel in recipe.ingredientList {
            let ingredientEntity = IngredientEntity(context: moc.context)
            ingredientEntity.id = ingredientModel.id
            ingredientEntity.name = ingredientModel.name
            ingredientEntity.value = ingredientModel.value
            ingredientEntity.valueType = ingredientModel.valueType

            ingredientEntities.insert(ingredientEntity)
        }

        data.ingredients = ingredientEntities

        var instructionEntities = Set<InstructionEntity>()
        for instructionList in recipe.instructionList {
            let entity = InstructionEntity(context: moc.context)

            entity.id = UUID()
            entity.indexPath = instructionList.index
            entity.text = instructionList.text

            instructionEntities.insert(entity)
        }

        data.instructions = instructionEntities

        do {
            try moc.context.save()
            print("DEBUG: Context saved after adding RecipeEntity")
        } catch {
            print("DEBUG: Error saving context: \(error)")
        }
    }

    func updateRecipe(recipe: RecipeModel) {
        let fetchRequest: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", recipe.id as CVarArg)

        do {
            let results = try moc.context.fetch(fetchRequest)
            if let recipeToUpdate = results.first {
                // Update the fields
                recipeToUpdate.name = recipe.name
                recipeToUpdate.servings = recipe.serving
                recipeToUpdate.prepTimeHours = recipe.perpTimeHours
                recipeToUpdate.prepTimeMinutes = recipe.perpTimeMinutes
                recipeToUpdate.spicy = recipe.spicy.rawValue
                recipeToUpdate.category = recipe.category.rawValue
                recipeToUpdate.difficulty = recipe.difficulty.rawValue
                recipeToUpdate.isImageSaved = recipe.isImageSaved
                recipeToUpdate.isFavourite = recipe.isFavourite

                // Update ingredients
                var ingredientEntities = Set<IngredientEntity>()
                for ingredientModel in recipe.ingredientList {
                    let ingredientEntity = IngredientEntity(context: moc.context)
                    ingredientEntity.id = ingredientModel.id
                    ingredientEntity.name = ingredientModel.name
                    ingredientEntity.value = ingredientModel.value
                    ingredientEntity.valueType = ingredientModel.valueType

                    ingredientEntities.insert(ingredientEntity)
                }

                recipeToUpdate.ingredients = ingredientEntities

                // Update instructions
                var instructionEntities = Set<InstructionEntity>()
                for instructionList in recipe.instructionList {
                    let entity = InstructionEntity(context: moc.context)

                    entity.id = UUID()
                    entity.indexPath = instructionList.index
                    entity.text = instructionList.text

                    instructionEntities.insert(entity)
                }

                recipeToUpdate.instructions = instructionEntities

                // Save the updated context
                try moc.context.save()
                print("DEBUG: RecipeEntity updated and context saved.")
            } else {
                print("DEBUG: No RecipeEntity found with the specified ID to update.")
            }
        } catch {
            print("DEBUG: Error updating recipe: \(error)")
        }
    }

    func updateRecipeFavouriteStatus(recipeId: UUID, isFavourite: Bool) {
        let fetchRequest: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", recipeId as CVarArg)

        do {
            let recipesToUpdate = try moc.context.fetch(fetchRequest)
            guard let recipeToUpdate = recipesToUpdate.first else {
                print("DEBUG: No RecipeEntity found with the specified ID to update.")
                return
            }

            recipeToUpdate.isFavourite = isFavourite

            try moc.context.save()
            print("DEBUG: RecipeEntity favourite status updated and context saved.")
        } catch {
            print("DEBUG: Error updating recipe's favourite status: \(error)")
        }
    }

    // MARK: Delete methods

    func deleteRecipe(withId id: UUID) {
        let fetchRequest: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let results = try moc.context.fetch(fetchRequest)
            if let recipeToDelete = results.first {
                moc.context.delete(recipeToDelete)
                try moc.context.save()
                print("DEBUG: RecipeEntity deleted and context saved.")
            } else {
                print("DEBUG: No RecipeEntity found with the specified ID.")
            }
        } catch {
            print("DEBUG: Error deleting recipe: \(error)")
        }
    }

    // MARK: Fetch methods

    func fetchAllRecipes() -> Result<[RecipeModel], Error> {
        do {
            let recipes = try moc.fetchAllRecipes()

            let result = recipes.map { recipe -> RecipeModel in
                self.mapRecipeEntityToModel(recipe)
            }
            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    func fetchRecipesWithName(_ name: String) -> Result<[RecipeModel]?, Error> {
        do {
            guard let recipes = try moc.fetchRecipesWithName(name) else {
                return .success(nil)
            }

            let result = recipes.map { recipe -> RecipeModel in
                self.mapRecipeEntityToModel(recipe)
            }

            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    // MARK: Shoping list

    func fetchShopingList(isChecked: Bool) -> Result<[ShopingListModel], Error> {
        do {
            let list = try moc.fetchShopingList(isChecked: isChecked).compactMap { $0 }

            let result = list.map { list -> ShopingListModel in
                ShopingListModel(id: list.id,
                                 isChecked: list.isChecked,
                                 name: list.name,
                                 value: list.value,
                                 valueType: list.valueType)
            }
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    func updateShopingList(shopingList: ShopingListModel) {
        let fetchRequest: NSFetchRequest<ShopingListEntity> = ShopingListEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", shopingList.id as CVarArg)

        do {
            let results = try moc.context.fetch(fetchRequest)
            if let shopingListToUpdate = results.first {
                // Update the fields
                shopingListToUpdate.name = shopingList.name
                shopingListToUpdate.value = shopingList.value
                shopingListToUpdate.valueType = shopingList.valueType
                shopingListToUpdate.isChecked = shopingList.isChecked

                // Save the updated context
                if save() {
                    print("DEBUG: ShopingListEntity updated and context saved.")
                }
            } else {
                print("DEBUG: No ShopingListEntity found with the specified ID to update.")
            }
        } catch {
            print("DEBUG: Error updating shoping list: \(error)")
        }
    }

    func clearShopingList() {
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
    

    func addIngredientsToShopingList(ingredients: [IngredientModel]) {
        let data = ShopingListEntity(context: moc.context)
        data.id = UUID()
        data.isChecked = false

        for ingredient in ingredients {
            data.name = ingredient.name
            data.value = ingredient.value
            data.valueType = ingredient.valueType
        }

        do {
            try moc.context.save()
            print("DEBUG: Ingredients added to shopping list and context saved.")
        } catch {
            print("DEBUG: Error adding ingredients to shopping list: \(error)")
        }
    }
}

extension DataRepository {
    func mapRecipeEntityToModel(_ recipeEntity: RecipeEntity) -> RecipeModel {
        return RecipeModel(
            id: recipeEntity.id,
            name: recipeEntity.name,
            serving: recipeEntity.servings,
            perpTimeHours: recipeEntity.prepTimeHours,
            perpTimeMinutes: recipeEntity.prepTimeMinutes,
            spicy: RecipeSpicy(rawValue: recipeEntity.spicy) ?? .medium,
            category: RecipeCategory(rawValue: recipeEntity.category) ?? .notSelected,
            difficulty: RecipeDifficulty(rawValue: recipeEntity.difficulty) ?? .medium,
            ingredientList: recipeEntity.ingredients.map { ingredient in
                IngredientModel(
                    id: ingredient.id,
                    value: ingredient.value,
                    valueType: ingredient.valueType,
                    name: ingredient.name)
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
}

enum DataRepositoryError: Error {
    case fetchAllRecipesError
    case saveError
}
