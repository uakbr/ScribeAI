import Foundation
import CoreData

extension TranscriptionRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TranscriptionRecord> {
        return NSFetchRequest<TranscriptionRecord>(entityName: "TranscriptionRecord")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var user_id: UUID?
    @NSManaged public var text: String?
    @NSManaged public var date: Date?
    @NSManaged public var duration: Double
    @NSManaged public var audio_url: URL?

    // Add any additional properties or methods
} 