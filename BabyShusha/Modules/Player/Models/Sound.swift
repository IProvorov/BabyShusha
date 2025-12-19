// Modules/Player/Models/Sound.swift
import SwiftUI

struct Sound: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String
    let fileName: String
    let color: Color
    let category: SoundCategory
    
    enum SoundCategory: String, CaseIterable {
        case whiteNoise = "Белый шум"
        case nature = "Природа"
        case relaxation = "Релаксация"
    }
    
    // Статический список звуков по умолчанию
    static let defaultSounds: [Sound] = [
        Sound(
            title: "Белый шум",
            icon: "sparkles",
            fileName: "white_noise",
            color: .blue,
            category: .whiteNoise
        ),
        Sound(
            title: "Дождь",
            icon: "cloud.rain",
            fileName: "rain",
            color: .cyan,
            category: .nature
        ),
        Sound(
            title: "Сердцебиение",
            icon: "heart.fill",
            fileName: "heartbeat",
            color: .pink,
            category: .relaxation
        ),
        Sound(
            title: "Океан",
            icon: "water.waves",
            fileName: "ocean",
            color: .teal,
            category: .nature
        ),
        Sound(
            title: "Вентилятор",
            icon: "fan",
            fileName: "fan",
            color: .mint,
            category: .whiteNoise
        ),
        Sound(
            title: "Камин",
            icon: "flame",
            fileName: "fireplace",
            color: .orange,
            category: .relaxation
        )
    ]
}
