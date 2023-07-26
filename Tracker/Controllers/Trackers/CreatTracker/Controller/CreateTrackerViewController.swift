import UIKit

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func dismissViewController(_ viewController: UIViewController)
}

final class CreateTrackerViewController: UIViewController {
    
    // MARK: public properties
    var typeTracker: TypeTracker?
    weak var delegate: CreateTrackerViewControllerDelegate?
    
   // MARK: helpers
    private enum SheduleCategory {
        case shedule
        case category
    }
    
    private struct CreateTrackerViewControllerConstants {
        static let habitTitle = "Новая привычка"
        static let eventTitle = "Новое нерегулярное событие"
        static let weekDays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    }
    
    // MARK: private properties
    private var selectedCategory: TrackerCategoryCoreData?
    private var selectedDates: [String]?
    
    private var stringSelectedDates: String {
        if selectedDates?.count == 7 {
            return "Каждый день"
        } else {
            return selectedDates?.joined(separator: ", ") ?? ""
        }
    }
    
    private var tracker: Tracker?
    private let dataProvider = DataProvider()
    
    // MARK: UI
    private var createTrackerView: CreateTrackerView!
    
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let typeTracker else {
            dismiss(animated: true)
            return
        }
        
        createTrackerView = CreateTrackerView(
            frame: view.bounds,
            delegate: self,
            typeTracker: typeTracker
        )
        
        switch typeTracker {
        case .habit:
            setupView(with: CreateTrackerViewControllerConstants.habitTitle)
        case .event:
            setupView(with: CreateTrackerViewControllerConstants.eventTitle)
        }
    }
    
    // MARK: private methods
    private func setupView(with title: String) {
        view.backgroundColor = .clear
        self.title = title
        addScreenView(view: createTrackerView)
    }
    
    deinit {
        print("CreateTrackerViewController deinit")
    }
}

// MARK: CreateTrackerViewDelegate
extension CreateTrackerViewController: CreateTrackerViewDelegate {
    func sendTrackerSetup(nameTracker: String?, color: UIColor, emoji: String) {
        if typeTracker == .event {
            selectedDates = CreateTrackerViewControllerConstants.weekDays
        }
    
        guard
            let nameTracker,
            selectedDates != nil
        else { return }
    
        tracker = Tracker(
            id: UUID().uuidString,
            name: nameTracker,
            color: color,
            emoji: emoji,
            schedule: selectedDates
        )
                
        guard let tracker = tracker,
              let selectedCategory
        else { return }
        
        try? dataProvider.saveTracker(tracker, in: selectedCategory)
        delegate?.dismissViewController(self)
    }
    
    func showSchedule() {
        let viewController = createViewController(type: .shedule)
        present(viewController, animated: true)
    }
    
    func showCategory() {
        let viewController = createViewController(type: .category)
        present(viewController, animated: true)
    }

    func cancelCreate() {
        delegate?.dismissViewController(self)
    }
}

// MARK: create CategoryViewController
extension CreateTrackerViewController {
    private func createViewController(type: SheduleCategory) -> UINavigationController {
        let viewController: UIViewController
        
        switch type {
        case .shedule:
            let sheduleViewController = SheduleViewController()
            sheduleViewController.delegate = self
            viewController = sheduleViewController
        case .category:
            let viewModel = CategoriesViewControllerViewModel()
            let categoryViewController = CategoriesViewController(viewModel: viewModel, delegate: self)
            viewController = categoryViewController
            
            if let selectedCategory {
                categoryViewController.selectedCategoryTitle = selectedCategory.title
            }
        }
        
        let navigationViewController = UINavigationController(rootViewController: viewController)
        return navigationViewController
    }
}

// MARK: CategoriesViewControllerDelegate
extension CreateTrackerViewController: CategoriesViewControllerDelegate {
    func setCategory(categoryCoreData: TrackerCategoryCoreData?) {
        self.selectedCategory = categoryCoreData
        createTrackerView.setCategory(with: categoryCoreData?.title)
        dismiss(animated: true)
    }
}

// MARK: SheduleViewControllerDelegate
extension CreateTrackerViewController: SheduleViewControllerDelegate {
    func setSelectedDates(dates: [String]) {
        selectedDates = dates
        createTrackerView.setShedule(with: stringSelectedDates)
        dismiss(animated: true)
    }
}
