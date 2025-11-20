import UIKit

final class CategoryViewCell: UITableViewCell {
    static let reuseIdentifier = "CategoryViewCell"
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        return nil
    }
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
        ])
    }
}
