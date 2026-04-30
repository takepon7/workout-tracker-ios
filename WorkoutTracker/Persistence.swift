//
//  Persistence.swift
//  WorkoutTracker
//
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        // Add preview data here if needed
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // We explicitly look for the model to ensure it exists
        // Note: When creating the xcdatamodeld manually, the compiled file extension is .momd
        // However, standard NSPersistentContainer initialization usually finds it by name automatically if it's in the bundle.
        // We will stick to the standard init first, but with error logging.
        
        container = NSPersistentContainer(name: "WorkoutDataModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                print("❌ Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
