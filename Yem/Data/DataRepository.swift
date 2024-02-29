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
            isImageSaved: recipeEntity.isImageSaved)
    }
}

enum DataRepositoryError: Error {
    case fetchAllRecipesError
    case saveError
}
