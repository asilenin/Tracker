import UIKit

protocol AddTrackerViewControllerDelegate: AnyObject {
    func addNewTracker(tracker: Tracker, title: String)
    func removeTrackerRecord(trackerId: UUID, date: Date)
}

final class AddTrackerViewController: UIViewController, UITextFieldDelegate, ScheduleViewControllerDelegate {
    
    // MARK: - Properties
    weak var delegate: AddTrackerViewControllerDelegate?
    
    // MARK: - Private Properties
    private let sections = [UIHabbitTrackerConstants.sectionCategory, UIHabbitTrackerConstants.sectionSchedule]
    private var categories: [String] = [UIHabbitTrackerConstants.categoryImportant, UIHabbitTrackerConstants.categoryUnimportant]
    private var trackerId: UUID!
    private var currentDate: Date?
    private var selectedSchedule: [Weekday] = []
    private var selectedCategory: String?
    
    // MARK: - UI Elements
    private let trackerNameTextField = UITextField()
    private let tableView = UITableView()
    private let createButton = UIButton()
    private let cancelButton = UIButton()
    private let errorLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupErrorLabel()
        setupTitle()
        setupNameTrackerTextField()
        setupTableView()
        setupCreateButton()
        setupCancelButton()
        setupConstraints()
        tableView.dataSource = self
        tableView.delegate = self
        trackerNameTextField.delegate = self
    }
    
    // MARK: - Setup UI Elements
    private func setupView() {
        view.backgroundColor = .whiteYP
    }
    
    private func setupErrorLabel(){
        errorLabel.textColor = UIColor(resource: .redYP)
        errorLabel.font = .systemFont(ofSize: 17, weight: .regular)
        errorLabel.text = UIHabbitTrackerConstants.errorMessage
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)
    }
    
    private func setupTitle(){
        navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 16, weight: .medium)]
        navigationItem.title = UIHabbitTrackerConstants.title
    }
    
    private func setupNameTrackerTextField() {
        trackerNameTextField.placeholder = UIHabbitTrackerConstants.namePlaceholder
        trackerNameTextField.backgroundColor = UIColor(resource: .backgroudYP).withAlphaComponent(0.3)
        trackerNameTextField.layer.cornerRadius = 16
        trackerNameTextField.layer.masksToBounds = true
        trackerNameTextField.clearButtonMode = .whileEditing
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: trackerNameTextField.frame.height))
        trackerNameTextField.leftView = paddingView
        trackerNameTextField.leftViewMode = .always
        trackerNameTextField.returnKeyType = .done
        trackerNameTextField.enablesReturnKeyAutomatically = true
        trackerNameTextField.smartInsertDeleteType = .no
        trackerNameTextField.textColor = UIColor(resource: .greyYP)
        trackerNameTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        trackerNameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackerNameTextField)
    }
    
    private func setupTableView() {
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryScheduleViewCell.self, forCellReuseIdentifier: CategoryScheduleViewCell.reuseIdentifier)
        view.addSubview(tableView)
    }
    
    private func setupCreateButton() {
        createButton.setTitle(UIHabbitTrackerConstants.createlButton, for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createButton.setTitleColor(.white, for: .normal)
        createButton.backgroundColor = UIColor(resource: .greyYP)
        createButton.layer.cornerRadius = 16
        createButton.layer.masksToBounds = true
        createButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createButton)
    }
    
    private func setupCancelButton() {
        cancelButton.setTitle(UIHabbitTrackerConstants.cancelButton, for: .normal)
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
            trackerNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            trackerNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            errorLabel.heightAnchor.constraint(equalToConstant: 22),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 8),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            tableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150)
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
        if newText.count > 38 {
            errorLabel.isHidden = false
            return false
        } else {
            errorLabel.isHidden = true
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == trackerNameTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: - Private Methods
    @objc private func saveButtonTapped(){
        guard let name = trackerNameTextField.text, !name.isEmpty else {
            return
        }
        errorLabel.isHidden = true
        let newTracker = Tracker(id: UUID(), name: name, color: UIColor(resource: .redYP), emoji: "🙂", schedule: selectedSchedule)
        guard let selectedCategory = selectedCategory else {
            return
        }
        delegate?.addNewTracker(tracker: newTracker, title: selectedCategory)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancelButtonTapped(){
        dismiss(animated: true)
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
        var subtitle: String? = nil
        if indexPath.row == 0 {
            subtitle = selectedCategory
        } else if indexPath.row == 1 && !selectedSchedule.isEmpty {
            let dayAbbreviations = selectedSchedule.map { day in
                switch day {
                case .monday: return "Пн"
                case .tuesday: return "Вт"
                case .wednesday: return "Ср"
                case .thursday: return "Чт"
                case .friday: return "Пт"
                case .saturday: return "Сб"
                case .sunday: return "Вс"
                }
            }
            subtitle = dayAbbreviations.joined(separator: ", ")
        }
        cell.configure(title: title, subtitle: subtitle)
        cell.accessoryType = .disclosureIndicator
        cell.contentView.backgroundColor = UIColor(resource: .backgroudYP).withAlphaComponent(0.3)
        let backgroundColor = UIColor(resource: .backgroudYP).withAlphaComponent(0.3)
        cell.backgroundColor = backgroundColor
        cell.contentView.backgroundColor = .clear
        cell.titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        cell.titleLabel.textColor = UIColor.black
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension AddTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let categoryViewController = CategoryViewController()
            categoryViewController.categories = categories
            categoryViewController.delegate = self
            categoryViewController.selectedCategory = selectedCategory
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
