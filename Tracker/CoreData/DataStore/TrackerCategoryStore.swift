import UIKit
import CoreData

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Public Properties
    weak var delegate: TrackerCategoryStoreDelegate?
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
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
            print("❌ [TrackerRecordStore]:\(#line)] \(#function) unable fetch results: \(error.localizedDescription)")
        }
        
        return fetchedResultsController
    }()
    
    
    // MARK: - Inits
    override init() {
        self.context = CoreDataManager.shared.viewContext
        super.init()
    }
    
    // MARK: - Public Methods
    func fetchCategories() -> [TrackerCategory] {
        if let objects = fetchedResultsController.fetchedObjects, !objects.isEmpty {
            return objects.compactMap { self.mapToCategory($0) }
        }
        
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        do {
            let objects = try context.fetch(request)
            return objects.compactMap { self.mapToCategory($0) }
        } catch {
            print("❌ [TrackerRecordStore]:\(#line)] \(#function) Unable to fetch Categories: \(error.localizedDescription)")
            return []
        }
    }
    
    @discardableResult
    func addNewCategory(with title: String) -> TrackerCategoryCoreData {
        if let existing = fetchCoreDataCategory(withTitle: title) {
            return existing
        }
        
        let entity = TrackerCategoryCoreData(context: context)
        entity.title = title
        entity.trackers = NSSet()
        do {
            try context.save()
        } catch {
            print("❌ [TrackerCategoryStore] Unable to save new category: \(error)")
        }
        delegate?.storeDidUpdate(fetchCategories())
        
        return entity
    }
    
    @discardableResult
    func addNewCategory(_ category: TrackerCategory) -> TrackerCategoryCoreData {
        let entity = addNewCategory(with: category.title)
        
        if !category.trackers.isEmpty {
            let coreTrackers = category.trackers.map { self.mapToCoreData($0) }
            entity.trackers = NSSet(array: coreTrackers)
            do {
                try context.save()
            } catch {
                print("❌ [TrackerCategoryStore]:\(#line)] \(#function) Unable to save category with trackers: \(error.localizedDescription)")
            }
        }
        
        delegate?.storeDidUpdate(fetchCategories())
        return entity
    }
    
    func category(withTitle title: String) -> TrackerCategory? {
        return fetchCategories().first { $0.title == title }
    }
    
    func fetchCoreDataCategory(withTitle title: String) -> TrackerCategoryCoreData? {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("❌ [TrackerCategoryStore]:\(#line)] \(#function) unable to fetch CoreData category: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Private Methods
    private func mapToCategory(_ object: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let title = object.title else { return nil }
        let trackers = (object.trackers as? Set<TrackerCoreData>)?
            .compactMap { self.mapToTracker($0) } ?? []
        return TrackerCategory(title: title, trackers: trackers)
    }
    
    private func mapToTracker(_ object: TrackerCoreData) -> Tracker? {
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
    
    private func mapToCoreData(_ tracker: Tracker) -> TrackerCoreData {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        request.fetchLimit = 1
        
        do {
            if let existing = try context.fetch(request).first {
                existing.name = tracker.name
                existing.emoji = tracker.emoji
                existing.colorHex = tracker.color.hexString
                existing.scheduleData = try? JSONEncoder().encode(tracker.schedule)
                return existing
            }
        } catch {
            print("❌ [TrackerRecordStore]:\(#line)] \(#function) Unable to map to CoreData \(error.localizedDescription)")
        }
        
        let entity = TrackerCoreData(context: context)
        entity.id = tracker.id
        entity.name = tracker.name
        entity.emoji = tracker.emoji
        entity.colorHex = tracker.color.hexString
        entity.scheduleData = try? JSONEncoder().encode(tracker.schedule)
        return entity
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        delegate?.storeDidUpdate(fetchCategories())
    }
}
