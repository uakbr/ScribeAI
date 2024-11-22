import Foundation
import CoreData

struct TranscriptionDTO: Decodable {
    let id: UUID
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
        record.text = text
        record.date = date
        record.duration = duration

        if let audioURLString = audio_url {
            record.audioURL = URL(string: audioURLString)
        }
        return record
    }
}
