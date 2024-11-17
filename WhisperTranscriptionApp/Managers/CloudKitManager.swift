import Foundation
import CloudKit

class CloudKitManager {
    static let shared = CloudKitManager()
    private let privateDatabase = CKContainer.default().privateCloudDatabase

    private init() {}

    func saveTranscription(_ transcription: TranscriptionRecord, completion: @escaping (Result<Void, Error>) -> Void) {
        let record = CKRecord(recordType: "Transcription")
        record["text"] = transcription.text as CKRecordValue
        record["date"] = transcription.date as CKRecordValue
        record["duration"] = transcription.duration as CKRecordValue

        // Handle audio data as CKAsset if applicable
        if let audioURL = transcription.audioURL {
            let asset = CKAsset(fileURL: audioURL)
            record["audioAsset"] = asset
        }

        privateDatabase.save(record) { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    func fetchTranscriptions(completion: @escaping (Result<[TranscriptionRecord], Error>) -> Void) {
        let query = CKQuery(recordType: "Transcription", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        let operation = CKQueryOperation(query: query)
        var fetchedTranscriptions: [TranscriptionRecord] = []

        operation.recordFetchedBlock = { record in
            if let transcription = TranscriptionRecord(record: record) {
                fetchedTranscriptions.append(transcription)
            }
        }

        operation.queryCompletionBlock = { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(fetchedTranscriptions))
                }
            }
        }

        privateDatabase.add(operation)
    }

    func deleteTranscription(recordID: CKRecord.ID, completion: @escaping (Result<Void, Error>) -> Void) {
        privateDatabase.delete(withRecordID: recordID) { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
} 