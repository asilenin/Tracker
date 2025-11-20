import UIKit

protocol TrackersViewControllerProtocol: AnyObject {
    var presenter: TrackersPresenterProtocol? { get set }
}

final class TrackersViewController: UIViewController,TrackerViewCellDelegate, AddTrackerViewControllerDelegate, TrackersViewControllerProtocol{
    
    // MARK: - Properties
    var presenter: TrackersPresenterProtocol?
    var currentDate = Date()
    var categories: [TrackerCategory] = []
    
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
    private var completedTrackers: [TrackerRecord] = []
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
        view.backgroundColor = UIColor(resource: .whiteYP)
        view.contentMode = .scaleToFill
    }
    
    private func setupClearTextLabel() {
        clearTextLabel.text = UITrackersVCConstants.clearTextLabel
        clearTextLabel.textColor = UIColor(resource: .blackYP)
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
        clearImageView.tintColor = UIColor(resource: .blackYP)
    }
    
    private func setupTrackerButton(){
        let trackerButtonImage = UIImage(resource: .addTracker)
        let addTrackerButton = UIBarButtonItem(image: trackerButtonImage, style: .plain, target: self, action: #selector(addTrackerButtonTapped))
        addTrackerButton.tintColor = .black
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
        searchField?.searchBar.searchTextField.textColor = UIColor(resource: .searchBGYP)
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
            collectionView.reloadData()
        }
    }
    
    func didTapUnCompleteButton(trackerId: UUID, at indexPath: IndexPath) {
        self.removeTrackerRecord(trackerId: trackerId, date: self.currentDate)
        collectionView.reloadData()
    }
    
    func addNewTracker(tracker newTracker: Tracker, title categoryTitle: String) {
        var updatedCategories: [TrackerCategory] = []
        var foundCategory = false
        for category in categories {
            if category.title == categoryTitle {
                let updatedTrackers = category.trackers + [newTracker]
                let updatedCategory = TrackerCategory(title: category.title, trackers: updatedTrackers)
                updatedCategories.append(updatedCategory)
                foundCategory = true
            } else {
                updatedCategories.append(category)
            }
        }
        if !foundCategory {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [newTracker])
            updatedCategories.append(newCategory)
        }
        self.categories = updatedCategories
        
        filterTrackersForSelectedDate(currentDate)
        updateClearView()
        collectionView.reloadData()
    }
    
    func addTrackerRecord(trackerId: UUID, date: Date) {
        let newRecord = TrackerRecord(trackerId: trackerId, date: date)
        completedTrackers.append(newRecord)
    }
    
    func removeTrackerRecord(trackerId: UUID, date: Date) {
        completedTrackers.removeAll { record in
            record.trackerId == trackerId && Calendar.current.isDate(record.date, inSameDayAs: date)
        }
    }
    
    func completeTracker(trackerId: UUID, date: Date) {
        let existingRecord = completedTrackers.first { record in
            record.trackerId == trackerId && Calendar.current.isDate(record.date, inSameDayAs: date)
        }
        if existingRecord != nil {
            removeTrackerRecord(trackerId: trackerId, date: date)
        } else {
            addTrackerRecord(trackerId: trackerId, date: date)
        }
    }
    
    // MARK: - Private Methods
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
        var newVisibleCategories: [TrackerCategory] = []
        var newFilteredTrackers: [Tracker] = []
        for category in categories {
            let filteredTrackersInCategory = category.trackers.filter { tracker in
                return tracker.schedule.contains(selectedWeekDay)
            }
            if !filteredTrackersInCategory.isEmpty {
                let newCategory = TrackerCategory(title: category.title, trackers:
                                                    filteredTrackersInCategory)
                newVisibleCategories.append(newCategory)
                newFilteredTrackers.append(contentsOf: filteredTrackersInCategory)
            }
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
        let completedDays = completedTrackers.filter { completedTracker in
            return completedTracker.trackerId == tracker.id
        }.count
        let isCompleted = completedTrackers.contains { completedTracker in
            return completedTracker.trackerId == tracker.id && completedTracker.date == currentDate
        }
        cell.configure(isCompleted: isCompleted, trackerID: tracker.id, trackerName: tracker.name, indexPath: indexPath, categoryTitle: category.title, completedDays: completedDays, currentDate: currentDate)
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
