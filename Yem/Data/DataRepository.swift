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
    
    // MARK: Save method
   
    func save() {
        return moc.saveContext()
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
                            category: recipe.category)
            }
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    func searchByQuery() {}
    
    //    func fetchShopingList() async -> Result<[ShopingListModel], Error> {
    //
    //    }

    // MARK: Update methods
    
    
    // MARK: Delete methods

    func delete() {}

}

enum DataRepositoryError: Error {
    case fetchAllRecipesError
    case saveError
}
