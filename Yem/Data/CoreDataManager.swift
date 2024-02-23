//
//  CoreDataManager.swift
//  Yem
//
//  Created by Adam Zapiór on 16/01/2024.
//

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
            do {
                try context.save()
                print("Core Data context has saved")
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
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
}
