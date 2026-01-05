import UIKit

protocol CategoryScheduleViewCellDelegate: AnyObject {
    func didTapCategoryButton()
}

final class CategoryScheduleViewCell: UITableViewCell {
    
    // MARK: - Properties
    weak var delegate: CategoryScheduleViewCellDelegate?
    static let reuseIdentifier = "CategoryScheduleViewCell"
    
    // MARK: - Private Properties
    private var separatorHeight: CGFloat {
        1.5 / UIScreen.main.scale
    }

    private lazy var bottomSeparatorHeightConstraint: NSLayoutConstraint = {
        bottomSeparator.heightAnchor.constraint(equalToConstant: separatorHeight)
    }()
    
    // MARK: - UI Elements
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    private let bottomSeparator: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .greyYP
        v.isOpaque = true
        return v
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupTitleLabel()
        setupSubtitleLabel()
        contentView.addSubview(bottomSeparator)
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bottomSeparator.isHidden = false
        bottomSeparator.backgroundColor = .greyYP
        bottomSeparatorHeightConstraint.constant = separatorHeight
    }
    
    // MARK: - Setup UI Elements
    private func setupTitleLabel() {
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
    }
    
    private func setupSubtitleLabel(){
        subtitleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            bottomSeparator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bottomSeparator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bottomSeparator.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -1
            ),
            bottomSeparatorHeightConstraint
        ])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14)
        ])
    }
    
    // MARK: - Configuration
    func configure(title: String, subtitle: String?) {
        titleLabel.text = title
        titleLabel.textColor = .blackYP

        subtitleLabel.text = subtitle
        subtitleLabel.textColor = .greyYP
        subtitleLabel.isHidden = (subtitle == nil || subtitle?.isEmpty == true)
    }
    
    func setSeparatorHidden(_ hidden: Bool) {
        bottomSeparator.isHidden = hidden
    }
    
    func setSeparatorAppearance(color: UIColor = .separator, height: CGFloat? = nil) {
        bottomSeparator.backgroundColor = color
        bottomSeparatorHeightConstraint.constant = height ?? separatorHeight
        setNeedsLayout()
    }
}
