import CoreData
import Logging

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataTracker")
        
        let description = container.persistentStoreDescriptions.first
        description?.shouldAddStoreAsynchronously = true
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                AppLogger.shared.error("[CoreDataManager]:\(#line)] \(#function) Error loading store CoreData: \(error), \(error.userInfo)")
            } else {
                AppLogger.shared.notice("[CoreDataManager]:\(#line)] \(#function) Store CoreData load success")
            }
        })
        
        let context = container.viewContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.shouldDeleteInaccessibleFaults = true
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext () {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                AppLogger.shared.error("[CoreDataManager]:\(#line)] \(#function) Error saving context: \(error)")
                context.rollback()
            }
        }
    }
}
