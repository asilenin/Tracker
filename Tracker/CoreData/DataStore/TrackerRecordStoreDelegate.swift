protocol TrackerRecordStoreDelegate: AnyObject {
    func storeDidUpdate(_ records: [TrackerRecord])
}
