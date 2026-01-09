enum TrackerFilter: CaseIterable {
    case all
    case today
    case completed
    case uncompleted

    var title: String {
        switch self {
        case .all: return TrackerFilterConstants.all
        case .today: return TrackerFilterConstants.today
        case .completed: return TrackerFilterConstants.completed
        case .uncompleted: return TrackerFilterConstants.uncompleted
        }
    }

    var showsCheckmark: Bool {
        switch self {
        case .all:
            return false
        case .today, .completed, .uncompleted:
            return true
        }
    }
}
