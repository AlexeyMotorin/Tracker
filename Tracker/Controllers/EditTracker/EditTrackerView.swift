import UIKit

protocol EditTrackerViewDelegate: AnyObject {
    func sendTrackerSetup(nameTracker: String?, color: UIColor, emoji: String, isChecked: Bool)
    func cancelCreate()
    func showCategory()
    func showSchedule()
}

final class EditTrackerView: UIView {
    
    // MARK: -Delegate
    weak var delegate: EditTrackerViewDelegate?
    
    // MARK: -CreateTrackerViewConstants
    private struct CreateTrackerViewConstants {
        static let cancelButtonTitle = "Отменить"
        static let createButtonTitle = "Создать"
        static let errorLabelText = "Ограничение 38 символов"
        static let textFieldPlaceholder = "Введите название трекера"
        static let defaultCellIdentifier = "cell"
        static let spacingConstant: CGFloat = 8
    }
    
    // MARK: -Private properties
    private var editTypeTracker: EditTypeTracker
    private var contentSize: CGSize {
        switch editTypeTracker {
        case .editEvent:
            return CGSize(width: frame.width, height: 931)
        case .editHabit:
            return CGSize(width: frame.width, height: 1031)
        }
    }
    
    private let editTracker: EditTracker
    
    private var emojiAndColorCollectionViewHelper: ColorAndEmojiCollectionViewHelper
    private var scheduleCategoryTableViewHelper: ScheduleCategoryTableViewHelper
    private var nameTrackerTextFieldHelper =  NameTrackerTextFieldHelper()
    
    private var emoji: String?
    private var color: UIColor?
    private var isChecked: Bool?
    
    private var topViewConstraint: NSLayoutConstraint!
    
    // MARK: UI
    private lazy var editCountDaysView: EditCountDaysView = {
        let view = EditCountDaysView()
        view.delegate = self
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.contentSize = contentSize
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        contentView.frame.size = contentSize
        return contentView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    private lazy var nameTrackerTextField: TrackerTextField = {
        let textField = TrackerTextField(
            frame: .zero,
            placeholderText: CreateTrackerViewConstants.textFieldPlaceholder
        )
        return textField
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.ypRegularSize17
        label.textColor = .ypRed
        label.text = CreateTrackerViewConstants.errorLabelText
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    private lazy var scheduleCategoryTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: CreateTrackerViewConstants.defaultCellIdentifier
        )
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = Constants.cornerRadius
        return tableView
    }()
    
