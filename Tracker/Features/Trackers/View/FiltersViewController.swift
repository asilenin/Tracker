import UIKit
final class FiltersViewController: UIViewController {
    // MARK: - Properties
    var onSelect: ((TrackerFilter) -> Void)?
    
    // MARK: - Private Properties
    private var selectedFilter: TrackerFilter
    
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = TrackerFilterConstants.listTitle
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .whiteYP
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    // MARK: - Initializers
    init(selectedFilter: TrackerFilter) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    private func setupView(){
        view.backgroundColor = .whiteYP
        
        tableView.register(FiltersCell.self, forCellReuseIdentifier: FiltersCell.reuseId)
        view.addSubview(titleLabel)
        
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

}

extension FiltersViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TrackerFilter.allCases.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FiltersCell.reuseId,
            for: indexPath
        ) as? FiltersCell else {
            return UITableViewCell()
        }

        let filter = TrackerFilter.allCases[indexPath.row]
        let isSelected = filter == selectedFilter && filter.showsCheckmark

        cell.configure(
            title: filter.title,
            isSelected: isSelected
        )

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filter = TrackerFilter.allCases[indexPath.row]
        onSelect?(filter)
        dismiss(animated: true)
    }
}
