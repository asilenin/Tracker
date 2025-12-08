import CoreData

final class TrackerRecordStore: NSObject {
    
    // MARK: - Public Properties
    weak var delegate: TrackerRecordStoreDelegate?
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
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
    func fetchRecords() -> [TrackerRecord] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        return objects.compactMap { self.mapToRecord($0) }
    }
    
    func addRecord(_ record: TrackerRecord) throws {
        let startOfDay = Calendar.current.startOfDay(for: record.date)
        
        let trackerRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        trackerRequest.predicate = NSPredicate(format: "id == %@", record.trackerId as CVarArg)
        
        guard let trackerObject = try context.fetch(trackerRequest).first else {
            print("❌ [TrackerRecordStore]:\(#line)] \(#function) Tracked id=\(record.trackerId) not found in DB")
            throw NSError(domain: "TrackerRecordStore", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Tracker with id \(record.trackerId) not found"
            ])
        }
        
        let entity = TrackerRecordCoreData(context: context)
        entity.trackerId = record.trackerId
        entity.date = startOfDay
        entity.tracker = trackerObject
        trackerObject.addToRecords(entity)
        try context.save()
    }
    
    func deleteRecord(_ record: TrackerRecord) throws {
        let startOfDay = Calendar.current.startOfDay(for: record.date)
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "trackerId == %@ AND date == %@",
            record.trackerId as CVarArg,
            startOfDay as CVarArg
        )
        
        if let existing = try context.fetch(request).first {
            context.delete(existing)
            try context.save()
        }
    }
    
    func toggleRecord(trackerId: UUID, date: Date) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        
        if let existing = existingRecord(trackerId: trackerId, date: startOfDay) {
            context.delete(existing)
        } else {
            let entity = TrackerRecordCoreData(context: context)
            entity.trackerId = trackerId
            entity.date = startOfDay
            
            if let tracker = fetchTrackerById(trackerId) {
                entity.tracker = tracker
                tracker.addToRecords(entity)
            }
        }
        
        do {
            try context.save()
        } catch {
            print("❌ [TrackerRecordStore]:\(#line)] \(#function) toggleRecord save error: \(error)")
        }
    }
    
    func records(for trackerId: UUID) -> [TrackerRecord] {
        return fetchedResultsController.fetchedObjects?.filter {
            $0.trackerId == trackerId
        }.compactMap(mapToRecord) ?? []
    }
    
    func isCompleted(trackerId: UUID, date: Date) -> Bool {
        return records(for: trackerId).contains {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }
    
    // MARK: - Private Methods
    private func existingRecord(trackerId: UUID, date: Date) -> TrackerRecordCoreData? {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "trackerId == %@ AND date == %@",
            trackerId as CVarArg,
            date as CVarArg
        )
        request.fetchLimit = 1
        
        return try? context.fetch(request).first
    }
    
    private func fetchTrackerById(_ id: UUID) -> TrackerCoreData? {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        return try? context.fetch(request).first
    }
    
    private func mapToRecord(_ object: TrackerRecordCoreData) -> TrackerRecord? {
        guard
            let trackerId = object.trackerId,
            let date = object.date
        else { return nil }
        
        return TrackerRecord(
            trackerId: trackerId,
            date: date
        )
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        guard let records = controller.fetchedObjects as? [TrackerRecordCoreData] else { return }
        delegate?.storeDidUpdate(records.compactMap { self.mapToRecord($0) })
    }
}
