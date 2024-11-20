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
        let session = try await client.auth.signIn(email: email, password: password)
        return session
    }

    func signUp(email: String, password: String) async throws -> Session {
        let session = try await client.auth.signUp(email: email, password: password)
        return session
    }

    // MARK: - Upload Transcription

    func uploadTranscription(_ transcription: String) async throws {
        let newTranscription = NewTranscription(content: transcription, created_at: Date().iso8601String)
        let response = try await client.from(table: "transcriptions")
            .insert(values: newTranscription)
            .execute()
        print("Upload successful: \(response)")
    }

    // MARK: - Fetch Transcriptions

    func fetchTranscriptions() async throws -> [Transcription] {
        let response = try await client.from(table: "transcriptions")
            .select()
            .order(column: "created_at", ascending: false)
            .execute()
        let data = try response.decoded(to: [Transcription].self)
        return data
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
