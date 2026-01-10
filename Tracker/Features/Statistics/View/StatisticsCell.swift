import UIKit

final class StatisticsCell: UICollectionViewCell {

    static let reuseIdentifier = "StatisticsCell"

    // MARK: - UI
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()
    private let containerView = UIView()

    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientFrame()
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        updateGradientFrame()
    }
    
    //MARK: - Public Methods
    func configure(with model: StatisticsItem) {
        valueLabel.text = "\(model.value)"
        titleLabel.text = model.title
    }
    
    // MARK: - Configuration
    private func setupView() {
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = false

        containerView.backgroundColor = .backgroundTableYP
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = false

        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        setupLabels()
        setupGradientBorder()
    }
    
    private func setupLabels() {
        valueLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        valueLabel.textColor = .blackYP

        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .blackYP

        let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = 8

        containerView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    private func setupGradientBorder() {
        gradientLayer.colors = [
            UIColor(resource: .redYP).cgColor,
            UIColor(resource: .greenYP).cgColor,
            UIColor(resource: .blueYP).cgColor
        ]

        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 1

        gradientLayer.mask = shapeLayer
        contentView.layer.addSublayer(gradientLayer)
    }
    
    private func updateGradientFrame() {
        gradientLayer.frame = contentView.bounds

        guard let shapeLayer = gradientLayer.mask as? CAShapeLayer else { return }

        let inset = shapeLayer.lineWidth / 2
        shapeLayer.path = UIBezierPath(
            roundedRect: contentView.bounds.insetBy(dx: inset, dy: inset),
            cornerRadius: 16 - inset
        ).cgPath
    }
}
