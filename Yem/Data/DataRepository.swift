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

//    func updateRecipe(recipe: RecipeModel) {
//        guard let recipeEntity = try? moc.context.fetch(RecipeEntity.fetchRequest()).first(where: { $0.id == recipe.id }) else {
//            print("Recipe not found for update")
//            return
//        }
//
//        recipeEntity.id = recipe.id
//        recipeEntity.name = recipe.name
//        recipeEntity.servings = recipe.serving
//        recipeEntity.prepTimeHours = recipe.perpTimeHours
//        recipeEntity.prepTimeMinutes = recipe.perpTimeMinutes
//        recipeEntity.spicy = recipe.spicy
//        recipeEntity.category = recipe.category
//        recipeEntity.difficulty = recipe.difficulty
//        recipeEntity.isImageSaved = recipe.isImageSaved
//
//        // ingredients update to fix
//        recipeEntity.ingredients.forEach { moc.context.delete($0) }
//        var ingredientEntities = Set<IngredientEntity>()
//        for ingredientModel in recipe.ingredientList {
//            let ingredientEntity = IngredientEntity(context: moc.context)
//            ingredientEntity.id = ingredientModel.id
//            ingredientEntity.name = ingredientModel.name
//            ingredientEntity.value = ingredientModel.value
//            ingredientEntity.valueType = ingredientModel.valueType
//            ingredientEntities.insert(ingredientEntity)
//        }
//        recipeEntity.ingredients = ingredientEntities
//
//        // instruction update to fix
//        recipeEntity.instructions.forEach { moc.context.delete($0) }
//        var instructionEntities = Set<InstructionEntity>()
//        for instructionModel in recipe.instructionList {
//            let instructionEntity = InstructionEntity(context: moc.context)
//            instructionEntity.id = instructionModel.id
//            instructionEntity.indexPath = instructionModel.index
//            instructionEntity.text = instructionModel.text
//            instructionEntities.insert(instructionEntity)
//        }
//        recipeEntity.instructions = instructionEntities
//
//        let saveSuccessful = save()
//        if !saveSuccessful {
//            print("Update error")
//        } else {
//            print("Update succesed")
//        }
//
//        print("RecipeEntity created and added to context. Is new object: \(recipeEntity.isInserted)")
//
//        do {
//            try moc.context.save() // Zapisz kontekst po dodaniu obiektu
//            print("Context saved after adding RecipeEntity")
//        } catch {
//            print("Error saving context: \(error)")
//        }
//
//    }

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

extension DataRepository {
//    func observeDataChanges() -> AnyPublisher<[RecipeModel], Never> {
//        moc.changesPublisher()
//            .flatMap { [weak self] objectIDs -> AnyPublisher<[RecipeModel], Never> in
//                guard let self = self else { return Just([]).eraseToAnyPublisher() }
//                let recipes = objectIDs.compactMap { self.moc.context.object(with: $0) as? RecipeEntity }
//                let models = recipes.map { entity in
//                    RecipeModel(
//                        id: entity.id,
//                        name: entity.name,
//                        serving: entity.servings,
//                        perpTimeHours: entity.prepTimeHours,
//                        perpTimeMinutes: entity.prepTimeMinutes,
//                        spicy: entity.spicy,
//                        category: entity.category,
//                        difficulty: entity.difficulty,
//                        ingredientList: entity.ingredients.map { IngredientModel(id: $0.id,
//                                                                                 value: $0.value,
//                                                                                 valueType: $0.valueType,
//                                                                                 name: $0.name)
//                        },
//                        instructionList: entity.instructions.map { InstructionModel(id: $0.id,
//                                                                                    index: $0.indexPath,
//                                                                                    text: $0.text)
//                        },
//                        isImageSaved: entity.isImageSaved
//                    )
//                }
//                return Just(models).eraseToAnyPublisher()
//            }
//            .eraseToAnyPublisher()
//    }

    func getUpdatedRecipes(for objectIDs: Set<NSManagedObjectID>) -> [RecipeModel] {
        let recipes = objectIDs.compactMap { self.moc.context.object(with: $0) as? RecipeEntity }
        return recipes.map { entity in
            RecipeModel(
                id: entity.id,
                name: entity.name,
                serving: entity.servings,
                perpTimeHours: entity.prepTimeHours,
                perpTimeMinutes: entity.prepTimeMinutes,
                spicy: entity.spicy,
                category: entity.category,
                difficulty: entity.difficulty,
                ingredientList: entity.ingredients.map { IngredientModel(id: $0.id,
                                                                         value: $0.value,
                                                                         valueType: $0.valueType,
                                                                         name: $0.name)
                },
                instructionList: entity.instructions.map { InstructionModel(id: $0.id,
                                                                            index: $0.indexPath,
                                                                            text: $0.text)
                },
                isImageSaved: entity.isImageSaved
            )
        }
    }

    func observeDataChanges() -> AnyPublisher<[RecipeModel], Never> {
        moc.changesPublisher
            .map { [weak self] objectIDs -> [RecipeModel] in
                guard let self = self else { return [] }
                return self.getUpdatedRecipes(for: objectIDs)
            }
            .eraseToAnyPublisher()
    }
}

enum DataRepositoryError: Error {
    case fetchAllRecipesError
    case saveError
}
