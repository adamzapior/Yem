//
//  CoreDataManager.swift
//  Yem
//
//  Created by Adam Zapiór on 16/01/2024.
//

import Combine
import CoreData
import Foundation

final class CoreDataManager {
    static let shared = CoreDataManager()

    let persistentContainer: NSPersistentContainer
    let context: NSManagedObjectContext

    init() {
        persistentContainer = NSPersistentContainer(name: "YemData")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        context = persistentContainer.viewContext
    }

    func saveContext() {
        if context.hasChanges {
            print("Context has unsaved changes")
            do {
                try context.save()
                print("Core Data context has saved")
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        } else {
            print("No unsaved changes in context")
        }
    }

    func beginTransaction() {
        context.undoManager = UndoManager()
        context.undoManager?.beginUndoGrouping()
    }

    func endTransaction() {
        context.undoManager?.endUndoGrouping()
        context.undoManager = nil
    }

    func rollbackTransaction() {
        context.undoManager?.endUndoGrouping()
        context.undoManager?.undo()
        context.undoManager = nil
    }

    func fetchAllRecipes() throws -> [RecipeEntity] {
        let request: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        do {
            return try CoreDataManager.shared.context.fetch(request)
        } catch {
            throw error
        }
    }

    func fetchRecipesWithName(_ name: String) throws -> [RecipeEntity]? {
        let request: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        let idString = name
        request.predicate = NSPredicate(format: "name == %@", idString)

        do {
            let results = try context.fetch(request)
            return results
        } catch {
            throw error
        }
    }
    
    func fetchShopingList() throws -> [ShopingListEntity]? {
        let request: NSFetchRequest<ShopingListEntity> = ShopingListEntity.fetchRequest()

        do {
            let results = try context.fetch(request)
            return results
        } catch {
            throw error
        }
    }
}

extension CoreDataManager {
    func allRecipesPublisher() -> AnyPublisher<RecipeChange?, Never> {
        NotificationCenter.default.publisher(for: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: context)
            .compactMap { notification in
                guard let userInfo = notification.userInfo else { return nil }

                var recipeChange: RecipeChange?

                if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>,
                   let insertedRecipe = inserts.first(where: { $0 is RecipeEntity })
                {
                    recipeChange = .inserted(insertedRecipe)
                }
                if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>,
                   let deletedRecipe = deletes.first(where: { $0 is RecipeEntity })
                {
                    recipeChange = .deleted(deletedRecipe)
                }
                if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>,
                   let updatedRecipe = updates.first(where: { $0 is RecipeEntity })
                {
                    recipeChange = .updated(updatedRecipe)
                }

                return recipeChange
            }
            .eraseToAnyPublisher()
    }
}

enum RecipeChange {
    case inserted(NSManagedObject)
    case deleted(NSManagedObject)
    case updated(NSManagedObject)
}
