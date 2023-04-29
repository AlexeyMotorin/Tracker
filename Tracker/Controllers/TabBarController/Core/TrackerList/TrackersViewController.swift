import UIKit
import CoreData

final class TrackersViewController: UIViewController {
    
    private struct TrackersListControllerConstants {
        static let viewControllerTitle = "Трекеры"
        static let plugLabelText = "Что будем отслеживать?"
        static let plugImageName = "plug"
        static let addTrackerButtonImageName = "plus"
        static let localeIdentifier = "ru_RU"
        static let reuseIdentifierCell = "cell"
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var dataProvider: DataProviderProtocol!
    
    private func loadCategories() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let categoryIsLoaded = UserDefaults.standard.bool(forKey: "isLoaded")
        
        // создаем категорию для хранения привычек
        if !categoryIsLoaded  {
            let category = TrackerCategoryCoreData(context: context)
            category.title = "Важное"
            try? context.save()
            UserDefaults.standard.set(true, forKey: "isLoaded")
        }
        
        //
        //        let category = TrackerCategoryCoreData(context: context)
        //        category.title = "Спорт"
        //        try? context.save()
        //
        //        let category = TrackerCategoryCoreData(context: context)
        //        category.title = "Отдых"
        //        try? context.save()
        //
        //        let category = TrackerCategoryCoreData(context: context)
        //        category.title = "Работа"
        //        try? context.save()
        
        let fetchRequestCategory = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        guard let categories = try? context.fetch(fetchRequestCategory) else { return }
        
        if categories.isEmpty {
            print("no categories")
        } else {
            print(categories.count)
            
            //            categories.forEach({
            //                print($0.title)
            //            })
            
            categories.forEach { coredata in
                print("\(coredata.title) has \(coredata.trackers?.count) trackers")
                (coredata.trackers?.allObjects as? [TrackerCoreData])?.forEach({ value in
                    print("\(coredata.title) has \(value.name)")
                })
            }
            
            print("+++++++++")
            
            //            (categories[0].trackers?.allObjects as? [TrackerCoreData])?.forEach({ value in
            //                print(value.name, value.category)
            //            })
            //
            //            (categories[1].trackers?.allObjects as? [TrackerCoreData])?.forEach({ value in
            //                print(value.schedule)
            //            })
        }
        
        //         удалить
        //                let fetchedRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        //                guard let objects = try? context.fetch(fetchedRequest) else { return }
        //                objects.forEach {  context.delete($0) }
        //
        //                let fetchedRequest1 = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        //                guard let objects = try? context.fetch(fetchedRequest1) else { return }
        //                objects.forEach {  context.delete($0) }
        //
        //                try? context.save()
    }
    
    
    private var categories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = [] // тут отфильтрованные трекеры
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    
    private var currentDate: Date {
        let date = datePicker.date
        let currentDate = date.getDate
        return currentDate
    }
    
