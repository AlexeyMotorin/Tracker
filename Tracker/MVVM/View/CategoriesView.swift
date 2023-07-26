import UIKit

enum EditCategory {
    case addCategory
    case editCategory
}

protocol CategoriesViewDelegate: AnyObject {
    func showEditCategoryViewController(type: EditCategory, editCategoryString: String?, at indexPath: IndexPath?)
    func showDeleteActionSheet(deleteCategory: TrackerCategoryCoreData)
    func showErrorAlert()
    func selectedCategory(categoryCoreData: TrackerCategoryCoreData?)
}

final class CategoriesView: UIView {
    
    weak var delegate: CategoriesViewDelegate?
    private var viewModel: CategoriesViewModelProtocol?
    
    private struct CategoryViewConstant {
        static let collectionViewReuseIdentifier = "Cell"
        static let addButtonTitle = "Добавить категорию"
        static let plugLabelText = """
            Привычки и события можно
            объединить по смыслу
        """
    }
    
    //MARK: UI
    private lazy var plugView: PlugView = {
        let plugView = PlugView(
            frame: .zero,
            titleLabel: CategoryViewConstant.plugLabelText,
            image: UIImage(named: "plug") ?? UIImage()
        )
        plugView.isHidden = true
        return plugView
    }()
    
    private lazy var categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: CategoryViewConstant.collectionViewReuseIdentifier
        )
        collectionView.register(
            CategoryCollectionViewCell.self,
            forCellWithReuseIdentifier: CategoryCollectionViewCell.cellReuseIdentifier
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var addButton: TrackerButton = {
        let button = TrackerButton(
            frame: .zero,
            title: CategoryViewConstant.addButtonTitle
        )
        button.addTarget(
            self,
            action: #selector(addButtonTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    // MARK: - initializers
    init(
        frame: CGRect,
        delegate: CategoriesViewDelegate?,
        viewModel: CategoriesViewModelProtocol
    ) {
        self.delegate = delegate
        self.viewModel = viewModel
        
        super.init(frame: frame)
       
        bind()
        viewModel.needToHidePlugView()
            
        setupView()
        addSubviews()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public properties
    func reloadCollectionView() {
        viewModel?.updateCategories()
    }
    
    // MARK: - Private properties
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .ypWhite
    }
    
    private func addSubviews() {
        addSubViews(
            categoryCollectionView,
            addButton,
            plugView
        )
    }
    
    private func activateConstraints() {
        let plugViewTopConstant = frame.height / 3.5
        let addButtonBottomAnchorConstant: CGFloat = -50
        
        NSLayoutConstraint.activate([
            categoryCollectionView.topAnchor.constraint(equalTo: topAnchor),
            categoryCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.indentationFromEdges),
            categoryCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.indentationFromEdges),
            categoryCollectionView.bottomAnchor.constraint(equalTo: addButton.topAnchor),
            
            addButton.heightAnchor.constraint(equalToConstant: Constants.hugHeight),
            addButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.indentationFromEdges),
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.indentationFromEdges),
            addButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: addButtonBottomAnchorConstant),
            
            plugView.topAnchor.constraint(equalTo: topAnchor, constant: plugViewTopConstant),
            plugView.leadingAnchor.constraint(equalTo: leadingAnchor),
            plugView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func bind() {
        viewModel?.hidePlugView = { [weak self] in
            guard let self = self else { return }
            self.plugView.isHidden = $0
        }
        viewModel?.needToUpdateCollectionView = { [weak self] in
            guard let self = self, $0 else { return }
            self.categoryCollectionView.reloadData()
        }
    }
    
    private func createContextMenu(indexPath: IndexPath) -> UIContextMenuConfiguration {
        return UIContextMenuConfiguration(actionProvider: { [weak self] actions in
            guard
                let self,
                let selectedCategory = self.viewModel?.didSelectCategory(by: indexPath)
            else { return UIMenu() }
            
            return UIMenu(children: [
                UIAction(title: "Редактировать") { _ in
                    self.delegate?.showEditCategoryViewController(
                        type: .editCategory,
                        editCategoryString: selectedCategory.title,
                        at: indexPath
                    )
                },
                UIAction(title: "Удалить", attributes: .destructive, handler: { _ in
                    guard let cell = self.viewModel?.categoryCellViewModel(at: indexPath) else { return }
                    cell.selectedCategory ? self.delegate?.showErrorAlert() : self.delegate?.showDeleteActionSheet(deleteCategory: selectedCategory)
                })
            ])
        })
    }
    
    private func setCellCornerRadius(cell: CategoryCollectionViewCell, numberRow: Int) {
        cell.layer.masksToBounds = true
        
        guard let viewModel else { return }
        
        switch viewModel.numberOfRows {
        case 1:
            cell.layer.cornerRadius = Constants.cornerRadius
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            cell.hideLineView()
        default:
            if numberRow == 0 {
                cell.layer.cornerRadius = Constants.cornerRadius
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else if numberRow == viewModel.numberOfRows - 1 {
                cell.layer.cornerRadius = Constants.cornerRadius
                cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
                cell.hideLineView()
            }
        }
    }
    
    @objc
    private func addButtonTapped() {
        addButton.showAnimation { [weak self] in
            guard let self = self else { return }
            self.delegate?.showEditCategoryViewController(type: .addCategory, editCategoryString: nil, at: nil)
        }
    }
}

// MARK: UICollectionViewDataSource
extension CategoriesView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.numberOfRows ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryCollectionViewCell.cellReuseIdentifier,
            for: indexPath) as? CategoryCollectionViewCell else { return UICollectionViewCell() }
        
        let categoryCellViewModel = viewModel?.categoryCellViewModel(at: indexPath)
        setCellCornerRadius(cell: cell, numberRow: indexPath.row)
        cell.initialize(viewModel: categoryCellViewModel)
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension CategoriesView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let categoryCoreData = viewModel?.didSelectCategory(by: indexPath)
        delegate?.selectedCategory(categoryCoreData: categoryCoreData)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else { return nil }
        let indexPath = indexPaths[0]
        return createContextMenu(indexPath: indexPath)
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension CategoriesView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = UIScreen.main.bounds.width - Constants.indentationFromEdges * 2
        return CGSize(width: width, height: Constants.hugHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }
}

