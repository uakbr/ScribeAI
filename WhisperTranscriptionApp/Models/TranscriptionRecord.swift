import Foundation

struct TranscriptionRecord: Decodable {
    let id: UUID
    let user_id: UUID
    let text: String
    let date: Date
    let duration: Double
    let audio_url: String?
} 