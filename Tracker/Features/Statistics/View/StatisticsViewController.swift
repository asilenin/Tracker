import UIKit

final class StatisticsViewController: UIViewController {

    // MARK: - Properties
    
    // MARK: - Private Properties
    private let trackerStore = TrackerStore()
    private let recordStore = TrackerRecordStore()

    // MARK: - ViewModel
    private lazy var viewModel = StatisticsViewModel(
        recordStore: recordStore,
        trackerStore: trackerStore
    )

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
    
    // MARK: - UI Elements
       private lazy var clearTextLabel = UILabel()
       private lazy var  clearImageView = UIImageView()
       private lazy var  collectionView: UICollectionView = {
           let layout = UICollectionViewFlowLayout()
           return UICollectionView(frame: .zero, collectionViewLayout: layout)
       }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setupUI()
        viewModel.reload()
    }
    
    // MARK: - Configuration
    private func setupUI() {
        setupView()
        setupTitle()
        setupClearImageView()
        setupClearTextLabel()
        setupCollectionView()
        setupConstraints()
    }
    
    private func setupView() {
        view.backgroundColor = .whiteYP
    }

    private func setupTitle() {
        navigationItem.title = UIStatisticsConstants.title
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupClearImageView() {
        clearImageView.image = UIImage(resource: .statisticsEmpty)
        clearImageView.translatesAutoresizingMaskIntoConstraints = false
        clearImageView.contentMode = .scaleAspectFit
        view.addSubview(clearImageView)
    }
    
    private func setupClearTextLabel() {
        clearTextLabel.text = UIStatisticsConstants.clearText
        clearTextLabel.font = .systemFont(ofSize: 12, weight: .medium)
        clearTextLabel.textColor = .blackYP
        clearTextLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clearTextLabel)
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .whiteYP

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(
            StatisticsCell.self,
            forCellWithReuseIdentifier: StatisticsCell.reuseIdentifier
        )

        view.addSubview(collectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            clearImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clearImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),

            clearTextLabel.topAnchor.constraint(equalTo: clearImageView.bottomAnchor, constant: 8),
            clearTextLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func bind() {
        viewModel.onUpdate = { [weak self] in
            self?.render()
        }
    }

    private func render() {
        collectionView.reloadData()
        updateClearView()
    }
    
    private func updateClearView() {
        let isEmpty = viewModel.statistics.isEmpty

        clearImageView.isHidden = !isEmpty
        clearTextLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
}

extension StatisticsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.statistics.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: StatisticsCell.reuseIdentifier,
            for: indexPath
        ) as? StatisticsCell else {
            return UICollectionViewCell()
        }

        let item = viewModel.statistics[indexPath.item]
        cell.configure(with: item)

        return cell
    }
}

extension StatisticsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let width = collectionView.bounds.width - 32
        return CGSize(width: width, height: 90)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        12
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}
