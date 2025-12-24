import Foundation

// MARK: - ChildGender Enum
enum ChildGender: String, Codable, CaseIterable {
    case male = "male"
    case female = "female"
    case notSpecified = "not_specified"
    
    var displayName: String {
        switch self {
        case .male: return "Мальчик"
        case .female: return "Девочка"
        case .notSpecified: return "Не указано"
        }
    }
    
    var emoji: String {
        switch self {
        case .male: return "👦"
        case .female: return "👧"
        case .notSpecified: return "👶"
        }
    }
    
    var pronoun: String {
        switch self {
        case .male: return "он"
        case .female: return "она"
        case .notSpecified: return "малыш"
        }
    }
    
    var possessivePronoun: String {
        switch self {
        case .male: return "его"
        case .female: return "её"
        case .notSpecified: return "малыша"
        }
    }
}

// MARK: - BMI Percentile Data (WHO Standards)
struct BMIPercentileData {
    let month: Int
    let male: [Double]    // percentiles: 3rd, 15th, 50th, 85th, 97th
    let female: [Double]  // percentiles: 3rd, 15th, 50th, 85th, 97th
}

// WHO BMI-for-age percentiles data (0-60 months)
private let whoBMIPercentiles: [BMIPercentileData] = [
    // Month 0 (newborn)
    BMIPercentileData(month: 0, male: [10.2, 11.4, 13.4, 15.8, 17.7], female: [9.8, 10.9, 12.9, 15.1, 16.9]),
    // Month 1
    BMIPercentileData(month: 1, male: [12.2, 13.6, 15.8, 18.3, 20.3], female: [11.6, 12.9, 15.1, 17.5, 19.5]),
    // Month 2
    BMIPercentileData(month: 2, male: [13.6, 15.0, 17.3, 19.9, 22.1], female: [12.9, 14.3, 16.5, 19.1, 21.1]),
    // Month 3
    BMIPercentileData(month: 3, male: [14.5, 15.9, 18.3, 21.0, 23.2], female: [13.7, 15.1, 17.4, 20.1, 22.2]),
    // Month 6
    BMIPercentileData(month: 6, male: [15.2, 16.6, 19.0, 21.7, 23.9], female: [14.4, 15.8, 18.1, 20.8, 22.9]),
    // Month 9
    BMIPercentileData(month: 9, male: [15.4, 16.8, 19.1, 21.8, 24.0], female: [14.6, 16.0, 18.2, 20.9, 23.0]),
    // Month 12
    BMIPercentileData(month: 12, male: [15.3, 16.7, 19.0, 21.7, 23.9], female: [14.6, 16.0, 18.2, 20.9, 23.0]),
    // Month 18
    BMIPercentileData(month: 18, male: [15.1, 16.5, 18.8, 21.5, 23.7], female: [14.5, 15.9, 18.1, 20.8, 22.9]),
    // Month 24
    BMIPercentileData(month: 24, male: [14.9, 16.3, 18.6, 21.3, 23.5], female: [14.4, 15.8, 18.0, 20.7, 22.8]),
    // Month 36
    BMIPercentileData(month: 36, male: [14.4, 15.8, 18.1, 20.8, 23.0], female: [14.0, 15.4, 17.6, 20.3, 22.4]),
    // Month 48
    BMIPercentileData(month: 48, male: [14.1, 15.5, 17.8, 20.5, 22.7], female: [13.7, 15.1, 17.3, 20.0, 22.1]),
    // Month 60
    BMIPercentileData(month: 60, male: [13.9, 15.3, 17.6, 20.3, 22.5], female: [13.5, 14.9, 17.1, 19.8, 21.9]),
]

// MARK: - ChildProfile Model
struct ChildProfile: Identifiable, Codable, Equatable, Hashable {
    
    // MARK: - Properties
    let id: UUID
    var name: String
    var birthDate: Date
    var gender: ChildGender
    var avatarEmoji: String?
    var weight: Double?           // в килограммах
    var height: Double?           // в сантиметрах
    var headCircumference: Double? // окружность головы в см
    var notes: String?
    var isActive: Bool = true
    var createdAt: Date
    var updatedAt: Date
    var sleepPreferences: SleepPreferences?
    var feedingPreferences: FeedingPreferences?
    var medicalNotes: String?
    
