import Foundation

struct SoundPreset: Codable, Identifiable {
    let id: UUID
    var name: String
    var sounds: [SoundConfiguration]
    var volume: Float
    var isFavorite: Bool
    var createdAt: Date
    var lastUsed: Date?
    
    struct SoundConfiguration: Codable {
        let type: SoundType
        var isEnabled: Bool
        var individualVolume: Float
    }
}

enum SoundType: String, Codable, CaseIterable {
    case whiteNoise = "white_noise"
    case heartbeat = "heartbeat"
    case rain = "rain"
    case lullaby = "lullaby"
    case vacuum = "vacuum"
    case hairDryer = "hair_dryer"
    case carRide = "car_ride"
    
    var displayName: String {
        switch self {
        case .whiteNoise: return "Белый шум"
        case .heartbeat: return "Сердцебиение"
        case .rain: return "Дождь"
        case .lullaby: return "Колыбельная"
        case .vacuum: return "Пылесос"
        case .hairDryer: return "Фен"
        case .carRide: return "Поездка на машине"
        }
    }
    
    var fileName: String {
        switch self {
        case .whiteNoise: return "white_noise.mp3"
        case .heartbeat: return "heartbeat.mp3"
        case .rain: return "rain.mp3"
        case .lullaby: return "lullaby.mp3"
        case .vacuum: return "vacuum.mp3"
        case .hairDryer: return "hair_dryer.mp3"
        case .carRide: return "car_ride.mp3"
        }
    }
    
    var iconName: String {
        switch self {
        case .whiteNoise: return "speaker.wave.3"
        case .heartbeat: return "heart.fill"
        case .rain: return "cloud.rain.fill"
        case .lullaby: return "music.note"
        case .vacuum: return "fanblades.fill"
        case .hairDryer: return "wind"
        case .carRide: return "car.fill"
        }
    }
    
    var recommendedForAge: ClosedRange<Int>? { // в месяцах
        switch self {
        case .heartbeat: return 0...6
        case .whiteNoise: return 0...24
        case .lullaby: return 3...36
        default: return nil
        }
    }
}
