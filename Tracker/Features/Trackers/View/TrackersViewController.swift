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

    private var currentFilter: TrackerFilter = .all {
        didSet {
            viewModel.currentFilter = currentFilter
            updateFilterButtonAppearance()
        }
    }
    
    private lazy var viewModel = TrackersViewModel(
        currentDate: currentDate,
        currentFilter: currentFilter,
        searchText: "",
        fetchCategories: { [weak self] in
            self?.categoryStore.fetchCategories() ?? []
        },
        isTrackerCompleted: { [weak self] trackerId, date in
            self?.recordStore.isCompleted(trackerId: trackerId, date: date) ?? false
        }
    )
    
    // MARK: - Initializers
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.onUpdate = { [weak self] in
            guard let self else { return }
            collectionView.reloadData()
            updateClearView()
        }
        
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
        setupFilterButton()
        setupConstraints()
        updateClearView()
        collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        AnalyticsService.shared.report(
            event: .openMain()
        )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        AnalyticsService.shared.report(
            event: .closeMain()
        )
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
        searchField?.searchResultsUpdater = self
        navigationItem.searchController = searchField
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInset.bottom = 80
        collectionView.verticalScrollIndicatorInsets.bottom = 80
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .whiteYP

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            TrackerViewCell.self,
            forCellWithReuseIdentifier: TrackerViewCell.reuseIdentifier
        )

        view.addSubview(collectionView)
    }
    
    private func setupDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func setupFilterButton(){
        view.addSubview(filterButton)
        view.bringSubviewToFront(filterButton)
    }
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(UITrackersVCConstants.filtersButtonLabel, for: .normal)
        button.backgroundColor = .blueYP
        button.setTitleColor(.alwaysWhiteYP, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            clearImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clearImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),

            clearTextLabel.topAnchor.constraint(equalTo: clearImageView.bottomAnchor, constant: 8),
            clearTextLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            clearTextLabel.topAnchor.constraint(equalTo: clearImageView.bottomAnchor, constant: 8),
            clearTextLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 48),
            filterButton.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    // MARK: - Public Methods
    func didTapCompleteButton(trackerId: UUID, at indexPath: IndexPath) {
        
        AnalyticsService.shared.report(
            event: .click(item: "track")
        )
        
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
        viewModel.updateVisibleCategories()
    }
    
    private func updateClearView() {
        let hasVisibleContent = !viewModel.visibleCategories.isEmpty
        let hasAnyTrackers = viewModel.hasAnyTrackers

        clearImageView.isHidden = hasVisibleContent
        clearTextLabel.isHidden = hasVisibleContent
        collectionView.isHidden = !hasVisibleContent
        filterButton.isHidden = !hasAnyTrackers

        guard !hasVisibleContent else { return }

        clearTextLabel.text = hasAnyTrackers
            ? UITrackersVCConstants.clearTextLabelNothingWasFound
            : UITrackersVCConstants.clearTextLabel
    }
    
    @objc private func addTrackerButtonTapped(){
        
        AnalyticsService.shared.report(
            event: .click(item: "add_track")
        )
        
        let addTrackerViewController = AddTrackerViewController()
        addTrackerViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: addTrackerViewController)
        present(navigationController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        viewModel.currentDate = currentDate
    }
    
    private func updateFilterButtonAppearance() {
        let isActive = currentFilter == .completed || currentFilter == .uncompleted

        filterButton.setTitleColor(isActive ? .red : .white, for: .normal)
    }
    
    private func makeContextMenu(
        for tracker: Tracker,
        at indexPath: IndexPath
    ) -> UIMenu {

        let editAction = UIAction(
            title: UITrackersVCConstants.contextEditLabel,
            image: UIImage(systemName: "pencil")
        ) { [weak self] _ in
            self?.editTracker(tracker)
        }

        let deleteAction = UIAction(
            title: UITrackersVCConstants.contextDeleteLabel,
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { [weak self] _ in
            self?.deleteTracker(tracker)
        }

        return UIMenu(title: "", children: [editAction, deleteAction])
    }
    
    private func editTracker(_ tracker: Tracker) {
        
        AnalyticsService.shared.report(
            event: .click(item: "edit")
        )
        
        let editVC = AddTrackerViewController(tracker: tracker)
        editVC.delegate = self
        let navVC = UINavigationController(rootViewController: editVC)
        present(navVC, animated: true)
    }
    
    private func deleteTracker(_ tracker: Tracker) {
        let alert = UIAlertController(
            title: UITrackersVCConstants.deleteTrackerTitle,
            message: UITrackersVCConstants.deleteTrackerMessage,
            preferredStyle: .alert
        )

        let deleteAction = UIAlertAction(
            title: UITrackersVCConstants.deleteTrackerOK,
            style: .destructive
        ) { [weak self] _ in
            self?.performDelete(tracker)
        }

        let cancelAction = UIAlertAction(
            title: UITrackersVCConstants.deleteTrackerCancel,
            style: .cancel
        )

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
    
    private func performDelete(_ tracker: Tracker) {
        
        AnalyticsService.shared.report(
            event: .click(item: "delete")
        )
        
        do {
            try trackerStore.deleteTracker(tracker)
        } catch {
            AppLogger.shared.error("[TrackersViewController]:\(#line)] \(#function) Failed to delete tracker: \(error)")
        }
    }
    
    @objc private func filterButtonTapped() {
        
        AnalyticsService.shared.report(
            event: .click(item: "filter")
        )
        
        searchField?.isActive = false
        let vc = FiltersViewController(
            selectedFilter: makeSelectedFilterForFiltersVC()
        )
        vc.onSelect = { [weak self] filter in
            self?.viewModel.currentFilter = filter
        }

        present(vc, animated: true)
    }
    
    private func makeSelectedFilterForFiltersVC() -> TrackerFilter {
        if viewModel.currentFilter == .all,
           Calendar.current.isDateInToday(viewModel.currentDate) {
            return .today
        }
        return viewModel.currentFilter
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerViewCell.reuseIdentifier, for: indexPath) as? TrackerViewCell else {
            return UICollectionViewCell()
        }
        let category = viewModel.visibleCategories[indexPath.section]
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
        viewModel.updateVisibleCategories()
    }
}

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func storeDidUpdate(_ categories: [TrackerCategory]) {
        viewModel.updateVisibleCategories()
    }
}

extension TrackersViewController: TrackerRecordStoreDelegate {
    func storeDidUpdate(_ records: [TrackerRecord]) {
        viewModel.updateVisibleCategories()
    }
}

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchText = searchController.searchBar.text ?? ""
    }
}

extension TrackersViewController {

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {

        let tracker = viewModel.visibleCategories[indexPath.section]
            .trackers[indexPath.row]

        return UIContextMenuConfiguration(
            identifier: indexPath as NSIndexPath,
            previewProvider: nil
        ) { [weak self] _ in
            self?.makeContextMenu(for: tracker, at: indexPath)
        }
    }
}

