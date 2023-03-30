import UIKit

final class CreateTrackerViewController: UIViewController {
    
    public var typeTracker: TypeTracker?
    
    private struct CreateTrackerViewControllerConstants {
        static let habitTitle = "Новая привычка"
        static let eventTitle = "Новое нерегулярное событие"
    }

  //  private var createTrackerView: CreateTrackerViewDelete!
    
    private var createTrackerView: CreateTrackerView!
    
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
        case .Habit:
            setupView(with: CreateTrackerViewControllerConstants.habitTitle)
        case .Event:
            setupView(with: CreateTrackerViewControllerConstants.eventTitle)
        }
    }
    
    private func setupView(with title: String) {
        view.backgroundColor = .clear
        self.title = title
        addScreenView(view: createTrackerView)
    }
    
    deinit {
        print("CreateTrackerViewController deinit")
    }
    
}

extension CreateTrackerViewController: CreateTrackerViewDelegate {
    func createTracker() {
        print("Создаем tracker")
    }
    
    func cancelCreate() {
        print("Отмена")
    }
}
