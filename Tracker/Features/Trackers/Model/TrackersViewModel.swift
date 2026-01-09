import Foundation

final class TrackersViewModel {
    
    // MARK: - Private Properties
    private(set) var visibleCategories: [TrackerCategory] = []
    
    private let fetchCategories: () -> [TrackerCategory]
    private let isTrackerCompleted: (_ trackerId: UUID, _ date: Date) -> Bool
    
    // MARK: - Public Properties
    var currentDate: Date {
        didSet { updateVisibleCategories() }
    }

    var currentFilter: TrackerFilter {
        didSet { updateVisibleCategories() }
    }

    var searchText: String {
        didSet { updateVisibleCategories() }
    }

    // MARK: - Init
    init(
        currentDate: Date = Date(),
        currentFilter: TrackerFilter = .all,
        searchText: String = "",
        fetchCategories: @escaping () -> [TrackerCategory],
        isTrackerCompleted: @escaping (_ trackerId: UUID, _ date: Date) -> Bool
    ) {
        self.currentDate = currentDate
        self.currentFilter = currentFilter
        self.searchText = searchText
        self.fetchCategories = fetchCategories
        self.isTrackerCompleted = isTrackerCompleted

        // initial render
        updateVisibleCategories()
    }

    // MARK: - Outputs

    var onUpdate: (() -> Void)?
    
    // MARK: - Public Methods
    func updateVisibleCategories() {
        let base = fetchCategories()
        let byDate = filterByDate(base, date: currentDate)
        let byFilter = filterByCompletion(byDate, filter: currentFilter, date: currentDate)
        let bySearch = filterBySearch(byFilter, text: searchText)
        
        visibleCategories = bySearch
        onUpdate?()
    }
    
    // MARK: - Filtering
    private func filterByDate(
        _ categories: [TrackerCategory],
        date: Date
    ) -> [TrackerCategory] {

        let calendarWeekday = Calendar.current.component(.weekday, from: date)
        guard let weekday = Weekday(calendarWeekday: calendarWeekday) else {
            return []
        }

        return categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                tracker.schedule.contains(weekday)
            }

            guard !trackers.isEmpty else { return nil }
            return TrackerCategory(title: category.title, trackers: trackers)
        }
    }

    private func filterByCompletion(
        _ categories: [TrackerCategory],
        filter: TrackerFilter,
        date: Date
    ) -> [TrackerCategory] {
        switch filter {
        case .completed:
            return categories.compactMap { category in
                let trackers = category.trackers.filter { isTrackerCompleted($0.id, date) }
                guard !trackers.isEmpty else { return nil }
                return TrackerCategory(title: category.title, trackers: trackers)
            }

        case .uncompleted:
            return categories.compactMap { category in
                let trackers = category.trackers.filter { !isTrackerCompleted($0.id, date) }
                guard !trackers.isEmpty else { return nil }
                return TrackerCategory(title: category.title, trackers: trackers)
            }

        case .all, .today:
            // .today is handled by VC (it sets currentDate = Date and filter = .all)
            return categories
        }
    }

    private func filterBySearch(_ categories: [TrackerCategory], text: String) -> [TrackerCategory] {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return categories }

        let lowered = query.lowercased()

        return categories.compactMap { category in
            let trackers = category.trackers.filter { $0.name.lowercased().contains(lowered) }
            guard !trackers.isEmpty else { return nil }
            return TrackerCategory(title: category.title, trackers: trackers)
        }
    }
}
