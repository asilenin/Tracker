import UIKit
import Logging

protocol CategoryViewModelProtocol: AnyObject {
    
    var categories: [TrackerCategory] { get }
    var selectedCategory: TrackerCategory? { get set }
    var onCategoriesUpdate: (() -> Void)? { get set }
    var onCategorySelected: ((TrackerCategory) -> Void)? { get set }
    
    func createCategory(title: String)
    func didSelectCategory(at indexPath: IndexPath)
    
    func cellModel(at indexPath: IndexPath) -> CategoryCellModel
}

final class CategoryViewModel: CategoryViewModelProtocol {
    
    // MARK: - Public Properties
    var onCategoriesUpdate: (() -> Void)?
    var selectedCategory: TrackerCategory?
    var onCategorySelected: ((TrackerCategory) -> Void)?
    
    // MARK: - Private Properties
    private let initialSelectedCategoryTitle: String?
    private let trackerCategoryStore: TrackerCategoryStore
    private(set) var categories: [TrackerCategory] = [] {
        didSet { onCategoriesUpdate?() }
    }
    
    // MARK: - Init
    init(
        trackerCategoryStore: TrackerCategoryStore,
        selectedCategoryTitle: String?
    ) {
        self.trackerCategoryStore = trackerCategoryStore
        self.initialSelectedCategoryTitle = selectedCategoryTitle
        self.trackerCategoryStore.delegate = self
        loadCategories()
    }
    
    // MARK: - Public Methods
    func createCategory(title: String) {
        AppLogger.shared.info("[CategoryViewModel]: :\(#line)] \(#function) createCategory called with title: \(title)")
        trackerCategoryStore.addNewCategory(with: title)
    }
    
    func didSelectCategory(at indexPath: IndexPath) {
        guard categories.indices.contains(indexPath.row) else { return }

        let category = categories[indexPath.row]
        selectedCategory = category
        onCategorySelected?(category)
    }
    
    func cellModel(at indexPath: IndexPath) -> CategoryCellModel {
        let category = categories[indexPath.row]

        return CategoryCellModel(
            title: category.title,
            isSelected: category.title == selectedCategory?.title
        )
    }
    
    // MARK: - Private Methods
    private func loadCategories() {
        categories = trackerCategoryStore.fetchCategories()

        if let title = initialSelectedCategoryTitle {
            selectedCategory = categories.first { $0.title == title }
        }
    }
}

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func storeDidUpdate(_ categories: [TrackerCategory]) {
        self.categories = categories
    }
}
