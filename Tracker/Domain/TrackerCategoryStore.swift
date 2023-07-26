import UIKit
import CoreData

protocol TrackerCategoryStoreProtocol: AnyObject {
    var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> { get }
    func creatTrackerCategory(from trackerCategoryCoreData:  TrackerCategoryCoreData) throws -> TrackerCategory
    func addTrackerCategoryCoreData(from trackerCategory: TrackerCategory)
    func getTrackerCategory(by indexPath: IndexPath) -> TrackerCategory?
    func getTrackerCategoryCoreData(by indexPath: IndexPath) -> TrackerCategoryCoreData?
    func deleteCategory(delete: TrackerCategoryCoreData)
    func changeCategory(at indexPath: IndexPath, newCategoryTitle: String?)
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    
    private enum TrackerCategoryStoreError: Error {
        case errorDecodingTitle
        case errorDecodingId
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)
        ]
        let fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        try? fetchedResultController.performFetch()
        return fetchedResultController
    }()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    
    private func saveContext() {
         if context.hasChanges {
             do {
                 try context.save()
             } catch {
                 let nserror = error as NSError
                 assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
             }
         }
     }
}

extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    func creatTrackerCategory(from trackerCategoryCoreData:  TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoryCoreData.title else { throw TrackerCategoryStoreError.errorDecodingTitle }
        return TrackerCategory(title: title)
    }
    
    func addTrackerCategoryCoreData(from trackerCategory: TrackerCategory) {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.title = trackerCategory.title
        saveContext()
    }
    
    func getTrackerCategory(by indexPath: IndexPath) -> TrackerCategory? {
        let object = fetchedResultsController.object(at: indexPath)
        return try? creatTrackerCategory(from: object)
    }
    
    func getTrackerCategoryCoreData(by indexPath: IndexPath) -> TrackerCategoryCoreData? {
        fetchedResultsController.object(at: indexPath)
    }
    
    func deleteCategory(delete: TrackerCategoryCoreData) {
        delete.trackers?.forEach({ element in
            guard let element = element as? NSManagedObject else { return }
            context.delete(element)
        })
        context.delete(delete)
        saveContext()
    }
    
    func changeCategory(at indexPath: IndexPath, newCategoryTitle: String?) {
        let oldCategory = fetchedResultsController.object(at: indexPath)
        oldCategory.title = newCategoryTitle
        saveContext()
    }
}
