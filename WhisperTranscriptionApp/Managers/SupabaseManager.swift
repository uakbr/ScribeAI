import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    let client: SupabaseClient

    private init() {
        let supabaseURL = URL(string: "https://zmmvaaxiuqlfqrxfdsye.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InptbXZhYXhpdXFsZnFyeGZkc3llIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzIwNzc3MTAsImV4cCI6MjA0NzY1MzcxMH0.9rAhxsLCuEy2sEYaLdA3thgt2zW6r-z32s12YhIn9tQ"

        client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }

    // MARK: - Authentication Methods

    func signIn(email: String, password: String) async throws -> User {
        let session = try await client.auth.signIn(email: email, password: password)
        let user = session.user
        return user
    }

    func signUp(email: String, password: String) async throws -> User {
        let response = try await client.auth.signUp(email: email, password: password)
        let user = response.user
        return user
    }

    // MARK: - Upload Transcription

    func uploadTranscription(_ transcription: String) async throws {
        let newTranscription = NewTranscription(content: transcription, created_at: Date().iso8601String)
        try await client.database
            .from("transcriptions")
            .insert(newTranscription)
            .execute()
    }

    // MARK: - Fetch Transcriptions

    func fetchTranscriptions() async throws -> [Transcription] {
        let response = try await client.database
            .from("transcriptions")
            .select()
            .order(column: "created_at", ascending: false)
            .execute()
            .value

        let decoder = JSONDecoder()
        let data = try JSONSerialization.data(withJSONObject: response)
        return try decoder.decode([Transcription].self, from: data)
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
