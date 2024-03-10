//
//  DataRepository.swift
//  Yem
//
//  Created by Adam Zapiór on 17/01/2024.
//

import Combine
import CoreData
import Foundation

protocol DataRepositoryProtocol {
    func save()
    func fetchAllRecipes() async -> Result<[RecipeEntity], DataRepositoryError>
    func searchByQuery()
    func delete()
}

final class DataRepository {
    let moc = CoreDataManager.shared
    var cancellables = Set<AnyCancellable>()

    var recipesInsertedPublisher = PassthroughSubject<RecipeChange, Never>()

    var recipesDeletedPublisher = PassthroughSubject<RecipeChange, Never>()

    var recipesUpdatedPublisher = PassthroughSubject<RecipeChange, Never>()

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
            print("Error checking if recipe exists: \(error)")
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
            try moc.context.save() // Zapisz kontekst po dodaniu obiektu
            print("Context saved after adding RecipeEntity")
        } catch {
            print("Error saving context: \(error)")
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
                print("RecipeEntity updated and context saved.")
            } else {
                print("No RecipeEntity found with the specified ID to update.")
            }
        } catch {
            print("Error updating recipe: \(error)")
        }
    }

    func updateRecipeFavouriteStatus(recipeId: UUID, isFavourite: Bool) {
        let fetchRequest: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", recipeId as CVarArg)

        do {
            let recipesToUpdate = try moc.context.fetch(fetchRequest)
            guard let recipeToUpdate = recipesToUpdate.first else {
                print("No RecipeEntity found with the specified ID to update.")
                return
            }

            recipeToUpdate.isFavourite = isFavourite

            try moc.context.save()
            print("RecipeEntity favourite status updated and context saved.")
        } catch {
            print("Error updating recipe's favourite status: \(error)")
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
                print("RecipeEntity deleted and context saved.")
            } else {
                print("No RecipeEntity found with the specified ID.")
            }
        } catch {
            print("Error deleting recipe: \(error)")
        }
    }

    // MARK: Fetch methods

    func fetchAllRecipes() async -> Result<[RecipeModel], Error> {
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

    func fetchRecipesWithName(_ name: String) async -> Result<[RecipeModel]?, Error> {
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

    func fetchShopingList() async -> Result<[IngredientModel], Error> {
        do {
            guard let shopingListEntity = try moc.fetchShopingList()?.first else {
                return .success([]) // Return an empty array if list is empty
            }

            let ingredientEntities = Array(shopingListEntity.ingredient ?? Set<IngredientEntity>())
            let result = ingredientEntities.map { ingredientEntity -> IngredientModel in
                IngredientModel(
                    id: ingredientEntity.id,
                    value: ingredientEntity.value,
                    valueType: ingredientEntity.valueType,
                    name: ingredientEntity.name,
                    isChecked: ingredientEntity.isChecked
                )
            }

            return .success(result)
        } catch {
            return .failure(error)
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
            category: RecipeCategory(rawValue: recipeEntity.category) ?? .none,
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
