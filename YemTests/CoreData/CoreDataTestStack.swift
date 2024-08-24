//
//  CoreDataStack.swift
//  YemTests
//
//  Created by Adam Zapiór on 24/08/2024.
//

import CoreData
import XCTest
@testable import Yem

/// **Warning: This class and the CoreDataManager_Tests class may not function fully correctly. During the tests, a temporary Core
/// Data context is created, but after building the tests, the debug console displays information about two Enity instances from the CD.**

final class CoreDataTestStack {
    var persistentContainer: NSPersistentContainer!
    var context: NSManagedObjectContext!

    private let managedObjectModel: NSManagedObjectModel
    
    init() {
        // Load the managed object model
        let modelURL = Bundle(for: type(of: self)).url(forResource: "YemData", withExtension: "momd")!
        managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!

        // Initialize the NSPersistentContainer with the managed object model
        let container = NSPersistentContainer(name: "YemData", managedObjectModel: managedObjectModel)

        // Configure the container to use an in-memory store
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        // Load the persistent stores
        container.loadPersistentStores { description, error in
            precondition(description.type == NSInMemoryStoreType, "Persistent store is not in-memory type")
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        // Assign the view context
        persistentContainer = container
        context = persistentContainer.viewContext
    }
}
