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
        persistentContainer = NSPersistentContainer(name: "Yem")
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
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
