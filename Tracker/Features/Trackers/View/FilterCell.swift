import UIKit

final class FiltersCell: UITableViewCell {

    static let reuseId = "FiltersCell"

    private let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        backgroundColor = .backgroundTableYP
        contentView.backgroundColor = .backgroundTableYP

        titleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = .blackYP
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 25),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -26),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    func configure(title: String, isSelected: Bool) {
        titleLabel.text = title
        accessoryType = isSelected ? .checkmark : .none
        tintColor = .blueYP
    }
}
