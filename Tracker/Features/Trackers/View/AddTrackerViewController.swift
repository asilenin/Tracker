import UIKit
import Logging

protocol AddTrackerViewControllerDelegate: AnyObject {
    func addNewTracker(tracker: Tracker, title: String)
    func removeTrackerRecord(trackerId: UUID, date: Date)
}

final class AddTrackerViewController: UIViewController, UITextFieldDelegate, ScheduleViewControllerDelegate {
    
    // MARK: - Properties
    weak var delegate: AddTrackerViewControllerDelegate?
    
    // MARK: - Private Properties
    private let sections = [UIHabitTrackerConstants.sectionCategory, UIHabitTrackerConstants.sectionSchedule]
    private var categories: [String] = [UIHabitTrackerConstants.categoryImportant, UIHabitTrackerConstants.categoryUnimportant]
    private var currentDate: Date?
    private var selectedSchedule: [Weekday] = []
    private var selectedCategory: String?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var isFormValid: Bool = false
    private let trackerId: UUID
    init(trackerId: UUID = UUID()) {
        self.trackerId = trackerId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: - UI Elements
    private lazy var scrollView = UIScrollView()
    private lazy var trackerNameTextField = UITextField()
    private lazy var tableView = UITableView()
    private lazy var emojiLabel = UILabel()
    private lazy var emojiCollectionView = UICollectionView()
    private lazy var colorLabel = UILabel()
    private lazy var colorCollectionView = UICollectionView()
    private lazy var createButton = UIButton()
    private lazy var cancelButton = UIButton()
    private lazy var errorLabel = UILabel()
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gesture.cancelsTouchesInView = false
        gesture.delaysTouchesBegan = false
        gesture.delaysTouchesEnded = false
        return gesture
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScrollView()
        setupErrorLabel()
        setupTitle()
        setupNameTrackerTextField()
        setupTableView()
        setupEmojiLabel()
        setupEmojiCollectionView()
        setupColorLabel()
        setupColorCollectionView()
        setupCreateButton()
        setupCancelButton()
        
        setupConstraints()
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup UI Elements
    private func setupView() {
        view.backgroundColor = .whiteYP
    }
    
    private func setupScrollView(){
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.delegate = self
        view.addSubview(scrollView)
    }
    
    private func setupErrorLabel(){
        errorLabel.textColor = .redYP
        errorLabel.font = .systemFont(ofSize: 17, weight: .regular)
        errorLabel.text = UIHabitTrackerConstants.errorMessage
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(errorLabel)
    }
    
    private func setupTitle(){
        navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 16, weight: .medium)]
        navigationItem.title = UIHabitTrackerConstants.title
    }
    
    private func setupNameTrackerTextField() {
        trackerNameTextField.placeholder = UIHabitTrackerConstants.namePlaceholder
        trackerNameTextField.backgroundColor = UIColor(resource: .backgroundYP).withAlphaComponent(0.3)
        trackerNameTextField.layer.cornerRadius = 16
        trackerNameTextField.layer.masksToBounds = true
        trackerNameTextField.clearButtonMode = .whileEditing
        trackerNameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: trackerNameTextField.frame.height))
        trackerNameTextField.leftViewMode = .always
        trackerNameTextField.returnKeyType = .done
        trackerNameTextField.enablesReturnKeyAutomatically = true
        trackerNameTextField.smartInsertDeleteType = .no
        trackerNameTextField.textColor = .greyYP
        trackerNameTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        trackerNameTextField.translatesAutoresizingMaskIntoConstraints = false
        trackerNameTextField.keyboardType = .default
        trackerNameTextField.delegate = self
        scrollView.addSubview(trackerNameTextField)
    }
    
    private func setupTableView() {
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryScheduleViewCell.self, forCellReuseIdentifier: CategoryScheduleViewCell.reuseIdentifier)
        scrollView.addSubview(tableView)
    }
    
    private func setupEmojiLabel() {
        emojiLabel.text = UIHabitTrackerConstants.emojiTitle
        emojiLabel.font = .systemFont(ofSize: 19, weight: .bold)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(emojiLabel)
    }
    
    private func setupEmojiCollectionView(){
        let emojiLayout = UICollectionViewFlowLayout()
        emojiLayout.itemSize = CGSize(width: 52, height: 52)
        emojiLayout.minimumInteritemSpacing = 5
        emojiLayout.minimumLineSpacing = 0
        emojiLayout.sectionInset = UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
        
        emojiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: emojiLayout)
        
        emojiCollectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        emojiCollectionView.backgroundColor = .clear
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        emojiCollectionView.isScrollEnabled = false
        scrollView.addSubview(emojiCollectionView)
    }
    
    private func setupColorLabel() {
        colorLabel.text = UIHabitTrackerConstants.colorTitle
        colorLabel.font = .systemFont(ofSize: 19, weight: .bold)
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(colorLabel)
    }
    
    private func setupColorCollectionView(){
        let colorLayout = UICollectionViewFlowLayout()
        colorLayout.itemSize = CGSize(width: 52, height: 52)
        colorLayout.minimumInteritemSpacing = 5
        colorLayout.minimumLineSpacing = 0
        colorLayout.sectionInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: colorLayout)
        colorCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        colorCollectionView.backgroundColor = .clear
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorCollectionView.isScrollEnabled = false
        scrollView.addSubview(colorCollectionView)
    }
    
    private func setupCreateButton() {
        createButton.setTitle(UIHabitTrackerConstants.createButtonLabel, for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createButton.setTitleColor(.white, for: .normal)
        createButton.backgroundColor = .greyYP
        createButton.layer.cornerRadius = 16
        createButton.layer.masksToBounds = true
        createButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createButton)
    }
    
    private func setupCancelButton() {
        cancelButton.setTitle(UIHabitTrackerConstants.cancelButtonLabel, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.layer.borderColor = (UIColor(resource: .redYP)).cgColor
        cancelButton.layer.borderWidth = 1.0
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.masksToBounds = true
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            // MARK: ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -16),
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            // MARK: Tracker Name
            trackerNameTextField.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            trackerNameTextField.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            // MARK: Error Label
            errorLabel.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 8),
            errorLabel.centerXAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerXAnchor),
            errorLabel.heightAnchor.constraint(equalToConstant: 22),
            
            // MARK: Category/Schedule table
            tableView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            // MARK: Emoji Label
            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 28),
            
            // MARK: Emoji Collection
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor),
            emojiCollectionView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            // MARK: Color Label
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 28),
            
            // MARK: Color Collection
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor),
            colorCollectionView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            colorCollectionView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            // MARK: Cancel Button
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            // MARK: Create Button
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8)
        ])
    }
    
    // MARK: - Methods
    func didUpdateSchedule(selectedSchedule: [Weekday]) {
        self.selectedSchedule = selectedSchedule
        tableView.reloadData()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return true }
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        errorLabel.isHidden = newText.count <= NewTrackerConstants.newTrackerTitleSymbolsLimit
        return newText.count <= NewTrackerConstants.newTrackerTitleSymbolsLimit
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == trackerNameTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateCreateButtonState()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateCreateButtonState()
    }
    
    // MARK: - Private Methods
    private func updateCreateButtonState() {
        guard let text = trackerNameTextField.text else {
            createButton.backgroundColor = .greyYP
            createButton.isEnabled = false
            AppLogger.shared.warning("[AddTrackerViewController]: :\(#line)] \(#function): TextField.text == nil")
            return
        }
        let hasText = !text.isEmpty
        let hasSchedule = !selectedSchedule.isEmpty
        let hasEmoji = selectedEmoji != nil
        let hasColor = selectedColor != nil
        
        isFormValid = hasText && hasSchedule && hasEmoji && hasColor
        
        createButton.backgroundColor = isFormValid ? .blackYP : .greyYP
        createButton.isEnabled = isFormValid
    }
    
    @objc private func saveButtonTapped(){
        guard let name = trackerNameTextField.text, !name.isEmpty else {
            return
        }
        guard
            let selectedCategory,
            let emoji = selectedEmoji,
            let color = selectedColor
        else {
            return
        }
        
        errorLabel.isHidden = true
        let newTracker = Tracker(
            id: UUID(),
            name: name,
            color: color,
            emoji: emoji,
            schedule: selectedSchedule
        )
        delegate?.addNewTracker(tracker: newTracker, title: selectedCategory)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancelButtonTapped(){
        dismiss(animated: true)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}


extension AddTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryScheduleViewCell.reuseIdentifier, for: indexPath) as? CategoryScheduleViewCell else {
            return UITableViewCell()
        }
        let title = sections[indexPath.row]
        var subtitle: String?
        if indexPath.row == 0 {
            subtitle = selectedCategory
        } else if indexPath.row == 1 {
            subtitle = scheduleSubtitle()
        }
        
        cell.configure(title: title, subtitle: subtitle)
        cell.accessoryType = .disclosureIndicator
        cell.contentView.backgroundColor = UIColor(resource: .backgroundYP).withAlphaComponent(0.3)
        let backgroundColor = UIColor(resource: .backgroundYP).withAlphaComponent(0.3)
        cell.backgroundColor = backgroundColor
        cell.contentView.backgroundColor = .clear
        cell.titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        cell.titleLabel.textColor = UIColor.black
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    private func scheduleSubtitle() -> String? {
        guard !selectedSchedule.isEmpty else { return nil }
        
        return selectedSchedule.count == Weekday.allCases.count
            ? UIHabitTrackerConstants.everyDay
            : selectedSchedule.map { $0.shortName }.joined(separator: ", ")
    }
}

