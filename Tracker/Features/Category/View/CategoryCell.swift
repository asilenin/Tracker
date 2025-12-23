import UIKit

final class CategoryViewCell: UITableViewCell {
    static let reuseIdentifier = "CategoryViewCell"
    
    // MARK: - Private Properties
    private lazy var bottomSeparatorHeightConstraint: NSLayoutConstraint = {
        bottomSeparator.heightAnchor.constraint(equalToConstant: pixelHeight)
    }()
    private var pixelHeight: CGFloat { 1.5 / UIScreen.main.scale }
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupView()
        setupConstraints()
    }
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .blackYP
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .blueYP
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bottomSeparator.isHidden = false
        bottomSeparator.backgroundColor = .separator
        bottomSeparatorHeightConstraint.constant = pixelHeight
    }
    
    // MARK: - UI Elements
    private let bottomSeparator: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .separator
        v.isOpaque = true
        return v
    }()
    
    // MARK: - Setup UI
    private func setupView() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkmarkImageView)
        contentView.addSubview(bottomSeparator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            bottomSeparator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bottomSeparator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bottomSeparator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomSeparatorHeightConstraint,
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 20),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    // MARK: - Public Methods
    func setSeparatorHidden(_ hidden: Bool) {
        bottomSeparator.isHidden = hidden
    }
    
    func setSeparatorAppearance(color: UIColor = .separator, height: CGFloat? = nil) {
        bottomSeparator.backgroundColor = color
        bottomSeparatorHeightConstraint.constant = height ?? pixelHeight
        setNeedsLayout()
    }
    
    func configure(with model: CategoryCellModel) {
        titleLabel.text = model.title
        checkmarkImageView.isHidden = !model.isSelected
    }
}