    // MARK: - Sleep Preferences
    struct SleepPreferences: Codable, Equatable {
        var preferredSoundType: Sound.SoundType?
        var bedtime: Date?              // предпочтительное время отхода ко сну (20:30)
        var wakeupTime: Date?           // предпочтительное время пробуждения (07:00)
        var napCount: Int?              // количество дневных снов
        var totalSleepHours: Double?    // общая потребность во сне (часы)
        var sleepAssociations: [String]? // ассоциации на сон (укачивание, грудь и т.д.)
        var hasSleepRoutine: Bool = false
        var routineSteps: [String]?     // шаги ритуала перед сном
    }
    
    // MARK: - Feeding Preferences
    struct FeedingPreferences: Codable, Equatable {
        var feedingType: FeedingType = .breast
        var feedingFrequency: Int?      // кормлений в день
        var lastFeedingTime: Date?
        var preferredFormula: String?
        var hasAllergies: Bool = false
        var allergies: [String]?
        var solidFoods: [String]?       // введенные прикормы
        var feedingNotes: String?
        
        enum FeedingType: String, Codable {
            case breast = "breast"       // грудное вскармливание
            case formula = "formula"     // искусственное вскармливание
            case mixed = "mixed"         // смешанное вскармливание
            case solids = "solids"       // прикорм
            
            var displayName: String {
                switch self {
                case .breast: return "Грудное"
                case .formula: return "Искусственное"
                case .mixed: return "Смешанное"
                case .solids: return "Прикорм"
                }
            }
        }
    }
    
