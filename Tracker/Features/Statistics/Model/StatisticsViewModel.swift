import Foundation

final class StatisticsViewModel: TrackerRecordStoreDelegate {
    
    // MARK: - Output
    private(set) var statistics: [StatisticsItem] = [] {
        didSet { onUpdate?() }
    }
    
    var isEmpty: Bool {
        statistics.isEmpty
    }
    
    var onUpdate: (() -> Void)?
    
    // MARK: - Dependencies
    private let recordStore: TrackerRecordStoreProtocol
    private let trackerStore: TrackerStoreProtocol
    
    
    init(
        recordStore: TrackerRecordStoreProtocol,
        trackerStore: TrackerStoreProtocol
    ) {
        self.recordStore = recordStore
        self.trackerStore = trackerStore
        
        (recordStore as? TrackerRecordStore)?.delegate = self
        
        let records = recordStore.fetchRecords()
        let trackers = trackerStore.fetchTrackers()
        statistics = makeStatistics(records: records, trackers: trackers)
    }
    
    // MARK: - Public Methods
    /*func reload() {
        let records = recordStore.fetchRecords()
        let trackers = trackerStore.fetchTrackers()
        statistics = makeStatistics(records: records, trackers: trackers)
    }*/
    
    func storeDidUpdate(_ records: [TrackerRecord]) {
        let trackers = trackerStore.fetchTrackers()
        statistics = makeStatistics(records: records, trackers: trackers)
    }
    
    // MARK: - Private Methods
    private func makeStatistics(
        records: [TrackerRecord],
        trackers: [Tracker]
    ) -> [StatisticsItem] {
        guard !records.isEmpty else {
            return []
        }
        
        return [
            StatisticsItem(value: bestPeriod(from: records), title: UIStatisticsConstants.bestPeriod),
            StatisticsItem(value: perfectDays(from: records, trackers: trackers), title: UIStatisticsConstants.perfectDays),
            StatisticsItem(value: records.count, title: UIStatisticsConstants.completed),
            StatisticsItem(value: average(from: records), title: UIStatisticsConstants.average)
        ]
    }
    
    private func weekday(from date: Date) -> Weekday? {
        let calendarWeekday = Calendar.current.component(.weekday, from: date)
        return Weekday(calendarWeekday: calendarWeekday)
    }
    
    private func bestPeriod(from records: [TrackerRecord]) -> Int {
        let days = Set(records.map {
            Calendar.current.startOfDay(for: $0.date)
        }).sorted()
        
        var best = 0
        var current = 0
        
        for i in 0..<days.count {
            if i == 0 ||
                Calendar.current.date(byAdding: .day, value: 1, to: days[i - 1]) == days[i] {
                current += 1
            } else {
                current = 1
            }
            best = max(best, current)
        }
        
        return best
    }
    
    private func perfectDays(
        from records: [TrackerRecord],
        trackers: [Tracker]
    ) -> Int {
        
        let recordsByDay = Dictionary(grouping: records) {
            Calendar.current.startOfDay(for: $0.date)
        }
        
        var count = 0
        
        for (date, dayRecords) in recordsByDay {
            guard let weekday = weekday(from: date) else { continue }
            
            let scheduledTrackers = trackers.filter {
                $0.schedule.contains(weekday)
            }
            
            if !scheduledTrackers.isEmpty &&
                scheduledTrackers.count == dayRecords.count {
                count += 1
            }
        }
        
        return count
    }
    
    private func average(from records: [TrackerRecord]) -> Int {
        let uniqueDays = Set(records.map {
            Calendar.current.startOfDay(for: $0.date)
        })
        
        guard !uniqueDays.isEmpty else { return 0 }
        return records.count / uniqueDays.count
    }
}