    private var today: Date {
        let date = Date()
        let today = date.getDate
        return today
    }
    
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    // MARK: UI
    private lazy var addTrackerButton: UIBarButtonItem = {
        let imageButton = UIImage(named: TrackersListControllerConstants.addTrackerButtonImageName)?.withRenderingMode(.alwaysTemplate)
        let button = UIBarButtonItem(
            image: imageButton,
            style: .done,
            target: self,
            action: #selector(addTrackerButtonTapped)
        )
        button.tintColor = .ypBlack
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: TrackersListControllerConstants.localeIdentifier)
        picker.calendar = Calendar(identifier: .iso8601)
        picker.addTarget(self, action: #selector(changedDate), for: .valueChanged)
        return picker
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: TrackersListControllerConstants.reuseIdentifierCell
        )
        collectionView.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier
        )
        collectionView.register(
            HeaderReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HeaderReusableView.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private lazy var plugView: PlugView = {
        let plugView = PlugView(
            frame: .zero,
            titleLabel: TrackersListControllerConstants.plugLabelText,
            image: UIImage(named: TrackersListControllerConstants.plugImageName) ?? UIImage()
        )
        plugView.isHidden = true
        return plugView
    }()
    
    // MARK: Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        loadCategories()
        dataProvider = DataProvider()
       
        
        setupView()
        addSubviews()
        activateConstraints()
        setupSearchController()
        showVisibleTrackers()
        
        dataProvider.delegate = self
        
        try? dataProvider.loadTrackers(from: datePicker.date)
    }
    
    // MARK: Private methods
    private func setupView() {
        view.backgroundColor = .ypWhite
        title = TrackersListControllerConstants.viewControllerTitle
        navigationItem.leftBarButtonItem = addTrackerButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func addSubviews() {
        view.addSubViews(collectionView, plugView)
        if categories.isEmpty { plugView.isHidden = false }
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.indentationFromEdges),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.indentationFromEdges),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            plugView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plugView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    // MARK: setup searchController
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.delegate = self
        searchController.searchBar.setValue("Отмена", forKey: "cancelButtonText")
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    @objc
    private func addTrackerButtonTapped() {
        showTypeTrackerViewController()
    }
    
    @objc
    private func changedDate() {
        try? dataProvider.loadTrackers(from: datePicker.date)
        presentedViewController?.dismiss(animated: false, completion: nil)
    }
    
    private func getDayCount(for id: String) -> Int {
        var completedDaysCount = 0
        completedTrackers.forEach {
            if $0.trackerID == id { completedDaysCount += 1 }
        }
        return completedDaysCount
    }
    
    private func getTracker(for indexPath: IndexPath) -> Tracker {
        
        return Tracker(id: "", name: "", color: .blue, emoji: "", schedule: nil)
        
        //            isFiltering ? filteredCategories[indexPath.section].trackers[indexPath.row] : visibleCategories[indexPath.section].trackers[indexPath.row]
    }
    
    private func showVisibleTrackers() {
        visibleCategories = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        let date = dateFormatter.string(from: datePicker.date)
        
        var newCategories: [TrackerCategory] = []
        
        //        for (index, category) in categories.enumerated() {
        //            var trackers: [Tracker] = []
        //            for tracker in category.trackers {
        //                guard let weekDays = tracker.schedule else { return }
        //                for weekDay in weekDays {
        //                    if weekDay == date {
        //                        trackers.append(tracker)
        //                    } else {
        //                        continue
        //                    }
        //                }
        //                guard !trackers.isEmpty else {
        //                    presentedViewController?.dismiss(animated: false, completion: nil)
        //                    plugView.isHidden = false
        //                    continue
        //                }
        //
        //                let newCategory = TrackerCategory(title: category.title, trackers: trackers)
        //
        //                if newCategories.contains(newCategory) {
        //                    let trackers = newCategory.trackers
        //                    let newTrackerCategory = TrackerCategory(title: category.title, trackers: trackers)
        //                    newCategories[index] = newTrackerCategory
        //                } else {
        //                    newCategories.append(newCategory)
        //                }
        //            }
        //        }
        
        visibleCategories = newCategories
        plugView.isHidden = visibleCategories.isEmpty ? false : true
        collectionView.reloadData()
    }
}

// MARK: UICollectionView
extension TrackersViewController: UICollectionViewDelegate {}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = UIScreen.main.bounds
        let width = (bounds.width - 44) / 2
        let heightConstant: CGFloat = 132
        let size = CGSize(width: width, height: heightConstant)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height / 20
        return CGSize(width: width, height: height)
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        dataProvider.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        dataProvider.numberOfRowsInSection(section)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.identifier,
            for: indexPath
        ) as? TrackerCollectionViewCell,
              let tracker = dataProvider.getTracker(at: indexPath)
        else {
            return UICollectionViewCell()
        }
        
//        dataProvider.trackerFromCategory(row: indexPath.row)
        
        
//        let completedDayCount = getDayCount(for: tracker.id)
//        var completed = false
//
//        completedTrackers.forEach { trackerRecord in
//            if trackerRecord.trackerID == tracker.id && trackerRecord.checkDate == currentDate {
//                completed = true
//            }
//        }
        
    
        cell.config(tracker: tracker, completedDaysCount: 0, completed: false)
        cell.enabledCheckTrackerButton(enabled: today < currentDate)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderReusableView.reuseIdentifier, for: indexPath) as? HeaderReusableView else {
            return UICollectionReusableView()
        }
        
        let categoryTitle = dataProvider.getSectionTitle(at: indexPath.section)
        view.config(title: categoryTitle)
        return view
    }
}