    // MARK: - Initializers
    init(id: UUID = UUID(),
         name: String,
         birthDate: Date,
         gender: ChildGender = .notSpecified,
         avatarEmoji: String? = nil,
         weight: Double? = nil,
         height: Double? = nil,
         headCircumference: Double? = nil,
         notes: String? = nil,
         isActive: Bool = true,
         createdAt: Date = Date(),
         updatedAt: Date = Date(),
         sleepPreferences: SleepPreferences? = nil,
         feedingPreferences: FeedingPreferences? = nil,
         medicalNotes: String? = nil) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.gender = gender
        self.avatarEmoji = avatarEmoji
        self.weight = weight
        self.height = height
        self.headCircumference = headCircumference
        self.notes = notes
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sleepPreferences = sleepPreferences
        self.feedingPreferences = feedingPreferences
        self.medicalNotes = medicalNotes
    }
    
    // MARK: - Computed Properties
    
    /// Возраст в месяцах (точный)
    var ageInMonths: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: birthDate, to: Date())
        return components.month ?? 0
    }
    
    /// Возраст в месяцах с дробной частью (для точных расчетов)
    var exactAgeInMonths: Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: birthDate, to: Date())
        let years = Double(components.year ?? 0)
        let months = Double(components.month ?? 0)
        let days = Double(components.day ?? 0)
        return years * 12 + months + days / 30.44 // среднее количество дней в месяце
    }
    
    /// Возраст в годах с дробной частью
    var ageInYears: Double {
        exactAgeInMonths / 12.0
    }
    
    /// Возраст в днях
    var ageInDays: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: birthDate, to: Date())
        return components.day ?? 0
    }
    
    /// Человеко-читаемое описание возраста
    var ageDescription: String {
        let months = ageInMonths
        
        if months == 0 {
            return "Новорожденный (\(ageInDays) дней)"
        } else if months == 1 {
            return "1 месяц"
        } else if months < 12 {
            return "\(months) \(monthWord(for: months))"
        } else {
            let years = months / 12
            let remainingMonths = months % 12
            
            if remainingMonths == 0 {
                return "\(years) \(yearWord(for: years))"
            } else {
                return "\(years) \(yearWord(for: years)) \(remainingMonths) \(monthWord(for: remainingMonths))"
            }
        }
    }
    
    /// Короткое описание возраста
    var shortAgeDescription: String {
        let months = ageInMonths
        
        if months == 0 {
            return "\(ageInDays)д"
        } else if months < 12 {
            return "\(months)м"
        } else {
            let years = months / 12
            let remainingMonths = months % 12
            
            if remainingMonths == 0 {
                return "\(years)г"
            } else {
                return "\(years)г\(remainingMonths)м"
            }
        }
    }
    
    /// Возрастная категория по ВОЗ
    var whoAgeCategory: WHOAgeCategory {
        let exactAge = exactAgeInMonths
        
        if exactAge < 0.5 { return .preterm }          // < 2 недель
        else if exactAge < 1 { return .newborn }       // 2 недели - 1 месяц
        else if exactAge < 3 { return .youngInfant }   // 1-3 месяца
        else if exactAge < 6 { return .olderInfant }   // 3-6 месяцев
        else if exactAge < 12 { return .crawler }      // 6-12 месяцев
        else if exactAge < 24 { return .toddler }      // 1-2 года
        else if exactAge < 36 { return .preschooler }  // 2-3 года
        else if exactAge < 60 { return .preschooler }  // 3-5 лет
        else { return .schoolAge }                     // 5+ лет
    }
    
    /// Возрастные категории ВОЗ
    enum WHOAgeCategory: String {
        case preterm = "Недоношенный"      // < 37 недель гестации
        case newborn = "Новорожденный"     // 0-1 месяц
        case youngInfant = "Младенец"      // 1-3 месяца
        case olderInfant = "Грудничок"     // 3-6 месяцев
        case crawler = "Ползунок"          // 6-12 месяцев
        case toddler = "Малыш"             // 1-2 года
        case preschooler = "Дошкольник"    // 2-5 лет
        case schoolAge = "Школьник"        // 5+ лет
        
        var description: String {
            return self.rawValue
        }
        
        var icon: String {
            switch self {
            case .preterm: return "🕊️"
            case .newborn: return "👶"
            case .youngInfant: return "🍼"
            case .olderInfant: return "🐣"
            case .crawler: return "🐢"
            case .toddler: return "🚶‍♂️"
            case .preschooler: return "🎨"
            case .schoolAge: return "🎒"
            }
        }
        
        var whoCode: String {
            switch self {
            case .preterm: return "PT"
            case .newborn: return "NB"
            case .youngInfant: return "YI"
            case .olderInfant: return "OI"
            case .crawler: return "CR"
            case .toddler: return "TD"
            case .preschooler: return "PS"
            case .schoolAge: return "SA"
            }
        }
    }
    
    /// BMI (индекс массы тела) - WHO Standard
    var bmi: Double? {
        guard let weight = weight, let height = height, height > 0 else {
            return nil
        }
        
        let heightInMeters = height / 100.0
        return weight / (heightInMeters * heightInMeters)
    }
    
    /// BMI Percentile по данным ВОЗ (более точный расчет)
    var bmiPercentileWHO: Double? {
        guard let bmi = bmi else { return nil }
        let exactAge = exactAgeInMonths
        
        // Получаем данные для ближайшего месяца
        let targetMonth = min(Int(exactAge.rounded()), 60)
        
        // Находим ближайшие данные
        guard let data = whoBMIPercentiles.first(where: { $0.month >= targetMonth }) ??
                        whoBMIPercentiles.last else {
            return nil
        }
        
        // Выбираем percentiles в зависимости от пола
        let percentiles = (gender == .male) ? data.male : data.female
        
        // Определяем перцентиль
        if bmi < percentiles[0] { return 3.0 }      // < 3rd percentile
        else if bmi < percentiles[1] { return 15.0 } // 3rd - 15th
        else if bmi < percentiles[2] { return 50.0 } // 15th - 50th
        else if bmi < percentiles[3] { return 85.0 } // 50th - 85th
        else if bmi < percentiles[4] { return 97.0 } // 85th - 97th
        else { return 99.0 }                         // > 97th percentile
    }
    
    /// Категория BMI по ВОЗ
    var bmiCategoryWHO: String? {
        guard let percentile = bmiPercentileWHO else { return nil }
        
        switch percentile {
        case ..<5:          return "Выраженный дефицит массы тела"
        case 5..<15:        return "Дефицит массы тела"
        case 15..<85:       return "Нормальная масса тела"
        case 85..<95:       return "Избыточная масса тела"
        case 95..<97:       return "Ожирение 1 степени"
        case 97...:         return "Ожирение 2 степени"
        default:            return "Нормальная масса тела"
        }
    }
    
    /// Цвет для отображения BMI категории
    var bmiCategoryColor: (colorName: String, hex: String)? {
        guard let percentile = bmiPercentileWHO else { return nil }
        
        switch percentile {
        case ..<5:          return ("Red", "#FF3B30")      // Выраженный дефицит
        case 5..<15:        return ("Orange", "#FF9500")   // Дефицит
        case 15..<85:       return ("Green", "#34C759")    // Норма
        case 85..<95:       return ("Yellow", "#FFCC00")   // Избыточный вес
        case 95..<97:       return ("Orange", "#FF9500")   // Ожирение 1
        case 97...:         return ("Red", "#FF3B30")      // Ожирение 2
        default:            return ("Green", "#34C759")
        }
    }
    
    /// Ростовая кривая (percentile)
    var heightPercentileWHO: Double? {
        guard let height = height else { return nil }
        // Здесь должна быть реализация с таблицами ВОЗ для роста
        // Возвращаем примерное значение
        return 50.0 // Заглушка
    }
    
    /// Весовая кривая (percentile)
    var weightPercentileWHO: Double? {
        guard let weight = weight else { return nil }
        // Здесь должна быть реализация с таблицами ВОЗ для веса
        // Возвращаем примерное значение
        return 50.0 // Заглушка
    }
    
    /// Окружность головы (percentile)
    var headCircumferencePercentileWHO: Double? {
        guard let hc = headCircumference else { return nil }
        // Здесь должна быть реализация с таблицами ВОЗ для окружности головы
        // Возвращаем примерное значение
        return 50.0 // Заглушка
    }
    
    /// Отображаемый эмодзи
    var displayEmoji: String {
        return avatarEmoji ?? gender.emoji
    }
    
    /// Полное имя с эмодзи
    var displayName: String {
        return "\(displayEmoji) \(name)"
    }
    
    /// Инициалы для аватарки
    var initials: String {
        let components = name.split(separator: " ")
        if let first = components.first, let firstChar = first.first {
            if components.count > 1, let last = components.last, let lastChar = last.first {
                return "\(firstChar)\(lastChar)".uppercased()
            }
            return "\(firstChar)".uppercased()
        }
        return "👶"
    }
    
    // MARK: - Sleep Recommendations (WHO Based)
    
    /// Рекомендуемая продолжительность сна по ВОЗ (в часах)
    var recommendedSleepHoursWHO: (min: Double, max: Double) {
        switch whoAgeCategory {
        case .newborn:      return (14, 17)    // 0-3 месяца
        case .youngInfant:  return (12, 16)    // 4-11 месяцев
        case .olderInfant:  return (12, 16)    // 4-11 месяцев
        case .crawler:      return (11, 14)    // 1-2 года
        case .toddler:      return (10, 13)    // 2-3 года
        case .preschooler:  return (10, 12)    // 3-5 лет
        default:            return (9, 11)     // 5+ лет
        }
    }
    
    /// Рекомендуемое количество дневных снов по возрасту
    var recommendedNapCount: Int {
        switch exactAgeInMonths {
        case ..<4:          return 3           // 3-4 сна
        case 4..<9:         return 3           // 3 сна
        case 9..<16:        return 2           // 2 сна
        case 16..<36:       return 1           // 1 сон
        default:            return 0           // без дневного сна
        }
    }
    
    /// Рекомендуемое время бодрствования между снами (Wake Windows)
    var recommendedWakeWindows: (min: Double, max: Double) {
        switch exactAgeInMonths {
        case 0..<1:         return (0.75, 1.0)     // 45-60 мин
        case 1..<2:         return (1.0, 1.5)      // 1-1.5 часа
        case 2..<3:         return (1.25, 1.75)    // 1.25-1.75 часа
        case 3..<5:         return (1.5, 2.0)      // 1.5-2 часа
        case 5..<8:         return (2.0, 2.5)      // 2-2.5 часа
        case 8..<12:        return (2.5, 3.0)      // 2.5-3 часа
        case 12..<18:       return (3.0, 3.5)      // 3-3.5 часа
        case 18..<36:       return (4.0, 5.0)      // 4-5 часов
        default:            return (5.0, 6.0)      // 5-6 часов
        }
    }
    
    /// Рекомендуемое время отхода ко сну по возрасту
    var recommendedBedtime: Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 19  // 19:00 для детей до 5 лет
        components.minute = 30
        
        if exactAgeInMonths > 60 { // После 5 лет
            components.hour = 20   // 20:00
            components.minute = 0
        }
        
        return calendar.date(from: components)
    }
    
    // MARK: - Feeding Recommendations
    
    /// Рекомендуемое количество кормлений в сутки
    var recommendedFeedingFrequency: Int {
        switch exactAgeInMonths {
        case 0..<1:         return 8    // Каждые 3 часа
        case 1..<3:         return 7    // 7 раз
        case 3..<6:         return 6    // 6 раз
        case 6..<9:         return 5    // 5 раз + прикорм
        case 9..<12:        return 4    // 4 раза + прикорм
        case 12..<24:       return 3    // 3 основных приема
        default:            return 3    // 3 приема пищи
        }
    }
    
    // MARK: - Development Milestones (Simplified)
    
    /// Основные вехи развития для этого возраста
    var developmentalMilestones: [String] {
        let milestones: [String]
        
        switch whoAgeCategory {
        case .newborn:
            milestones = [
                "Реагирует на громкие звуки",
                "Фокусирует взгляд на лицах",
                "Поднимает голову лежа на животе"
            ]
        case .youngInfant:
            milestones = [
                "Улыбается в ответ",
                "Следит за предметами глазами",
                "Издает первые звуки"
            ]
        case .olderInfant:
            milestones = [
                "Переворачивается со спины на живот",
                "Сидит с поддержкой",
                "Тянется к игрушкам"
            ]
        case .crawler:
            milestones = [
                "Ползает на четвереньках",
                "Стоит с поддержкой",
                "Произносит «мама», «папа»"
            ]
        case .toddler:
            milestones = [
                "Ходит самостоятельно",
                "Говорит 10-20 слов",
                "Показывает части тела"
            ]
        case .preschooler:
            milestones = [
                "Бегает и прыгает",
                "Составляет простые предложения",
                "Рисует каракули"
            ]
        default:
            milestones = []
        }
        
        return milestones
    }
    
    // MARK: - Helper Methods
    
    /// Правильное склонение слова "месяц"
    private func monthWord(for count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            return "месяцев"
        }
        
        switch lastDigit {
        case 1: return "месяц"
        case 2, 3, 4: return "месяца"
        default: return "месяцев"
        }
    }
    
    /// Правильное склонение слова "год"
    private func yearWord(for count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            return "лет"
        }
        
        switch lastDigit {
        case 1: return "год"
        case 2, 3, 4: return "года"
        default: return "лет"
        }
    }
    
    // MARK: - Mutating Methods
    
    mutating func update(_ updatedProfile: ChildProfile) {
        self.name = updatedProfile.name
        self.birthDate = updatedProfile.birthDate
        self.gender = updatedProfile.gender
        self.avatarEmoji = updatedProfile.avatarEmoji
        self.weight = updatedProfile.weight
        self.height = updatedProfile.height
        self.headCircumference = updatedProfile.headCircumference
        self.notes = updatedProfile.notes
        self.sleepPreferences = updatedProfile.sleepPreferences
        self.feedingPreferences = updatedProfile.feedingPreferences
        self.medicalNotes = updatedProfile.medicalNotes
        self.updatedAt = Date()
    }
    
    mutating func updateSleepPreferences(_ preferences: SleepPreferences) {
        self.sleepPreferences = preferences
        self.updatedAt = Date()
    }
    
    mutating func updateFeedingPreferences(_ preferences: FeedingPreferences) {
        self.feedingPreferences = preferences
        self.updatedAt = Date()
    }
    
    mutating func addMeasurement(weight: Double? = nil, height: Double? = nil, headCircumference: Double? = nil) {
        if let weight = weight { self.weight = weight }
        if let height = height { self.height = height }
        if let hc = headCircumference { self.headCircumference = hc }
        self.updatedAt = Date()
    }
    
    // MARK: - Equatable Conformance
    static func == (lhs: ChildProfile, rhs: ChildProfile) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Hashable Conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Extensions