    private let colorAndEmojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: "emojiCell"
        )
        collectionView.register(
            EmojiCollectionViewCell.self,
            forCellWithReuseIdentifier: EmojiCollectionViewCell.cellReuseIdentifier
        )
        collectionView.register(
            HeaderReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HeaderReusableView.reuseIdentifier)
        collectionView.register(
            ColorCollectionViewCell.self,
            forCellWithReuseIdentifier: ColorCollectionViewCell.cellReuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = CreateTrackerViewConstants.spacingConstant
        return stackView
    }()
    
    private lazy var cancelButton: TrackerButton = {
        let button = TrackerButton(
            frame: .zero,
            title: CreateTrackerViewConstants.cancelButtonTitle
        )
        button.addTarget(
            self,
            action: #selector(cancelButtonTapped),
            for: .touchUpInside
        )
        button.setTitleColor(.ypRed, for: .normal)
        button.backgroundColor = .ypWhite
        button.layer.borderColor = UIColor.ypRed?.cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    private lazy var createButton: TrackerButton = {
        let button = TrackerButton(
            frame: .zero,
            title: CreateTrackerViewConstants.createButtonTitle
        )
        button.addTarget(
            self,
            action: #selector(createButtonTapped),
            for: .touchUpInside
        )
        button.backgroundColor = .ypBlack
        return button
    }()
    
    // MARK: -Initialization
    init(
        frame: CGRect,
        editTypeTracker: EditTypeTracker,
        editTracker: EditTracker
    ) {
        self.editTypeTracker = editTypeTracker
        self.editTracker = editTracker
        emojiAndColorCollectionViewHelper = ColorAndEmojiCollectionViewHelper()
        scheduleCategoryTableViewHelper = ScheduleCategoryTableViewHelper(editTypeTracker: editTypeTracker)
        super.init(frame: frame)
        
        colorAndEmojiCollectionView.dataSource = emojiAndColorCollectionViewHelper
        colorAndEmojiCollectionView.delegate = emojiAndColorCollectionViewHelper
        
        scheduleCategoryTableView.dataSource = scheduleCategoryTableViewHelper
        scheduleCategoryTableView.delegate = scheduleCategoryTableViewHelper
        
        nameTrackerTextField.delegate = nameTrackerTextFieldHelper
        emojiAndColorCollectionViewHelper.delegate = self
        
        nameTrackerTextFieldHelper.delegate = self
        scheduleCategoryTableViewHelper.delegate = self
        
        setupView(with: editTracker)
        addViews()
        activateConstraints()
        trackerSetup(editTracker: editTracker)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCategory(with category: String?) {
        scheduleCategoryTableViewHelper.setCategory(category: category)
    }
    
    func setSchedule(with schedule: String?) {
        scheduleCategoryTableViewHelper.setSchedule(schedule: schedule)
    }
    
    func setEmoji(emoji: String) {
        emojiAndColorCollectionViewHelper.setEmoji(emoji: emoji)
    }
    
    func setSelectedTrackerColor(color: UIColor?) {
        emojiAndColorCollectionViewHelper.setColor(color: color)
    }
    
    // MARK: - Private methods
    private func setupView(with editTracker: EditTracker) {
        editCountDaysView.config(
            countDay: editTracker.checkCountDay,
            isChecked: editTracker.isChecked,
            canCheck: editTracker.canCheck
        )
        nameTrackerTextField.text = editTracker.tracker.name
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .ypWhite
    }
    
    private func addViews() {
        addSubViews(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubViews(
            editCountDaysView,
            nameTrackerTextField,
            errorLabel,
            stackView,
            buttonStackView
        )
        
        stackView.addArrangedSubview(scheduleCategoryTableView)
        stackView.addArrangedSubview(colorAndEmojiCollectionView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
    }
    
    private func activateConstraints() {
        
        var tableViewHeight: CGFloat = Constants.hugHeight
        
        switch editTypeTracker {
        case .editHabit:
            tableViewHeight *= 2
        case .editEvent:
            break
        }
        
        let buttonHeight: CGFloat = 60
        let verticalAxis: CGFloat = 10
        let edge = Constants.indentationFromEdges
        
        let insetBetweenNameTextFieldAndStackView: CGFloat = 24
        let nameTrackerTextFieldTopAnchorConstant: CGFloat = 42
        
        topViewConstraint = stackView.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: insetBetweenNameTextFieldAndStackView)
        topViewConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            editCountDaysView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalAxis),
            editCountDaysView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            nameTrackerTextField.topAnchor.constraint(equalTo: editCountDaysView.bottomAnchor, constant: nameTrackerTextFieldTopAnchorConstant),
            nameTrackerTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: edge),
            nameTrackerTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -edge),
            nameTrackerTextField.heightAnchor.constraint(equalToConstant: Constants.hugHeight),
            
            errorLabel.leadingAnchor.constraint(equalTo: nameTrackerTextField.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: nameTrackerTextField.trailingAnchor),
            errorLabel.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 8),
            
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: edge),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -edge),
            stackView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -10),
            
            buttonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: edge),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -edge),
            buttonStackView.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            scheduleCategoryTableView.heightAnchor.constraint(equalToConstant: tableViewHeight),
        ])
    }
    
    private func trackerSetup(editTracker: EditTracker) {
        emoji = editTracker.tracker.emoji
        color = editTracker.tracker.color
        isChecked = editTracker.isChecked
    }
    
    @objc
    private func createButtonTapped() {
        createButton.showAnimation { [weak self] in
            guard
                let self = self,
                self.nameTrackerTextField.text != "",
                let selectedEmoji = self.emoji,
                let selectedColor = self.color,
                let isChecked = self.isChecked else { return }
            self.delegate?.sendTrackerSetup(
                nameTracker: self.nameTrackerTextField.text,
                color: selectedColor,
                emoji: selectedEmoji,
                isChecked: isChecked
            )
        }
    }
    
    @objc
    private func cancelButtonTapped() {
        cancelButton.showAnimation { [weak self] in
            guard let self = self else { return }
            self.delegate?.cancelCreate()
        }
    }
}

extension EditTrackerView: NameTrackerTextFieldHelperDelegate {
    func noLimitedCharacters() {
        topViewConstraint.constant = 24
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.errorLabel.alpha = 0
            self.layoutIfNeeded()
        }
    }
    
    func askLimitedCharacter() {
        topViewConstraint.constant = 40
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.errorLabel.alpha = 1
            self.layoutIfNeeded()
        }
    }
}

extension EditTrackerView: ScheduleCategoryTableViewHelperDelegate {
    func reloadTableView() {
        scheduleCategoryTableView.reloadData()
    }
    
    func showSchedule() {
        delegate?.showSchedule()
    }
    
    func showCategory() {
        delegate?.showCategory()
    }
}

extension EditTrackerView: ColorAndEmojiCollectionViewHelperDelegate {
    func sendSelectedEmoji(_ emoji: String?) {
        self.emoji = emoji
    }
    
    func sendSelectedColor(_ color: UIColor?) {
        self.color = color
    }
}

extension EditTrackerView: EditCountDaysViewDelegate {
    func checkDay() {
        isChecked = true
    }
    
    func uncheckDay() {
        isChecked = false
    }
}
