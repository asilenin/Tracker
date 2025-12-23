import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func didUpdateCategory(_ categoryTitle: String)
}

final class CategoryViewController: UIViewController{
    
    // MARK: - Public Properties
    weak var delegate: CategoryViewControllerDelegate?
    
    // MARK: - Private Properties
    private var viewModel: CategoryViewModelProtocol
    
    // MARK: - Init
    init(viewModel: CategoryViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - UI Elements
    private let tableView = UITableView()
    private let doneButton = UIButton()
    private var clearImageView = UIImageView()
    private let clearTextLabel = UILabel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupView()
        setupTableView()
        setupDoneButton()
        setupClearImageView()
        setupClearTextLabel()
        setupConstraints()
        bindViewModel()
        
        tableView.reloadData()
        updateClearView()
        refreshCustomSeparators()
    }
    
    // MARK: - Setup UI
    private func setupView() {
        view.backgroundColor = .white
        navigationItem.title = UICategoryConstants.navigationTitle
        let title: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.black
        ]
        navigationController?.navigationBar.titleTextAttributes = title
    }
    
    private func setupClearTextLabel() {
        clearTextLabel.text = UICategoryConstants.clearTextLabel
        clearTextLabel.numberOfLines = 2
        clearTextLabel.textColor = .blackYP
        clearTextLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        clearTextLabel.textAlignment = .center
        clearTextLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clearTextLabel)
    }
    
    private func setupClearImageView() {
        clearImageView.image = .clearListStar
        clearImageView.translatesAutoresizingMaskIntoConstraints = false
        clearImageView.contentMode = .scaleAspectFit
        clearImageView.tintColor = .blackYP
        view.addSubview(clearImageView)
    }
    
    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.tableFooterView = UIView()
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryViewCell.self, forCellReuseIdentifier: CategoryViewCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
    }
    
    private func setupDoneButton() {
        doneButton.setTitle(UICategoryConstants.addButtonTitle, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = .blackYP
        doneButton.layer.cornerRadius = 16
        doneButton.layer.masksToBounds = true
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -24),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            
            clearImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clearImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            clearImageView.widthAnchor.constraint(equalToConstant: 80),
            clearImageView.heightAnchor.constraint(equalToConstant: 80),

            clearTextLabel.topAnchor.constraint(equalTo: clearImageView.bottomAnchor, constant: 8),
            clearTextLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Private Methods
    private func updateClearView() {
        let hasContent = !viewModel.categories.isEmpty
        
        clearImageView.isHidden = hasContent
        clearTextLabel.isHidden = hasContent
        
        tableView.isHidden = !hasContent
    }
    
    private func bindViewModel() {
        viewModel.onCategoriesUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.updateClearView()
                self?.refreshCustomSeparators()
            }
        }
    }
    
    private func configureAppearance(for cell: UITableViewCell, at indexPath: IndexPath) {
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16
        if numberOfRows == 1 {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            if indexPath.row == 0 {
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else if indexPath.row == numberOfRows - 1 {
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            } else {
                cell.layer.maskedCorners = []
            }
        }
    }
    
    private func refreshCustomSeparators() {
        guard let visibleIndexPaths = tableView.indexPathsForVisibleRows else { return }
        for indexPath in visibleIndexPaths {
            if let cell = tableView.cellForRow(at: indexPath) as? CategoryViewCell {
                let lastRow = tableView.numberOfRows(inSection: indexPath.section) - 1
                cell.setSeparatorHidden(indexPath.row == lastRow)
            }
        }
    }
    
    @objc private func doneButtonTapped() {
        let addCategoryViewController = AddCategoryViewController()
        addCategoryViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: addCategoryViewController)
        present(navigationController, animated: true)
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryViewCell.reuseIdentifier,
            for: indexPath
        ) as? CategoryViewCell else {
            return UITableViewCell()
        }

        let model = viewModel.cellModel(at: indexPath)

        cell.configure(with: model)
        
        return cell
    }
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < viewModel.categories.count else {
            return
        }
        viewModel.didSelectCategory(at: indexPath)
        
        if let selectedCategory = viewModel.selectedCategory {
            delegate?.didUpdateCategory(selectedCategory.title)
        }

        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        configureAppearance(for: cell, at: indexPath)
        if let cell = cell as? CategoryViewCell {
            let lastRow = tableView.numberOfRows(inSection: indexPath.section) - 1
            cell.setSeparatorHidden(indexPath.row == lastRow)
        }
    }
}

extension CategoryViewController: AddCategoryViewControllerDelegate {
    func didCreateCategory(_ categoryTitle: String) {
        viewModel.createCategory(title: categoryTitle)
    }
}
