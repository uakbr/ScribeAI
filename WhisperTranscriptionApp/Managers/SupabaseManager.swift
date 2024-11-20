import Foundation
import Supabase
import PostgREST
import GoTrue

class SupabaseManager {
    static let shared = SupabaseManager()
    let client: SupabaseClient

    private init() {
        // Initialize the Supabase client with your Supabase URL and Anon Key
        let supabaseURL = URL(string: "https://zmmvaaxiuqlfqrxfdsye.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InptbXZhYXhpdXFsZnFyeGZkc3llIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzIwNzc3MTAsImV4cCI6MjA0NzY1MzcxMH0.9rAhxsLCuEy2sEYaLdA3thgt2zW6r-z32s12YhIn9tQ"
        client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }

    // MARK: - Authentication Methods

    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        client.auth.signIn(email: email, password: password) { result in
            completion(result)
        }
    }

    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        client.auth.signUp(email: email, password: password) { result in
            completion(result)
        }
    }

    // MARK: - Upload Transcription

    func uploadTranscription(_ transcription: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let data: [String: Any] = [
            "content": transcription,
            "created_at": Date().iso8601String
        ]

        client.database
            .from("transcriptions")
            .insert(values: [data]) // Provide an array of dictionaries
            .execute { result in
                switch result {
                case .success(let response):
                    print("Upload successful: \(response)")
                    completion(.success(()))
                case .failure(let error):
                    print("Upload failed: \(error)")
                    completion(.failure(error))
                }
            }
    }

    // MARK: - Fetch Transcriptions

    func fetchTranscriptions(completion: @escaping (Result<[Transcription], Error>) -> Void) {
        client.database
            .from("transcriptions")
            .select()
            .order(column: "created_at", ascending: false)
            .execute { result in
                switch result {
                case .success(let response):
                    do {
                        // Decode the response into your Transcription model
                        let data = try JSONDecoder().decode([Transcription].self, from: response.data)
                        completion(.success(data))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

// Define your Transcription model

struct Transcription: Decodable {
    let id: Int
    let content: String
    let created_at: String
}

// Date extension to format timestamps

private extension Date {
    var iso8601String: String {
        return ISO8601DateFormatter().string(from: self)
    }
} 