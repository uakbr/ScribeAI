import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    let client: SupabaseClient

    private init() {
        let supabaseURL = URL(string: "https://zmmvaaxiuqlfqrxfdsye.supabase.co")!
        let supabaseKey = "your-supabase-anon-key"

        client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }

    // MARK: - Authentication Methods

    func signIn(email: String, password: String) async throws -> Session {
        let response = try await client.auth.signIn(email: email, password: password)
        guard let session = response.session else {
            throw AuthenticationError.noSession
        }
        return session
    }

    func signUp(email: String, password: String) async throws -> Session {
        let response = try await client.auth.signUp(email: email, password: password)
        guard let session = response.session else {
            throw AuthenticationError.noSession
        }
        return session
    }

    // MARK: - Upload Transcription

    func uploadTranscription(_ transcription: String) async throws {
        let newTranscription = NewTranscription(content: transcription, created_at: Date().iso8601String)
        _ = try await client.database
            .from("transcriptions")
            .insert(newTranscription)
    }

    // MARK: - Fetch Transcriptions

    func fetchTranscriptions() async throws -> [Transcription] {
        let data = try await client.database
            .from("transcriptions")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value

        return data
    }

    // MARK: - Example Database Function

    func someDatabaseFunction() {
        Task {
            do {
                let data = try await client.database
                    .from("your_table")
                    .select()
                    .execute()
                    .value as [ActualDataType]
                // Handle the data
            } catch {
                // Handle the error
                print("Database error: \(error.localizedDescription)")
            }
        }
    }
}

// Define your Transcription models

struct NewTranscription: Codable {
    let content: String
    let created_at: String
}

struct Transcription: Codable {
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

// Authentication Error

enum AuthenticationError: Error {
    case noSession
} 
