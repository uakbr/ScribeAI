import Foundation
import CoreData

struct TranscriptionRecord: Decodable {
    let id: UUID
    let user_id: UUID
    let text: String
    let date: Date
    let duration: Double
    let audio_url: String?
}

extension TranscriptionRecord {
    static func fetch(in context: NSManagedObjectContext) throws -> [TranscriptionRecord] {
        let request: NSFetchRequest<TranscriptionRecord> = TranscriptionRecord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TranscriptionRecord.date, ascending: false)]
        
        return try context.performAndWait {
            try request.execute()
        }
    }
    
    static func create(in context: NSManagedObjectContext) -> TranscriptionRecord {
        context.performAndWait {
            let record = TranscriptionRecord(context: context)
            record.id = UUID()
            record.date = Date()
            return record
        }
    }
    
    static func saveContext(_ context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved Core Data error \(nserror), \(nserror.userInfo)")
        }
    }
    
    static func delete(_ record: TranscriptionRecord, from context: NSManagedObjectContext) {
        context.perform {
            context.delete(record)
            try? context.save()
        }
    }
} 