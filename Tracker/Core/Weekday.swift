enum Weekday: String, CaseIterable, Codable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    // MARK: - Init for Calendar weekday numbers
    init?(calendarWeekday: Int) {
        switch calendarWeekday {
        case 1: self = .sunday
        case 2: self = .monday
        case 3: self = .tuesday
        case 4: self = .wednesday
        case 5: self = .thursday
        case 6: self = .friday
        case 7: self = .saturday
        default: return nil
        }
    }

    // MARK: - Full localized name
    var fullName: String {
        switch self {
        case .monday: WeekdaysConstants.monday
        case .tuesday: WeekdaysConstants.tuesday
        case .wednesday: WeekdaysConstants.wednesday
        case .thursday: WeekdaysConstants.thursday
        case .friday: WeekdaysConstants.friday
        case .saturday: WeekdaysConstants.saturday
        case .sunday: WeekdaysConstants.sunday
        }
    }


    // MARK: - Short weekday names
    var shortName: String {
        switch self {
        case .monday: WeekdaysConstants.m
        case .tuesday: WeekdaysConstants.tu
        case .wednesday: WeekdaysConstants.w
        case .thursday: WeekdaysConstants.th
        case .friday: WeekdaysConstants.f
        case .saturday: WeekdaysConstants.s
        case .sunday: WeekdaysConstants.su
        }
    }
}
