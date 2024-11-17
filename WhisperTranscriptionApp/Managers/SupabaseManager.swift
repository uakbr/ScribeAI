import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        let supabaseURL = URL(string: "https://your-project-ref.supabase.co")! // Replace with your Supabase URL
        let supabaseKey = "your-anon-key" // Replace with your Supabase Anon/Public API Key
        client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }

    func performAuthenticatedRequest(...) {
        guard let session = client.auth.session, !session.isExpired else {
            DispatchQueue.main.async {
                // Redirect to login
                NotificationCenter.default.post(name: .sessionExpired, object: nil)
            }
            return
        }

        // Proceed with the request
    }
} 