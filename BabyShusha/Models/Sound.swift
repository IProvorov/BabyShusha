// Models/Sound.swift
import Foundation

struct Sound: Identifiable, Codable {
    let id: UUID
    let name: String
    let icon: String
    let filename: String
    let category: SoundCategory
    let isPremium: Bool
    var volume: Float
    
    init(id: UUID = UUID(),
         name: String,
         icon: String,
         filename: String,
         category: SoundCategory = .whiteNoise,
         isPremium: Bool = false,
         volume: Float = 0.5) {
        self.id = id
        self.name = name
        self.icon = icon
        self.filename = filename
        self.category = category
        self.isPremium = isPremium
        self.volume = volume
    }
}

enum SoundCategory: String, Codable, CaseIterable {
    case whiteNoise = "Белый шум"
    case heartbeat = "Сердцебиение"
    case nature = "Природа"
    case melodies = "Мелодии"
}
