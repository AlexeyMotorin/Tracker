import UIKit
import CoreData

final class TrackerStore: NSObject {
    
    private struct TrackerStoreConstants {
        static let entityName = "TrackerCoreData"
        static let categorySectionNameKeyPath = "category"
    }
    
    private enum TrackerStoreError: Error {
        case errorDecodingId
        case errorDecodingName
        case errorDecodingColorHex
        case errorDecodingEmoji
        case errorDecodingScheduleString
        case errorDecodingCreatedAt
        case errorDecodingIdCategory
        case errorDecodingIsHabit
    }
    
    private let context: NSManagedObjectContext
    private let colorMarshaling = UIColorMarshalling()
    private let scheduleMarshaling = ScheduleMarshalling()
        
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    func addNewTracker(_ tracker: Tracker, with category: TrackerCategoryCoreData) {
        creatTrackerCoreData(from: tracker, with: category)
        saveContext()
    }
    
    func changeTracker(_ id: NSManagedObjectID, newTracker: Tracker, category: TrackerCategoryCoreData?) throws {
        guard let object = try context.existingObject(with: id) as? TrackerCoreData else { return }
        let colorHex = creatColorHex(with: newTracker.color)
        let sheduleString = creatStringSchedule(with: newTracker.schedule)
        object.name = newTracker.name
        object.colorHex = colorHex
        object.emoji = newTracker.emoji
        object.schedule = sheduleString
        object.category = category
        saveContext()
    }
    
    func deleteTracker(forId id: NSManagedObjectID) {
        guard let object = try? context.existingObject(with: id) as? TrackerCoreData else { return }
        context.delete(object)
        saveContext()
    }
    
    func creatTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.id else { throw TrackerStoreError.errorDecodingId }
        guard let name = trackerCoreData.name else { throw TrackerStoreError.errorDecodingName }
        guard let colorHex = trackerCoreData.colorHex else { throw TrackerStoreError.errorDecodingColorHex }
        guard let emoji = trackerCoreData.emoji else { throw TrackerStoreError.errorDecodingEmoji }
        guard let scheduleString = trackerCoreData.schedule else { throw TrackerStoreError.errorDecodingScheduleString }
        
        return Tracker(
            id: id,
            name: name,
            color: colorMarshaling.colorWithHexString(hexString: colorHex),
            emoji: emoji,
            schedule: scheduleMarshaling.arrayFromString(string: scheduleString),
            isHabit: trackerCoreData.isHabit
        )
    }
    
    private func creatTrackerCoreData(from tracker: Tracker, with category: TrackerCategoryCoreData)  {
        let colorHex = creatColorHex(with: tracker.color)
        let sheduleString = creatStringSchedule(with: tracker.schedule)
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.colorHex = colorHex
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.schedule = sheduleString
        trackerCoreData.category = category
        trackerCoreData.isHabit = tracker.isHabit
    }
    
    private func creatColorHex(with color: UIColor?) -> String? {
        guard let color else { return nil }
        return colorMarshaling.hexStringFromColor(color: color)
    }
    
    private func creatStringSchedule(with arraySchedule: [String]?) -> String? {
        guard let arraySchedule else { return nil }
        return scheduleMarshaling.stringFromArray(array: arraySchedule)
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
