import Foundation
import CoreData

class TranscriptionStorageManager {
    static let shared = TranscriptionStorageManager()

    private init() {
        // Private initializer to ensure singleton pattern
    }

    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WhisperTranscriptionApp")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                print("Failed to load persistent stores: \(error.localizedDescription)")
                // Handle the error appropriately, e.g., log it or terminate the app
            }
        })
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - CRUD Methods
    func saveTranscription(text: String, date: Date, duration: TimeInterval, audioURL: URL?) throws {
        let context = persistentContainer.viewContext
        let transcription = TranscriptionRecord(context: context)
        transcription.text = text
        transcription.date = date
        transcription.duration = duration
        transcription.audioURL = audioURL

        do {
            try context.save()
        } catch {
            print("Failed to save transcription: \(error.localizedDescription)")
            throw error
        }
    }

    func fetchTranscriptions() -> [TranscriptionRecord] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TranscriptionRecord> = TranscriptionRecord.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchBatchSize = 20

        do {
            let transcriptions = try context.fetch(fetchRequest)
            return transcriptions
        } catch {
            print("Failed to fetch transcriptions: \(error.localizedDescription)")
            return []
        }
    }

    func deleteTranscription(_ transcription: TranscriptionRecord) throws {
        let context = persistentContainer.viewContext
        context.delete(transcription)

        do {
            try context.save()
        } catch {
            throw error
        }
    }

    // MARK: - Save Context
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error.localizedDescription)")
            }
        }
    }

    func syncTranscriptions() {
        // Fetch local and remote transcriptions
        // Compare and resolve conflicts
        // Update both local and remote storage
        DispatchQueue.main.async {
            // Update UI or notify user
        }
    }
}
