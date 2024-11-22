import Foundation
import CoreData

struct TranscriptionDTO: Decodable {
    let id: UUID
    let user_id: UUID
    let text: String
    let date: Date
    let duration: Double
    let audio_url: String?
}

// Add a conversion method to create a Core Data entity from DTO
extension TranscriptionDTO {
    func toCoreDataEntity(in context: NSManagedObjectContext) -> TranscriptionRecord {
        let record = TranscriptionRecord(context: context)
        record.id = id
        record.user_id = user_id
        record.text = text
        record.date = date
        record.duration = duration
        record.audio_url = URL(string: audio_url ?? "")
        return record
    }
}

// Any extensions or methods specific to TranscriptionDTO 