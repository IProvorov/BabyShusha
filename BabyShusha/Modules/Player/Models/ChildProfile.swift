import Foundation

struct ChildProfile: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var birthDate: Date
    var avatarEmoji: String
    var isActive: Bool // Активный профиль
    var sleepGoalHours: Double // Цель сна в часах
    var notes: String // Дополнительные заметки
    var favoriteSounds: [String] // Любимые звуки этого ребенка
    var sleepRoutine: [SleepRoutineItem] // Режим дня
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        name: String = "Малыш",
        birthDate: Date = Date(),
        avatarEmoji: String = "👶",
        isActive: Bool = true,
        sleepGoalHours: Double = 12.0,
        notes: String = "",
        favoriteSounds: [String] = [],
        sleepRoutine: [SleepRoutineItem] = []
    ) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.avatarEmoji = avatarEmoji
        self.isActive = isActive
        self.sleepGoalHours = sleepGoalHours
        self.notes = notes
        self.favoriteSounds = favoriteSounds
        self.sleepRoutine = sleepRoutine.isEmpty ? SleepRoutineItem.defaultRoutine() : sleepRoutine
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Computed Properties
    
    var ageInMonths: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: birthDate, to: Date())
        return components.month ?? 0
    }
    
    var ageString: String {
        let months = ageInMonths
        if months < 1 {
            return "Новорожденный"
        } else if months < 12 {
            return "\(months) мес."
        } else {
            let years = months / 12
            let remainingMonths = months % 12
            if remainingMonths == 0 {
                return "\(years) год"
            } else {
                return "\(years) г. \(remainingMonths) мес."
            }
        }
    }
    
    var ageCategory: AgeCategory {
        switch ageInMonths {
        case 0..<3: return .newborn
        case 3..<6: return .infant
        case 6..<12: return .baby
        case 12..<24: return .toddler
        case 24..<36: return .preschooler
        default: return .child
        }
    }
    
    var sleepGoalFormatted: String {
        let hours = Int(sleepGoalHours)
        let minutes = Int((sleepGoalHours - Double(hours)) * 60)
        
        if minutes > 0 {
            return "\(hours)ч \(minutes)м"
        } else {
            return "\(hours)ч"
        }
    }
    
    // MARK: - Methods
    
    mutating func update(
        name: String? = nil,
        birthDate: Date? = nil,
        avatarEmoji: String? = nil,
        sleepGoalHours: Double? = nil,
        notes: String? = nil
    ) {
        if let name = name { self.name = name }
        if let birthDate = birthDate { self.birthDate = birthDate }
        if let avatarEmoji = avatarEmoji { self.avatarEmoji = avatarEmoji }
        if let sleepGoalHours = sleepGoalHours { self.sleepGoalHours = sleepGoalHours }
        if let notes = notes { self.notes = notes }
        self.updatedAt = Date()
    }
    
    mutating func addFavoriteSound(_ soundId: String) {
        if !favoriteSounds.contains(soundId) {
            favoriteSounds.append(soundId)
            updatedAt = Date()
        }
    }
    
    mutating func removeFavoriteSound(_ soundId: String) {
        favoriteSounds.removeAll { $0 == soundId }
        updatedAt = Date()
    }
    
    mutating func updateSleepRoutine(_ routine: [SleepRoutineItem]) {
        sleepRoutine = routine
        updatedAt = Date()
    }
    
    static func == (lhs: ChildProfile, rhs: ChildProfile) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Supporting Types

enum AgeCategory: String, Codable, CaseIterable {
    case newborn = "Новорожденный"
    case infant = "Младенец"
    case baby = "Грудничок"
    case toddler = "Малыш"
    case preschooler = "Дошкольник"
    case child = "Ребенок"
    
    var sleepRecommendation: String {
        switch self {
        case .newborn: return "14-17 часов"
        case .infant: return "12-16 часов"
        case .baby: return "12-15 часов"
        case .toddler: return "11-14 часов"
        case .preschooler: return "10-13 часов"
        case .child: return "9-11 часов"
        }
    }
    
    var recommendedSleepGoal: Double {
        switch self {
        case .newborn: return 15.5
        case .infant: return 14.0
        case .baby: return 13.5
        case .toddler: return 12.5
        case .preschooler: return 11.5
        case .child: return 10.0
        }
    }
    
    var icon: String {
        switch self {
        case .newborn: return "👶"
        case .infant: return "🍼"
        case .baby: return "🐻"
        case .toddler: return "🚶"
        case .preschooler: return "✏️"
        case .child: return "👦"
        }
    }
}

struct SleepRoutineItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var icon: String
    var time: String // "HH:mm"
    var duration: Int // в минутах
    var isEnabled: Bool
    var soundId: String?
    
    init(
        id: UUID = UUID(),
        title: String,
        icon: String,
        time: String,
        duration: Int = 60,
        isEnabled: Bool = true,
        soundId: String? = nil
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.time = time
        self.duration = duration
        self.isEnabled = isEnabled
        self.soundId = soundId
    }
    
    static func defaultRoutine() -> [SleepRoutineItem] {
        return [
            SleepRoutineItem(title: "Пробуждение", icon: "🌅", time: "07:00"),
            SleepRoutineItem(title: "Завтрак", icon: "🍎", time: "08:00", duration: 30),
            SleepRoutineItem(title: "Игры", icon: "🎮", time: "09:00", duration: 120),
            SleepRoutineItem(title: "Утренний сон", icon: "😴", time: "11:00", duration: 90),
            SleepRoutineItem(title: "Обед", icon: "🥣", time: "13:00", duration: 45),
            SleepRoutineItem(title: "Прогулка", icon: "🚶", time: "14:00", duration: 120),
            SleepRoutineItem(title: "Дневной сон", icon: "😴", time: "16:00", duration: 90),
            SleepRoutineItem(title: "Ужин", icon: "🍽️", time: "18:00", duration: 45),
            SleepRoutineItem(title: "Купание", icon: "🛁", time: "19:30", duration: 30),
            SleepRoutineItem(title: "Чтение", icon: "📖", time: "20:00", duration: 30),
            SleepRoutineItem(title: "Ночной сон", icon: "🌙", time: "20:30")
        ]
    }
}

// MARK: - Mock Data
extension ChildProfile {
    static var mockChildren: [ChildProfile] {
        return [
            ChildProfile(
                name: "Саша",
                birthDate: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
                avatarEmoji: "🐻",
                sleepGoalHours: 13.5,
                notes: "Любит спать с белым шумом"
            ),
            ChildProfile(
                name: "Маша",
                birthDate: Calendar.current.date(byAdding: .month, value: -18, to: Date()) ?? Date(),
                avatarEmoji: "🐰",
                sleepGoalHours: 12.0,
                notes: "Требует сказку перед сном"
            ),
            ChildProfile(
                name: "Ваня",
                birthDate: Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date(),
                avatarEmoji: "🐯",
                sleepGoalHours: 11.0,
                notes: "Спит с ночником"
            )
        ]
    }
    
    static var mock: ChildProfile {
        return mockChildren[0]
    }
}
