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
                ErrorAlertManager.shared.showAlert(
                    title: "Data Error",
                    message: "Failed to load persistent stores: \(error.localizedDescription)"
                )
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
        let transcription = Transcription(context: context)
        transcription.text = text
        transcription.date = date
        transcription.duration = duration
        transcription.audioURL = audioURL
        
        do {
            try context.save()
        } catch {
            // Throw the error to be handled by the caller
            throw error
        }
    }
    
    func fetchTranscriptions() -> [Transcription] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Transcription> = Transcription.fetchRequest()
        
        // Add sort descriptors and fetch limits if necessary
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchBatchSize = 20
        
        do {
            let transcriptions = try context.fetch(fetchRequest)
            return transcriptions
        } catch {
            ErrorAlertManager.shared.handleStorageError(error)
            return []
        }
    }
    
    func deleteTranscription(_ transcription: Transcription) throws {
        let context = persistentContainer.viewContext
        context.delete(transcription)
        
        do {
            try context.save()
        } catch {
            // Throw the error to be handled by the caller
            throw error
        }
    }
    
    // MARK: - Save Context
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                ErrorAlertManager.shared.showAlert(
                    title: "Save Error",
                    message: "Failed to save transcription: \(error.localizedDescription)"
                )
            }
        }
    }

    func syncTranscriptions() {
        // Fetch local and remote transcriptions
        // Compare and resolve conflicts
        // Update both local and remote storage
        // Inform the user of sync status
        DispatchQueue.main.async {
            // Update UI or notify user
        }
    }
}