// MARK: TypeTrackerViewController
extension TrackersViewController {
    private func showTypeTrackerViewController() {
        let typeTrackerViewController = TypeTrackerViewController()
        typeTrackerViewController.delegate = self
        let navigationViewController = UINavigationController(rootViewController: typeTrackerViewController)
        present(navigationViewController, animated: true)
    }
}

extension TrackersViewController: TypeTrackerViewControllerDelegate {
    func dismissViewController(_ viewController: UIViewController) {
        dismiss(animated: true)
    }
    
    func createTrackerCategory(_ trackerCategory: TrackerCategory?) {
        guard let trackerCategory else { return }
        guard !categories.contains(trackerCategory) else {
            for (index, category) in categories.enumerated() {
                //                if category.title == trackerCategory.title {
                //                    let trackers = category.trackers + trackerCategory.trackers
                //                    let newTrackerCategory = TrackerCategory(title: category.title, trackers: trackers)
                //                    categories[index] = newTrackerCategory
                //                }
            }
            showVisibleTrackers()
            dismiss(animated: true)
            return
        }
        
        categories.append(trackerCategory)
        if !categories.isEmpty { plugView.isHidden = true }
        showVisibleTrackers()
        dismiss(animated: true)
    }
}

// MARK: TrackerCollectionViewCellDelegate
extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func checkTracker(id: String?, completed: Bool) {
        guard let id = id else { return }
        let completedTracker = TrackerRecord(trackerID: id, checkDate: currentDate)
        if completed {
            completedTrackers.insert(completedTracker)
        } else {
            completedTrackers.remove(completedTracker)
        }
    }
}

// MARK: UISearchResultsUpdating, UISearchControllerDelegate
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //        if searchController.searchBar.text == "" {
        //            filteredCategories = []
        //        } else {
        //            filterContentForSearchText(searchController.searchBar.text)
        //        }
    }
    
    //    private func filterContentForSearchText (_ searchText: String?) {
    //        guard let searchText else { return }
    //        var newCategories: [TrackerCategory] = []
    //
    //        for category in visibleCategories {
    //            var trackers: [Tracker] = []
    //
    //            for (index, tracker) in category.trackers.enumerated() {
    //                if tracker.name.lowercased().contains(searchText.lowercased()){
    //                    if trackers.contains(tracker) {
    //                        trackers[index] = tracker
    //                    } else {
    //                        trackers.append(tracker)
    //                    }
    //                }
    //            }
    //
    //            let category = TrackerCategory(title: category.title, trackers: trackers)
    //
    //            if newCategories.contains(category) {
    //                guard let index = newCategories.firstIndex(of: category) else { return }
    //                newCategories[index] = category
    //            }
    //            else {
    //                newCategories.append(category)
    //            }
    //        }
    //
    //        filteredCategories = newCategories
    //
    //        if filteredCategories.isEmpty && searchText != "" {
    //            plugView.isHidden = false
    //            plugView.config(title: "Ничего не найдено", image: UIImage(named: "notFound"))
    //        } else {
    //            plugView.isHidden = true
    //        }
    //        collectionView.reloadData()
    //    }
}

extension TrackersViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        filteredCategories = []
        let plusIsHidden = categories.isEmpty ? false : true
        plugView.isHidden = plusIsHidden
        plugView.config(
            title: TrackersListControllerConstants.plugLabelText,
            image: UIImage(named: TrackersListControllerConstants.plugImageName)
        )
        collectionView.reloadData()
    }
}

// MARK: DataProviderDelegate
extension TrackersViewController: DataProviderDelegate {
    func didUpdate() {
        plugView.isHidden = dataProvider.isTrackersForSelectedDate ? true : false
        collectionView.reloadData()
    }
}
