import UIKit
import Logging

protocol TrackersViewControllerProtocol: AnyObject {
    var presenter: TrackersPresenterProtocol? { get set }
}

final class TrackersViewController: UIViewController,TrackerViewCellDelegate, AddTrackerViewControllerDelegate, TrackersViewControllerProtocol{
    
    // MARK: - Properties
    var presenter: TrackersPresenterProtocol?
    var currentDate = Date()
    
    // MARK: - UI Elements
    private let clearTextLabel = UILabel()
    private var clearImageView = UIImageView()
    private var searchField: UISearchController?
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    // MARK: - Private Properties
    private let trackerStore = TrackerStore()
    private let categoryStore = TrackerCategoryStore()
    private let recordStore = TrackerRecordStore()
    
    private var visibleCategories: [TrackerCategory] = [] {
        didSet {
            updateClearView()
            collectionView.reloadData()
        }
    }
    var filteredTrackers: [Tracker] = [] {
        didSet {
            updateClearView()
            collectionView.reloadData()
        }
    }
    
    // MARK: - Initializers
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        return nil
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        setupStores()
        setupView()
        setupClearTextLabel()
        setupClearImageView()
        setupTrackerButton()
        setupTitle()
        setupSearchField()
        setupCollectionView()
        setupDatePicker()
        setupConstraints()
        updateClearView()
        collectionView.reloadData()
    }
    
    // MARK: - Configuration
    private func setupView() {
        view.backgroundColor = .whiteYP
        view.contentMode = .scaleToFill
    }
    
    private func setupClearTextLabel() {
        clearTextLabel.text = UITrackersVCConstants.clearTextLabel
        clearTextLabel.textColor = .blackYP
        clearTextLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        clearTextLabel.contentMode = .center
        clearTextLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clearTextLabel)
    }
    
    private func setupClearImageView(){
        let image = UIImage(resource: .clearListStar)
        clearImageView = UIImageView(image: image)
        clearImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clearImageView)
        clearImageView.contentMode = .scaleAspectFit
        clearImageView.tintColor = .blackYP
    }
    
    private func setupTrackerButton(){
        let trackerButtonImage = UIImage(resource: .addTracker)
        let addTrackerButton = UIBarButtonItem(image: trackerButtonImage, style: .plain, target: self, action: #selector(addTrackerButtonTapped))
        addTrackerButton.tintColor = .blackYP
        navigationItem.leftBarButtonItem = addTrackerButton
    }
    
    private func setupTitle(){
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = UITrackersVCConstants.title
    }
    
    private func setupSearchField() {
        searchField = UISearchController(searchResultsController: nil)
        searchField?.searchBar.placeholder = UITrackersVCConstants.searchBarPlaceholder
        searchField?.searchBar.searchTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        searchField?.searchBar.searchTextField.textColor = .searchBGYP
        navigationItem.searchController = searchField
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackerViewCell.self, forCellWithReuseIdentifier: TrackerViewCell.reuseIdentifier)
        collectionView.backgroundColor = .whiteYP
        view.addSubview(collectionView)
    }
    
    private func setupDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            clearImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clearImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            clearImageView.widthAnchor.constraint(equalToConstant: 80),
            clearImageView.heightAnchor.constraint(equalToConstant: 80),
            
            clearTextLabel.topAnchor.constraint(equalTo: clearImageView.bottomAnchor, constant: 8),
            clearTextLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - Public Methods
    func didTapCompleteButton(trackerId: UUID, at indexPath: IndexPath) {
        if currentDate <= Date() {
            addTrackerRecord(trackerId: trackerId, date: currentDate)
        }
    }
    
    func didTapUnCompleteButton(trackerId: UUID, at indexPath: IndexPath) {
        self.removeTrackerRecord(trackerId: trackerId, date: self.currentDate)
    }
    
    func addNewTracker(tracker newTracker: Tracker, title categoryTitle: String) {
        let category = categoryStore.addNewCategory(with: categoryTitle)
        
        do {
            try trackerStore.addNewTracker(newTracker, to: category)
        } catch {
            AppLogger.shared.error("[TrackersViewController]:\(#line)] \(#function) error: \(error)")
        }
    }
    
    func addTrackerRecord(trackerId: UUID, date: Date) {
        let newRecord = TrackerRecord(trackerId: trackerId, date: date)
        
        do {
            try recordStore.addRecord(newRecord)
        } catch {
            AppLogger.shared.error("[TrackersViewController]:\(#line)] \(#function) error: \(error)")
        }
    }
    
    func removeTrackerRecord(trackerId: UUID, date: Date) {
        let oldRecord = TrackerRecord(trackerId: trackerId, date: date)
        do {
            try recordStore.deleteRecord(oldRecord)
        } catch {
            AppLogger.shared.error("[TrackersViewController]:\(#line)] \(#function) error: \(error)")
        }
    }
    
    func completeTracker(trackerId: UUID, date: Date) {
        recordStore.toggleRecord(trackerId: trackerId, date: date)
    }
    
    // MARK: - Private Methods
    private func setupStores(){
        trackerStore.delegate = self
        categoryStore.delegate = self
        recordStore.delegate = self
        
        filterTrackersForSelectedDate(currentDate)
    }
    
    private func updateClearView() {
        let hasContent = !filteredTrackers.isEmpty
        
        clearImageView.isHidden = hasContent
        clearTextLabel.isHidden = hasContent
        
        collectionView.isHidden = !hasContent
    }
    
    @objc private func addTrackerButtonTapped(){
        let addTrackerViewController = AddTrackerViewController()
        addTrackerViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: addTrackerViewController)
        present(navigationController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        self.currentDate = selectedDate
        filterTrackersForSelectedDate(selectedDate)
    }
    
    private func filterTrackersForSelectedDate(_ date: Date) {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        guard let selectedWeekDay = Weekday(calendarWeekday: dayOfWeek) else {
            self.filteredTrackers = []
            self.visibleCategories = []
            return
        }
        let categories = categoryStore.fetchCategories()
        var newVisibleCategories: [TrackerCategory] = []
        var newFilteredTrackers: [Tracker] = []
        for category in categories {
            let filteredTrackersInCategory = category.trackers.filter { tracker in
                return tracker.schedule.contains(selectedWeekDay)
            }
            guard !filteredTrackersInCategory.isEmpty else { continue }
            newVisibleCategories.append(
                TrackerCategory(title: category.title, trackers: filteredTrackersInCategory)
            )
            newFilteredTrackers.append(contentsOf: filteredTrackersInCategory)
        }
        self.filteredTrackers = newFilteredTrackers
        self.visibleCategories = newVisibleCategories
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerViewCell.reuseIdentifier, for: indexPath) as? TrackerViewCell else {
            return UICollectionViewCell()
        }
        let category = visibleCategories[indexPath.section]
        let tracker = category.trackers[indexPath.row]
        let completedDays = recordStore.records(for: tracker.id).count
        let isCompleted = recordStore.isCompleted(trackerId: tracker.id, date: currentDate)
        cell.configure(
            isCompleted: isCompleted,
            trackerID: tracker.id,
            trackerName: tracker.name,
            indexPath: indexPath,
            categoryTitle: category.title,
            completedDays: completedDays,
            currentDate: currentDate,
            trackerEmoji: tracker.emoji,
            trackerColor: tracker.color)
        cell.delegate = self
        return cell
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionInsets = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        let itemSpacing = self.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: indexPath.section)
        let numberOfColumns: CGFloat = 2
        let totalPadding = sectionInsets.left + sectionInsets.right
        let spacingBetweenCells = itemSpacing * (numberOfColumns - 1)
        let availableWidth = collectionView.bounds.width - totalPadding - spacingBetweenCells
        let cellWidth = availableWidth / numberOfColumns
        let cellHeight: CGFloat = 178
        return CGSize(width: floor(cellWidth), height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 16, bottom: 0, right: 16)
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func storeDidUpdate(_ trackers: [Tracker]) {
        self.filteredTrackers = trackers
        filterTrackersForSelectedDate(currentDate)
    }
}

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func storeDidUpdate(_ categories: [TrackerCategory]) {
        filterTrackersForSelectedDate(currentDate)
    }
}

extension TrackersViewController: TrackerRecordStoreDelegate {
    func storeDidUpdate(_ records: [TrackerRecord]) {
        filterTrackersForSelectedDate(currentDate)
    }
}
