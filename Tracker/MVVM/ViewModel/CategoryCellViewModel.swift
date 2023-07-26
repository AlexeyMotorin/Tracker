import Foundation

protocol CategoryCellViewModelProtocol {
    var categoryLabel: String { get }
    var selectedCategory: Bool { get }
}

final class CategoryCellViewModel: CategoryCellViewModelProtocol {
    
    private let category: TrackerCategory
    private let isSelect: Bool
    
    var categoryLabel: String {
        category.title
    }
    
    var selectedCategory: Bool {
        isSelect
    }
    
    init(category: TrackerCategory, isSelect: Bool) {
        self.category = category
        self.isSelect = isSelect
    }
}
