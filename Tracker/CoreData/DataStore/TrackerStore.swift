import UIKit
import CoreData
import Logging

final class TrackerStore: NSObject {
    
    // MARK: - Public Properties
    weak var delegate: TrackerStoreDelegate?
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            AppLogger.shared.error("[TrackerStore]:\(#line)] \(#function) unable to get Trackers: \(error.localizedDescription)")
        }
        
        return fetchedResultsController
    }()
    
    // MARK: - Inits
    override init() {
        self.context = CoreDataManager.shared.viewContext
        super.init()
    }
    
    // MARK: - Public Methods
    func fetchTrackers() -> [Tracker] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        return objects.compactMap { mapToTracker($0) }
    }
    
    func addNewTracker(_ tracker: Tracker, to category: TrackerCategoryCoreData) throws {
        let entity = try fetchOrCreateCoreDataEntity(for: tracker)
        entity.category = category
        category.addToTrackers(entity)
        
        do {
            try context.save()
        } catch {
            AppLogger.shared.error("[TrackerStore] Failed to save tracker: \(error)")
            throw error
        }
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        request.fetchLimit = 1

        guard let entity = try context.fetch(request).first else {
            AppLogger.shared.warning("[TrackerStore] Tracker not found for deletion: \(tracker.id)")
            return
        }

        context.delete(entity)

        do {
            try context.save()
        } catch {
            AppLogger.shared.error("[TrackerStore] Failed to delete tracker: \(error)")
            throw error
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchOrCreateCoreDataEntity(for tracker: Tracker) throws -> TrackerCoreData {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        request.fetchLimit = 1
        
        if let existing = try context.fetch(request).first {
            existing.name = tracker.name
            existing.emoji = tracker.emoji
            existing.colorHex = tracker.color.hexString
            existing.scheduleData = try JSONEncoder().encode(tracker.schedule)
            return existing
        }
        
        let entity = TrackerCoreData(context: context)
        entity.id = tracker.id
        entity.name = tracker.name
        entity.emoji = tracker.emoji
        entity.colorHex = tracker.color.hexString
        entity.scheduleData = try JSONEncoder().encode(tracker.schedule)
        
        return entity
    }
    
    // MARK: - Private Methods
    func mapToTracker(_ object: TrackerCoreData) -> Tracker? {
        guard
            let id = object.id,
            let name = object.name,
            let emoji = object.emoji,
            let colorHex = object.colorHex,
            let scheduleData = object.scheduleData
        else { return nil }
        
        let color = UIColor(hex: colorHex)
        let schedule = (try? JSONDecoder().decode([Weekday].self, from: scheduleData)) ?? []
        
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        guard let trackers = controller.fetchedObjects as? [TrackerCoreData] else { return }
        delegate?.storeDidUpdate(trackers.compactMap { mapToTracker($0) })
    }
}
