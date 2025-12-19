import Foundation

struct DailyRoutine: Codable, Identifiable {
    let id: UUID
    var title: String
    var icon: String
    var time: Date
    var duration: TimeInterval // в минутах
    var isEnabled: Bool
    var soundId: String? // Звук для этого времени
    var notificationEnabled: Bool
    
    init(
        title: String,
        icon: String,
        hour: Int,
        minute: Int = 0,
        duration: TimeInterval = 60, // 1 час по умолчанию
        isEnabled: Bool = true,
        soundId: String? = nil,
        notificationEnabled: Bool = true
    ) {
        self.id = UUID()
        self.title = title
        self.icon = icon
        self.duration = duration * 60 // конвертируем в секунды
        
        // Создаем время
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        self.time = Calendar.current.date(from: components) ?? Date()
        
        self.isEnabled = isEnabled
        self.soundId = soundId
        self.notificationEnabled = notificationEnabled
    }
    
    // MARK: - Computed Properties
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: time)
    }
    
    var endTime: Date {
        Calendar.current.date(byAdding: .second, value: Int(duration), to: time) ?? time
    }
    
    var isCurrent: Bool {
        let now = Date()
        return now >= time && now <= endTime
    }
    
    var timeUntil: TimeInterval {
        max(time.timeIntervalSince(Date()), 0)
    }
    
    // MARK: - Default Routines
    
    static func defaultForAge(_ age: AgeCategory) -> [DailyRoutine] {
        switch age {
        case .newborn:
            return [
                DailyRoutine(title: "Кормление", icon: "🍼", hour: 7),
                DailyRoutine(title: "Утренний сон", icon: "😴", hour: 9, duration: 90),
                DailyRoutine(title: "Кормление", icon: "🍼", hour: 12),
                DailyRoutine(title: "Прогулка", icon: "🚶", hour: 13, duration: 60),
                DailyRoutine(title: "Дневной сон", icon: "😴", hour: 15, duration: 90),
                DailyRoutine(title: "Кормление", icon: "🍼", hour: 18),
                DailyRoutine(title: "Купание", icon: "🛁", hour: 20),
                DailyRoutine(title: "Ночной сон", icon: "🌙", hour: 21)
            ]
            
        case .infant, .baby:
            return [
                DailyRoutine(title: "Пробуждение", icon: "🌅", hour: 7),
                DailyRoutine(title: "Завтрак", icon: "🍎", hour: 8),
                DailyRoutine(title: "Игры", icon: "🎮", hour: 9, duration: 120),
                DailyRoutine(title: "Утренний сон", icon: "😴", hour: 11, duration: 90),
                DailyRoutine(title: "Обед", icon: "🥣", hour: 13),
                DailyRoutine(title: "Прогулка", icon: "🚶", hour: 14, duration: 120),
                DailyRoutine(title: "Дневной сон", icon: "😴", hour: 16, duration: 90),
                DailyRoutine(title: "Ужин", icon: "🍽️", hour: 18),
                DailyRoutine(title: "Купание", icon: "🛁", hour: 19),
                DailyRoutine(title: "Сказка", icon: "📖", hour: 19, duration: 30),
                DailyRoutine(title: "Ночной сон", icon: "🌙", hour: 20)
            ]
            
        default:
            return [
                DailyRoutine(title: "Пробуждение", icon: "🌅", hour: 7),
                DailyRoutine(title: "Завтрак", icon: "🍎", hour: 8),
                DailyRoutine(title: "Занятия", icon: "✏️", hour: 9, duration: 90),
                DailyRoutine(title: "Прогулка", icon: "🚶", hour: 11, duration: 120),
                DailyRoutine(title: "Обед", icon: "🥣", hour: 13),
                DailyRoutine(title: "Тихий час", icon: "😴", hour: 14, duration: 120),
                DailyRoutine(title: "Полдник", icon: "🍪", hour: 16),
                DailyRoutine(title: "Игры", icon: "🎮", hour: 17, duration: 90),
                DailyRoutine(title: "Ужин", icon: "🍽️", hour: 18),
                DailyRoutine(title: "Купание", icon: "🛁", hour: 19),
                DailyRoutine(title: "Чтение", icon: "📖", hour: 19, duration: 30),
                DailyRoutine(title: "Сон", icon: "🌙", hour: 20)
            ]
        }
    }
    
    // MARK: - Helper Methods
    
    func timeUntilString() -> String {
        let interval = timeUntil
        if interval == 0 {
            return "Сейчас"
        }
        
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "Через \(hours)ч \(minutes)м"
        } else if minutes > 0 {
            return "Через \(minutes)м"
        } else {
            return "Скоро"
        }
    }
}

// MARK: - Mock Data
extension DailyRoutine {
    static var mockDay: [DailyRoutine] {
        return [
            DailyRoutine(title: "Пробуждение", icon: "🌅", hour: 7, isEnabled: true),
            DailyRoutine(title: "Завтрак", icon: "🍎", hour: 8, isEnabled: true),
            DailyRoutine(title: "Игры", icon: "🎮", hour: 9, duration: 120, isEnabled: true),
            DailyRoutine(title: "Утренний сон", icon: "😴", hour: 11, duration: 90, isEnabled: true),
            DailyRoutine(title: "Обед", icon: "🥣", hour: 13, isEnabled: true),
            DailyRoutine(title: "Прогулка", icon: "🚶", hour: 14, duration: 120, isEnabled: true),
            DailyRoutine(title: "Дневной сон", icon: "😴", hour: 16, duration: 90, isEnabled: true),
            DailyRoutine(title: "Ужин", icon: "🍽️", hour: 18, isEnabled: true),
            DailyRoutine(title: "Купание", icon: "🛁", hour: 19, isEnabled: true),
            DailyRoutine(title: "Сказка", icon: "📖", hour: 19, duration: 30, isEnabled: true),
            DailyRoutine(title: "Ночной сон", icon: "🌙", hour: 20, isEnabled: true)
        ]
    }
}
