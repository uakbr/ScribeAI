import Foundation
import CoreData

extension TranscriptionRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TranscriptionRecord> {
        return NSFetchRequest<TranscriptionRecord>(entityName: "TranscriptionRecord")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var text: String?
    @NSManaged public var date: Date?
    @NSManaged public var duration: Double

    // Add any additional properties or methods
} 