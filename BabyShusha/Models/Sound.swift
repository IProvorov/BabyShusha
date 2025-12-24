// Models/Sound.swift
import Foundation

struct Sound: Identifiable, Codable {
    let id: UUID
    var name: String
    var filename: String
    var type: SoundType
    var iconName: String
    var volume: Float
    var isPremium: Bool = false
    
    init(id: UUID = UUID(),
         name: String,
         filename: String,
         type: SoundType,
         iconName: String,
         volume: Float = 0.5,
         isPremium: Bool = false) {
        self.id = id
        self.name = name
        self.filename = filename
        self.type = type
        self.iconName = iconName
        self.volume = volume
        self.isPremium = isPremium
    }
    
    enum SoundType: String, Codable, CaseIterable {
        case whiteNoise = "white_noise"
        case heartbeat = "heartbeat"
        case rain = "rain"
        case lullaby = "lullaby"
        case nature = "nature"
        case melodies = "melodies"
        
        var displayName: String {
            switch self {
            case .whiteNoise: return "Белый шум"
            case .heartbeat: return "Сердцебиение"
            case .rain: return "Дождь"
            case .lullaby: return "Колыбельные"
            case .nature: return "Природа"
            case .melodies: return "Мелодии"
            }
        }
    }
}
