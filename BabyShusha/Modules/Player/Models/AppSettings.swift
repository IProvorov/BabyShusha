// Modules/Player/Models/AppSettings.swift
import SwiftUI
import Foundation

struct AppSettings: Codable {
    // Настройки звука
    var volume: Float = 0.5
    var fadeInEnabled: Bool = true
    var fadeInDuration: TimeInterval = 2.0
    var fadeOutEnabled: Bool = true
    var fadeOutDuration: TimeInterval = 3.0
    
    // Настройки таймера
    var defaultTimerDuration: Int = 30
    var autoStartTimer: Bool = false
    var vibrationOnTimerEnd: Bool = true
    
    // Настройки интерфейса
    var isNightMode: Bool = false
    var showPulseAnimation: Bool = true
    var useAdaptiveColors: Bool = true
    
    // Настройки доступности
    var hapticFeedbackEnabled: Bool = true
    var soundOnButtonPress: Bool = false
    var largeControlSize: Bool = false
    
    // Системные настройки
    var lastSelectedSound: String = "white_noise"
    var firstLaunchDate: Date = Date()
    var launchCount: Int = 0
    
    // Функции для работы с UserDefaults
    static func load() -> AppSettings {
        if let data = UserDefaults.standard.data(forKey: "app_settings"),
           let settings = try? JSONDecoder().decode(AppSettings.self, from: data) {
            return settings
        }
        return AppSettings() // Возвращаем настройки по умолчанию
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "app_settings")
        }
    }
    
    static var preview: AppSettings {
        var settings = AppSettings()
        settings.volume = 0.7
        settings.isNightMode = true
        settings.defaultTimerDuration = 60
        return settings
    }
}
