import UIKit

final class TrackerViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    weak var delegate: TrackerViewCellDelegate?
    static let reuseIdentifier = "TrackerViewCell"
    
    // MARK: - Private Properties
    private var trackerID: UUID?
    private var trackerName: String?
    private var indexPath: IndexPath?
    private var categoryTitle: String?
    private var completedDays: Int = 0
    private var currentDate: Date = Date()
    private var isFutureDate: Bool = false
    
    // MARK: - UI Elements
    private let cardView = UIView()
    private let counterLabel = UILabel()
    private let addButton = UIButton()
    private let textLabel = UILabel()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCardView()
        setupCounterLabel()
        setupEmojiLabel()
        setupTextLabel()
        setuptTitleLabel()
        setupAddButton()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("❌[TrackerViewCell][init(coder:)] has not been implemented")
    }
    
    // MARK: - Setup UI Elements
    
    private func setupCardView() {
        cardView.backgroundColor = UIColor(resource: .greenYP)
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
    }
    
    private func setupTextLabel() {
        textLabel.text = TrackViewCellMock.textText
        textLabel.numberOfLines = 0
        titleLabel.contentMode = .bottom
        textLabel.textColor = UIColor(resource: .whiteYP)
        textLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textLabel)
    }
    
    private func setupEmojiLabel() {
        emojiLabel.text = TrackViewCellMock.emojiText
        emojiLabel.textColor = UIColor(resource: .blackYP)
        emojiLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        emojiLabel.backgroundColor = .white.withAlphaComponent(0.3)
        emojiLabel.layer.cornerRadius = 12
        emojiLabel.layer.masksToBounds = true
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiLabel)
    }
    
    private func setupCounterLabel() {
        counterLabel.text = TrackViewCellMock.counterText
        counterLabel.textColor = UIColor(resource: .blackYP)
        counterLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(counterLabel)
    }
    
    private func setuptTitleLabel() {
        titleLabel.text = TrackViewCellMock.titleText
        titleLabel.textColor = UIColor(resource: .blackYP)
        titleLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        titleLabel.contentMode = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
    }
    
    private func setupAddButton() {
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        let checkmarkImage = UIImage(systemName: "checkmark")
        addButton.setImage(checkmarkImage, for: .selected)
        addButton.tintColor = UIColor(resource: .whiteYP)
        addButton.backgroundColor = UIColor(resource: .greenYP)
        addButton.layer.cornerRadius = 16
        addButton.clipsToBounds = true
        addButton.contentMode = .scaleAspectFit
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        contentView.addSubview(addButton)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 18),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            cardView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            addButton.heightAnchor.constraint(equalToConstant: 34),
            addButton.widthAnchor.constraint(equalToConstant: 34),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            addButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            counterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            counterLabel.heightAnchor.constraint(equalToConstant: 18),
            counterLabel.centerYAnchor.constraint(equalTo: addButton.centerYAnchor), //
            counterLabel.trailingAnchor.constraint(lessThanOrEqualTo: addButton.leadingAnchor, constant: -8),
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            textLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            textLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            textLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
        ])
    }
    
    // MARK: - Actions
    
    @objc func addButtonTapped() {
        guard let trackerID = trackerID, let indexPath = indexPath else {
            return
        }
        if isFutureDate {
            return
        }
        let newIsCompleted = !addButton.isSelected
        if newIsCompleted {
            completedDays += 1
            delegate?.didTapCompleteButton(trackerId: trackerID, at: indexPath)
        } else {
            completedDays -= 1
            delegate?.didTapUnCompleteButton(trackerId: trackerID, at: indexPath)
        }
        updateCounterLabelText(completedDays: completedDays)
        updateAddButtonView(isCompleted: newIsCompleted)
        addButton.isSelected = newIsCompleted
    }
    
    // MARK: - Configuration
    
    func configure(isCompleted: Bool, trackerID: UUID, trackerName: String, indexPath: IndexPath, categoryTitle: String, completedDays: Int, currentDate: Date) {
        self.trackerID = trackerID
        self.textLabel.text = trackerName
        self.indexPath = indexPath
        self.categoryTitle = categoryTitle
        self.completedDays = completedDays
        self.currentDate = currentDate
        isFutureDate = currentDate > Date()
        updateCounterLabelText(completedDays: completedDays)
        updateAddButtonView(isCompleted: isCompleted)
        addButton.isSelected = isCompleted
        titleLabel.isHidden = indexPath.row != 0
        titleLabel.text = categoryTitle
        if isFutureDate {
            addButton.isEnabled = false
            addButton.backgroundColor = .gray
        } else {
            addButton.isEnabled = true
        }
    }
    
    // MARK: - Update UI
    
    private func updateAddButtonView(isCompleted: Bool) {
        addButton.isSelected = isCompleted
        let image = isCompleted ? UIImage(named: "Plus") : UIImage(systemName: "plus")
        addButton.setImage(image, for: .normal)
        if isFutureDate {
            addButton.backgroundColor = UIColor.gray
        } else {
            addButton.backgroundColor = isCompleted ? UIColor(resource: .greenYP).withAlphaComponent(0.3) : UIColor(resource: .greenYP)
        }
    }
    
    private func setCategoryTitle(_ title: String) {
        if self.categoryTitle == nil {
            self.categoryTitle = title
            titleLabel.text = title
        }
    }
    
    private func updateCounterLabelText(completedDays: Int){
        let days = completedDays % 100
        if (11...14).contains(days) {
            counterLabel.text = "\(completedDays) дней"
        } else {
            switch days % 10 {
            case 1:
                counterLabel.text = "\(completedDays) день"
            case 2...4:
                counterLabel.text = "\(completedDays) дня"
            default:
                counterLabel.text = "\(completedDays) дней"
            }
        }
    }
}
