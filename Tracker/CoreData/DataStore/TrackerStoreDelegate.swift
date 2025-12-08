protocol TrackerStoreDelegate: AnyObject {
    func storeDidUpdate(_ trackers: [Tracker])
}
