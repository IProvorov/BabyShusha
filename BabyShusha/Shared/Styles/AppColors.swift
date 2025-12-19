// Shared/Styles/AppColors.swift
import SwiftUI

struct AppColors {
    // Основные цвета
    static let primaryBackground = Color(red: 0.07, green: 0.1, blue: 0.2)
    static let secondaryBackground = Color(red: 0.12, green: 0.08, blue: 0.25)
    static let cardBackground = Color.white.opacity(0.1)
    
    // Ночной режим
    static let nightBackground = Color(red: 0.05, green: 0.05, blue: 0.1)
    static let nightCard = Color(red: 0.1, green: 0.1, blue: 0.15)
    
    // Акцентные цвета для звуков
    static let whiteNoise = Color.blue
    static let rain = Color.cyan
    static let heartbeat = Color.pink
    static let ocean = Color.teal
    static let fan = Color.mint
    static let fireplace = Color.orange
    
    // Градиенты
    static func accentGradient(for color: Color) -> LinearGradient {
        LinearGradient(
            colors: [
                color.opacity(0.8),
                color
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static let glassGradient = LinearGradient(
        colors: [
            .white.opacity(0.1),
            .white.opacity(0.05),
            .white.opacity(0.025)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Текст
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.7)
    static let mutedText = Color.white.opacity(0.5)
    
    // Статусы
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    
    // Получение цвета по имени звука
    static func color(for soundName: String) -> Color {
        switch soundName {
        case "white_noise": return whiteNoise
        case "rain": return rain
        case "heartbeat": return heartbeat
        case "ocean": return ocean
        case "fan": return fan
        case "fireplace": return fireplace
        default: return .blue
        }
    }
}

// Extension для удобного доступа к цветам
extension Color {
    static let app = AppColors.self
}
