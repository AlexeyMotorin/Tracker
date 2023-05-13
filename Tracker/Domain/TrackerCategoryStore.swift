import UIKit
import CoreData

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
    
    func creatTrackerCategory(from trackerCategoryCoreData:  TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoryCoreData.title else { throw TrackerCategoryStoreError.errorDecodingTitle }
        return TrackerCategory(title: title)
    }
    
    func addTrackerCategoryCoreData(from trackerCategory: TrackerCategory) -> TrackerCategoryCoreData {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.title = trackerCategory.title
        saveContext()
        return trackerCategoryCoreData
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
    
    func changeCategory(at indexPath: IndexPath, newCategoryTitle: String?) -> TrackerCategoryCoreData {
        let oldCategory = fetchedResultsController.object(at: indexPath)
        oldCategory.title = newCategoryTitle
        saveContext()
        return fetchedResultsController.object(at: indexPath)
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