extension ChildProfile {
    /// JSON представление профиля
    var jsonRepresentation: [String: Any]? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        guard let data = try? encoder.encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        return dictionary
    }
    
    /// Создание из JSON
    static func from(json: [String: Any]) -> ChildProfile? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let data = try? JSONSerialization.data(withJSONObject: json),
              let profile = try? decoder.decode(ChildProfile.self, from: data) else {
            return nil
        }
        
        return profile
    }
    
    /// Сводка здоровья ребенка
    var healthSummary: String {
        var summary = "\(name), \(ageDescription)\n"
        
        if let weight = weight, let height = height {
            summary += "Вес: \(String(format: "%.1f", weight)) кг, Рост: \(String(format: "%.0f", height)) см\n"
        }
        
        if let bmiCat = bmiCategoryWHO {
            summary += "ИМТ: \(bmiCat)"
            if let percentile = bmiPercentileWHO {
                summary += " (\(String(format: "%.0f", percentile))-й перцентиль)"
            }
        }
        
        return summary
    }
    
    /// Сводка сна
    var sleepSummary: String {
        let sleepHours = recommendedSleepHoursWHO
        return "Рекомендуемый сон: \(String(format: "%.0f", sleepHours.min))-\(String(format: "%.0f", sleepHours.max)) часов, \(recommendedNapCount) дневных сна"
    }
}

