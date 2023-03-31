
import UIKit

protocol EditCategoryViewDelegate: AnyObject {
    func editCategory()
}

final class EditCategoryView: UIView {
    
    weak var delegate: EditCategoryViewDelegate?
    
    private struct CategoryViewConstant {
        static let editButtonTitle = "Готово"
        static let editCategoryTextFieldPlaceholderText = "Введите название категории"
    }
    
    private var editCategoryViewTextFieldHelper = EditCategoryViewTextFieldHelper()
    
    private lazy var editCategoryTextField: TrackerTextField = {
        let textField = TrackerTextField(
            frame: .zero,
            placeholderText: CategoryViewConstant.editCategoryTextFieldPlaceholderText
        )
        return textField
    }()

    
    private lazy var editButton: TrackerButton = {
        let button = TrackerButton(
            frame: .zero,
            title: CategoryViewConstant.editButtonTitle
        )
        button.addTarget(
            self,
            action: #selector(editButtonTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    init(
        frame: CGRect,
        delegate: EditCategoryViewDelegate?
    ) {
        self.delegate = delegate
        super.init(frame: frame)
        
        editCategoryTextField.delegate = editCategoryViewTextFieldHelper
       
        
        setupView()
        addSubviews()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .ypWhite
    }
    
    private func addSubviews() {
        addSubViews(
            editCategoryTextField,
            editButton
        )
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
           editCategoryTextField.heightAnchor.constraint(equalToConstant: Constants.hugHeight),
           editCategoryTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.indentationFromEdges),
           editCategoryTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.indentationFromEdges),
           editCategoryTextField.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            
            editButton.heightAnchor.constraint(equalToConstant: Constants.hugHeight),
            editButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.indentationFromEdges),
            editButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.indentationFromEdges),
            editButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
        ])
    }
    
    @objc
    private func editButtonTapped() {
        editButton.showAnimation { [weak self] in
            guard let self = self else { return }
            self.delegate?.editCategory()
        }
    }
}

