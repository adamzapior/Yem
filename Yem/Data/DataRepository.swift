//
//  DataRepository.swift
//  Yem
//
//  Created by Adam Zapiór on 17/01/2024.
//

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
    }

    func updateRecipe(recipe: RecipeModel) {
        guard let recipeEntity = try? moc.context.fetch(RecipeEntity.fetchRequest()).first(where: { $0.id == recipe.id }) else {
            print("Recipe not found for update")
            return
        }

        recipeEntity.id = recipe.id
        recipeEntity.name = recipe.name
        recipeEntity.servings = recipe.serving
        recipeEntity.prepTimeHours = recipe.perpTimeHours
        recipeEntity.prepTimeMinutes = recipe.perpTimeMinutes
        recipeEntity.spicy = recipe.spicy
        recipeEntity.category = recipe.category
        recipeEntity.difficulty = recipe.difficulty
        recipeEntity.isImageSaved = recipe.isImageSaved

        // ingredients update to fix
        recipeEntity.ingredients.forEach { moc.context.delete($0) }
        var ingredientEntities = Set<IngredientEntity>()
        for ingredientModel in recipe.ingredientList {
            let ingredientEntity = IngredientEntity(context: moc.context)
            ingredientEntity.id = ingredientModel.id
            ingredientEntity.name = ingredientModel.name
            ingredientEntity.value = ingredientModel.value
            ingredientEntity.valueType = ingredientModel.valueType
            ingredientEntities.insert(ingredientEntity)
        }
        recipeEntity.ingredients = ingredientEntities

        // instruction update to fix
        recipeEntity.instructions.forEach { moc.context.delete($0) }
        var instructionEntities = Set<InstructionEntity>()
        for instructionModel in recipe.instructionList {
            let instructionEntity = InstructionEntity(context: moc.context)
            instructionEntity.id = instructionModel.id
            instructionEntity.indexPath = instructionModel.index
            instructionEntity.text = instructionModel.text
            instructionEntities.insert(instructionEntity)
        }
        recipeEntity.instructions = instructionEntities

        let saveSuccessful = save()
        if !saveSuccessful {
            print("Update error")
        } else {
            print("Update succesed")
        }
    }

    // MARK: Fetch methods

    func fetchAllRecipes() async -> Result<[RecipeModel], Error> {
        do {
            let recipes = try moc.fetchAllRecipes()

            let result = recipes.map { recipe -> RecipeModel in
                RecipeModel(id: recipe.id,
                            name: recipe.name,
                            serving: recipe.servings,
                            perpTimeHours: recipe.prepTimeHours,
                            perpTimeMinutes: recipe.prepTimeMinutes,
                            spicy: recipe.spicy,
                            category: recipe.category,
                            difficulty: recipe.difficulty,
                            ingredientList: recipe.ingredients.map { list in
                                IngredientModel(id: list.id,
                                                value: list.value,
                                                valueType: list.valueType,
                                                name: list.name)
                            }, instructionList: recipe.instructions.map { step in
                                InstructionModel(id: step.id,
                                                 index: step.indexPath,
                                                 text: step.text)
                            },
                            isImageSaved: recipe.isImageSaved)
            }
            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    func fetchRecipesWithName(_ name: String) async -> Result<[RecipeModel]?, Error> {
        do {
            guard let recipe = try moc.fetchRecipesWithName(name) else {
                return .success(nil)
            }

            let result = recipe.map { recipe -> RecipeModel in
                RecipeModel(id: recipe.id,
                            name: recipe.name,
                            serving: recipe.servings,
                            perpTimeHours: recipe.prepTimeHours,
                            perpTimeMinutes: recipe.prepTimeMinutes,
                            spicy: recipe.spicy,
                            category: recipe.category,
                            difficulty: recipe.difficulty,
                            ingredientList: recipe.ingredients.map { list in
                                IngredientModel(id: list.id,
                                                value: list.value,
                                                valueType: list.valueType,
                                                name: list.name)
                            }, instructionList: recipe.instructions.map { step in
                                InstructionModel(id: step.id,
                                                 index: step.indexPath,
                                                 text: step.text)
                            },
                            isImageSaved: recipe.isImageSaved)
            }
            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    // MARK: Update methods

    // MARK: Delete methods

    func delete() {}
}

extension DataRepository {}

enum DataRepositoryError: Error {
    case fetchAllRecipesError
    case saveError
}
