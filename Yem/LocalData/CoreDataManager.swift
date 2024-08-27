//
//  CoreDataManager.swift
//  Yem
//
//  Created by Adam Zapiór on 16/01/2024.
//

import Combine
import CoreData
import Foundation
import LifetimeTracker

protocol CoreDataManagerProtocol {
    var context: NSManagedObjectContext { get }
    func saveContext()
    func beginTransaction()
    func endTransaction()
    func rollbackTransaction()
    func allRecipesPublisher() -> AnyPublisher<ObjectChange?, Never>
    func shopingListPublisher() -> AnyPublisher<ObjectChange?, Never>
    func fetchAllRecipes() throws -> [RecipeEntity]
    func fetchRecipesWithName(_ name: String) throws -> [RecipeEntity]?
    func fetchShopingList(isChecked: Bool) throws -> [ShopingListEntity]
}

final class CoreDataManager: CoreDataManagerProtocol {
    private let persistentContainer: NSPersistentContainer
    let context: NSManagedObjectContext

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        self.context = persistentContainer.viewContext

#if DEBUG
        trackLifetime()
#endif
    }

    // MARK: - Operations on current context

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Unresolved error \(error)")
            }
        }
    }

    func beginTransaction() {
        let undoManager = UndoManager()
        context.undoManager = undoManager
        undoManager.beginUndoGrouping()
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

    // MARK: - Fetch data methods

    func fetchAllRecipes() throws -> [RecipeEntity] {
        let request: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        return try context.fetch(request)
    }

    func fetchRecipesWithName(_ name: String) throws -> [RecipeEntity]? {
        let request: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        return try context.fetch(request)
    }

    func fetchShopingList(isChecked: Bool) throws -> [ShopingListEntity] {
        let request: NSFetchRequest<ShopingListEntity> = ShopingListEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = NSPredicate(format: "\(#keyPath(ShopingListEntity.isChecked)) == %@", NSNumber(value: isChecked))
        return try context.fetch(request)
    }

    // MARK: - Observe changes methods

    func allRecipesPublisher() -> AnyPublisher<ObjectChange?, Never> {
        NotificationCenter.default.publisher(for: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: context)
            .compactMap { notification in
                self.objectChange(from: notification, ofType: RecipeEntity.self)
            }
            .eraseToAnyPublisher()
    }

    func shopingListPublisher() -> AnyPublisher<ObjectChange?, Never> {
        NotificationCenter.default.publisher(for: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: context)
            .compactMap { notification in
                self.objectChange(from: notification, ofType: ShopingListEntity.self)
            }
            .eraseToAnyPublisher()
    }

    private func objectChange<T: NSManagedObject>(from notification: Notification, ofType type: T.Type) -> ObjectChange? {
        guard let userInfo = notification.userInfo else { return nil }

        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>,
           let insertedObject = inserts.first(where: { $0 is T })
        {
            return .inserted(insertedObject)
        }
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>,
           let deletedObject = deletes.first(where: { $0 is T })
        {
            return .deleted(deletedObject)
        }
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>,
           let updatedObject = updates.first(where: { $0 is T })
        {
            return .updated(updatedObject)
        }

        return nil
    }
}

// MARK: - ObjectChange enum

enum ObjectChange {
    case inserted(NSManagedObject)
    case deleted(NSManagedObject)
    case updated(NSManagedObject)
}

#if DEBUG
extension CoreDataManager: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "CoreDataManager")
    }
}
#endif