// MARK: - Preview Data
#if DEBUG
extension ChildProfile {
    static let previewNewborn = ChildProfile(
        name: "Миша",
        birthDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
        gender: .male,
        avatarEmoji: "👶",
        weight: 3.5,
        height: 52,
        headCircumference: 35.5
    )
    
    static let previewInfant = ChildProfile(
        name: "Аня",
        birthDate: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
        gender: .female,
        avatarEmoji: "🍼",
        weight: 5.2,
        height: 58,
        headCircumference: 39.0,
        sleepPreferences: SleepPreferences(
            preferredSoundType: .heartbeat,
            bedtime: Calendar.current.date(bySettingHour: 20, minute: 30, second: 0, of: Date()),
            napCount: 4
        )
    )
    
    static let previewToddler = ChildProfile(
        name: "Даниил",
        birthDate: Calendar.current.date(byAdding: .year, value: -1, month: -3, to: Date())!,
        gender: .male,
        avatarEmoji: "🚗",
        weight: 11.5,
        height: 82,
        headCircumference: 48.5,
        notes: "Любит машинки, начал ходить в 11 месяцев",
        sleepPreferences: SleepPreferences(
            bedtime: Calendar.current.date(bySettingHour: 19, minute: 45, second: 0, of: Date()),
            napCount: 2,
            hasSleepRoutine: true,
            routineSteps: ["Купание", "Книжка", "Колыбельная"]
        ),
        feedingPreferences: FeedingPreferences(
            feedingType: .mixed,
            feedingFrequency: 4,
            solidFoods: ["Каша", "Овощное пюре", "Фруктовое пюре"]
        )
    )
    
    static let previewPreschooler = ChildProfile(
        name: "София",
        birthDate: Calendar.current.date(byAdding: .year, value: -3, month: -6, to: Date())!,
        gender: .female,
        avatarEmoji: "👸",
        weight: 15.0,
        height: 98,
        headCircumference: 50.0,
        notes: "Обожает принцесс, ходит в детский сад",
        sleepPreferences: SleepPreferences(
            bedtime: Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()),
            napCount: 1,
            hasSleepRoutine: true
        ),
        feedingPreferences: FeedingPreferences(
            feedingType: .solids,
            feedingFrequency: 3,
            hasAllergies: true,
            allergies: ["Мед", "Цитрусовые"]
        )
    )
}
#endif
