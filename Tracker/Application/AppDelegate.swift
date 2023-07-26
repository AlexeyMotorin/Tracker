import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {}
        }
        return container
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.ypWhite
        appearance.titleTextAttributes = [.foregroundColor: UIColor.ypBlack ?? UIColor.black]
        UINavigationBarAppearance().titleTextAttributes = [.font: UIFont.ypMediumSize16]
        UINavigationBar.appearance().prefersLargeTitles = false
        UINavigationBar.appearance().backgroundColor = UIColor.ypWhite
        return true
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
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

