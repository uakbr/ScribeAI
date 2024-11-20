import Foundation
import CoreData

@objc(TranscriptionRecord)
public class TranscriptionRecord: NSManagedObject {
    // Your properties and methods
    @NSManaged public var id: UUID?
    @NSManaged public var text: String?
    @NSManaged public var date: Date?
    @NSManaged public var duration: Double
    @NSManaged public var audioURL: URL?
}

extension TranscriptionRecord {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TranscriptionRecord> {
        return NSFetchRequest<TranscriptionRecord>(entityName: "TranscriptionRecord")
    }

    // ... existing code ...
} 