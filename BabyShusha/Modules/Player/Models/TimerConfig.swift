// Modules/Player/Models/TimerConfig.swift
import Foundation

struct TimerConfig: Identifiable, Codable {
    let id = UUID()
    let duration: Int // в минутах
    let label: String
    let icon: String
    let isAutoStop: Bool
    let fadeDuration: TimeInterval // длительность fade-out в секундах
    
    // Стандартные таймеры
    static let standardTimers: [TimerConfig] = [
        TimerConfig(duration: 15, label: "15 мин", icon: "timer", isAutoStop: true, fadeDuration: 3.0),
        TimerConfig(duration: 30, label: "30 мин", icon: "timer", isAutoStop: true, fadeDuration: 3.0),
        TimerConfig(duration: 60, label: "60 мин", icon: "timer", isAutoStop: true, fadeDuration: 3.0),
        TimerConfig(duration: 0, label: "Выкл", icon: "timer.slash", isAutoStop: false, fadeDuration: 0)
    ]
    
    var isActive: Bool {
        duration > 0
    }
    
    var totalSeconds: Int {
        duration * 60
    }
}

// Состояние таймера
struct TimerState {
    var isActive: Bool = false
    var timeRemaining: Int = 0
    var startTime: Date?
    var endTime: Date?
    
    var progress: Double {
        guard let start = startTime, let end = endTime else { return 0 }
        let total = end.timeIntervalSince(start)
        let elapsed = Date().timeIntervalSince(start)
        return min(elapsed / total, 1.0)
    }
    
    var formattedRemaining: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
