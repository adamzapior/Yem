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
    
    private var changesPublisherSubject = PassthroughSubject<Set<NSManagedObjectID>, Never>()
    
    var changesPublisher: AnyPublisher<Set<NSManagedObjectID>, Never> {
         changesPublisherSubject.eraseToAnyPublisher()
     }

    init() {
        persistentContainer = NSPersistentContainer(name: "YemData")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        context = persistentContainer.viewContext
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(notification:)), name: .NSManagedObjectContextObjectsDidChange, object: context)
        
        
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: nil) { notification in
            print("NSManagedObjectContextDidSave notification received")
        }
        
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: nil) { notification in
            print("NSManagedObjectContextDidSave notification received")

            if let insertedObjectIDs = notification.userInfo?[NSInsertedObjectIDsKey] as? Set<NSManagedObjectID> {
                print("Inserted Object IDs: \(insertedObjectIDs)")
            } else {
                print("No inserted object IDs in the notification")
            }
        }

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

extension CoreDataManager {
//    func changesPublisher() -> AnyPublisher<Set<NSManagedObjectID>, Never> {
//        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: context)
//            .compactMap { notification in
//                var objectIDs = Set<NSManagedObjectID>()
//                if let insertedIDs = notification.userInfo?[NSInsertedObjectIDsKey] as? Set<NSManagedObjectID> {
//                    objectIDs.formUnion(insertedIDs)
//                }
//                if let updatedIDs = notification.userInfo?[NSUpdatedObjectIDsKey] as? Set<NSManagedObjectID> {
//                    objectIDs.formUnion(updatedIDs)
//                }
//                if let deletedIDs = notification.userInfo?[NSDeletedObjectIDsKey] as? Set<NSManagedObjectID> {
//                    objectIDs.formUnion(deletedIDs)
//                }
//                return objectIDs.isEmpty ? nil : objectIDs
//            }
//            .eraseToAnyPublisher()
//    }

    
    @objc private func contextObjectsDidChange(notification: Notification) {
          var objectIDs = Set<NSManagedObjectID>()

          if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>, !insertedObjects.isEmpty {
              objectIDs.formUnion(insertedObjects.map { $0.objectID })
          }

          if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>, !updatedObjects.isEmpty {
              objectIDs.formUnion(updatedObjects.map { $0.objectID })
          }

          if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>, !deletedObjects.isEmpty {
              objectIDs.formUnion(deletedObjects.map { $0.objectID })
          }

          changesPublisherSubject.send(objectIDs)
      }
    
}
