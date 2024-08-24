//
//  CoreDataStack.swift
//  Yem
//
//  Created by Adam Zapiór on 24/08/2024.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()

    private(set) lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "YemData")
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    lazy var coreDataManager: CoreDataManager = {
        return CoreDataManager(persistentContainer: persistentContainer)
    }()
}

/// This method help to avoid crash in Core Data Tests.
/// When running all tests at once without using this method, multiple Entity instances are created, which will likely cause an error
/// Solution: https://forums.kodeco.com/t/multiple-warnings-when-running-unit-tests-in-sample-app/74860/8

public extension NSManagedObject {
  convenience init(using usedContext: NSManagedObjectContext) {
    let name = String(describing: type(of: self))
    let entity = NSEntityDescription.entity(forEntityName: name, in: usedContext)!
    self.init(entity: entity, insertInto: usedContext)
  }
}