extension AddTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let viewModel = CategoryViewModel(
                trackerCategoryStore: TrackerCategoryStore(),
                selectedCategoryTitle: selectedCategory
            )

            let categoryViewController = CategoryViewController(viewModel: viewModel)
            categoryViewController.delegate = self

            navigationController?.pushViewController(categoryViewController, animated: true)
        } else if indexPath.row == 1 {
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            scheduleViewController.selectedSchedule = selectedSchedule
            let navigationController = UINavigationController(rootViewController: scheduleViewController)
            present(navigationController, animated: true, completion: nil)
        }
    }
}

extension AddTrackerViewController: CategoryViewControllerDelegate {
    func didUpdateCategory(_ selectedCategory: String) {
        self.selectedCategory = selectedCategory
        tableView.reloadData()
    }
}

extension AddTrackerViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension AddTrackerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == emojiCollectionView
            ? TrackerEmojis.emojis.count
            : TrackerColors.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "EmojiCell",
                for: indexPath
            ) as? EmojiCell else {
                AppLogger.shared.error("[AddTrackerViewController]: :\(#line)] \(#function) Error unwrapping EmojiCell")
                return UICollectionViewCell()
            }
            cell.configure(with: TrackerEmojis.emojis[indexPath.item])
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ColorCell",
                for: indexPath
            ) as? ColorCell else {
                AppLogger.shared.error("[AddTrackerViewController]: :\(#line)] \(#function) Error unwrapping ColorCell")
                return UICollectionViewCell()
            }
            cell.configure(with: TrackerColors.colors[indexPath.item])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = TrackerEmojis.emojis[indexPath.item]
            AppLogger.shared.info("[AddTrackerViewController]: :\(#line)] \(#function) selected emoji: \(selectedEmoji ?? "")")
            
        } else if collectionView == colorCollectionView {
            selectedColor = TrackerColors.colors[indexPath.item]
            AppLogger.shared.info("[AddTrackerViewController]: :\(#line)] \(#function) selected color: \(selectedColor?.description ?? "")")
        }
        updateCreateButtonState()
    }
}
