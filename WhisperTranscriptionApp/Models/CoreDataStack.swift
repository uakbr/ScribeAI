import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WhisperTranscriptionApp")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            context.perform {
                do {
                    try context.save()
                } catch {
                    print("Unresolved Core Data error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchRecentTranscriptions(limit: Int) -> [TranscriptionRecord] {
        let request: NSFetchRequest<TranscriptionRecord> = TranscriptionRecord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TranscriptionRecord.date, ascending: false)]
        if limit > 0 {
            request.fetchLimit = limit
        }
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch transcriptions: \(error.localizedDescription)")
            return []
        }
    }
} 