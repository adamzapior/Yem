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

    var recipesChangedPublisher = PassthroughSubject<Void, Never>()

    init() {
        moc.allRecipesPublisher()
            .sink(receiveValue: { [weak self] _ in
                Task { [weak self] in
                    self?.recipesChangedPublisher.send(())
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

    func addRecipe(recipe: RecipeModel) {
        let data = RecipeEntity(context: moc.context)
        data.id = recipe.id
        data.name = recipe.name
        data.servings = recipe.serving
        data.prepTimeHours = recipe.perpTimeHours
        data.prepTimeMinutes = recipe.perpTimeMinutes
        data.spicy = recipe.spicy
        data.category = recipe.category
        data.difficulty = recipe.difficulty
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

        print("RecipeEntity created and added to context. Is new object: \(data.isInserted)")

        do {
            try moc.context.save() // Zapisz kontekst po dodaniu obiektu
            print("Context saved after adding RecipeEntity")
        } catch {
            print("Error saving context: \(error)")
        }
    }

//    func updateRecipe(recipe: RecipeModel) {
//        let fetchRequest: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "id == %@", recipe.id as CVarArg)
//
//        do {
//            let results = try moc.context.fetch(fetchRequest)
//            if let recipeToUpdate = results.first {
//                // Update the fields
//                recipeToUpdate.name = recipe.name
//                recipeToUpdate.servings = recipe.serving
//                recipeToUpdate.prepTimeHours = recipe.perpTimeHours
//                recipeToUpdate.prepTimeMinutes = recipe.perpTimeMinutes
//                recipeToUpdate.spicy = recipe.spicy
//                recipeToUpdate.category = recipe.category
//                recipeToUpdate.difficulty = recipe.difficulty
//                recipeToUpdate.isImageSaved = recipe.isImageSaved
//                recipeToUpdate.isFavourite = recipe.isFavourite
//
//                // Update ingredients
//                updateIngredients(for: recipeToUpdate, with: recipe.ingredientList)
//
//                // Update instructions
//                updateInstructions(for: recipeToUpdate, with: recipe.instructionList)
//
//                // Save the updated context
//                try moc.context.save()
//                print("RecipeEntity updated and context saved.")
//            } else {
//                print("No RecipeEntity found with the specified ID to update.")
//            }
//        } catch {
//            print("Error updating recipe: \(error)")
//        }
//    }

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
}

extension DataRepository {
    func mapRecipeEntityToModel(_ recipeEntity: RecipeEntity) -> RecipeModel {
        return RecipeModel(
            id: recipeEntity.id,
            name: recipeEntity.name,
            serving: recipeEntity.servings,
            perpTimeHours: recipeEntity.prepTimeHours,
            perpTimeMinutes: recipeEntity.prepTimeMinutes,
            spicy: recipeEntity.spicy,
            category: recipeEntity.category,
            difficulty: recipeEntity.difficulty,
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
