import UIKit

protocol AddCategoryViewControllerDelegate: AnyObject {
    func didCreateCategory(_ categoryTitle: String)
}

final class AddCategoryViewController: UIViewController {
    
    weak var delegate: AddCategoryViewControllerDelegate?
    
    // MARK: - Private Properties
    private let textField = UITextField()
    private let doneButton = UIButton()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        setupDoneButton()
        setupView()
        setupConstraints()
        doneButton.isEnabled = false
        doneButton.backgroundColor = .blackYP
    }
    
    // MARK: - Actions
    @objc private func doneButtonTapped() {
        if let text = textField.text, !text.isEmpty {
            delegate?.didCreateCategory(text)
        }
        dismiss(animated: true)
    }
    
    // MARK: - Setup UI
    private func setupTextField() {
        textField.placeholder = UICategoryConstants.namePlaceholder
        textField.backgroundColor = .backgroundTableYP
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.clearButtonMode = .whileEditing
        textField.textColor = .blackYP
        textField.returnKeyType = .done
        textField.enablesReturnKeyAutomatically = true
        textField.smartInsertDeleteType = .no
        textField.leftViewMode = .always
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
    }
    
    private func setupDoneButton() {
        doneButton.backgroundColor = .blackYP
        doneButton.layer.cornerRadius = 16
        doneButton.layer.masksToBounds = true
        doneButton.setTitle(UIScheduleConstants.doneButtonTitle, for: .normal)
        doneButton.setTitleColor(.whiteYP, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)
    }
    
    private func setupView() {
        navigationItem.title = UICategoryConstants.title
        view.backgroundColor = .whiteYP
    }
    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}

// MARK: - UITextFieldDelegate
extension AddCategoryViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let isEnabled = !(textField.text?.isEmpty ?? true)
        doneButton.isEnabled = isEnabled
        doneButton.backgroundColor = isEnabled ? .blackYP : .greyYP
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
