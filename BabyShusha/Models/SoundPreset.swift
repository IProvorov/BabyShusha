import Foundation

struct SoundPreset: Identifiable, Codable {
    let id: UUID
    var name: String
    var sounds: [SoundConfiguration]
    var isFavorite: Bool
    var createdAt: Date
    
    struct SoundConfiguration: Codable {
        let soundId: UUID
        var isEnabled: Bool
        var volume: Float
    }
}
