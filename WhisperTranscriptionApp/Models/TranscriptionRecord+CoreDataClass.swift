import Foundation
import CoreData

@objc(TranscriptionRecord)
public class TranscriptionRecord: NSManagedObject {
    // Move the static methods from TranscriptionRecord.swift here
    static func fetch(in context: NSManagedObjectContext) throws -> [TranscriptionRecord] {
        let request: NSFetchRequest<TranscriptionRecord> = TranscriptionRecord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TranscriptionRecord.date, ascending: false)]
        
        return try context.performAndWait {
            try request.execute()
        }
    }
    
    static func create(in context: NSManagedObjectContext, completion: @escaping (TranscriptionRecord?) -> Void) {
        context.perform {
            let record = TranscriptionRecord(context: context)
            record.id = UUID()
            record.date = Date()
            do {
                try context.save()
                completion(record)
            } catch {
                print("Failed to save new transcription record: \(error)")
                completion(nil)
            }
        }
    }
    
    static func delete(_ record: TranscriptionRecord, from context: NSManagedObjectContext) {
        context.perform {
            context.delete(record)
            try? context.save()
        }
    }
    
    static func fetchAll(in context: NSManagedObjectContext, completion: @escaping ([TranscriptionRecord]) -> Void) {
        context.perform {
            let request: NSFetchRequest<TranscriptionRecord> = TranscriptionRecord.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \TranscriptionRecord.date, ascending: false)]
            
            do {
                let records = try context.fetch(request)
                completion(records)
            } catch {
                print("Failed to fetch transcription records: \(error)")
                completion([])
            }
        }
    }
} 