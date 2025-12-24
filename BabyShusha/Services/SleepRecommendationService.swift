import Foundation

// MARK: - SleepRecommendation Model
struct SleepRecommendation: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let category: RecommendationCategory
    let priority: Priority
    let action: RecommendationAction?
    
    enum Priority: Int, Comparable {
        case low = 0, medium = 1, high = 2, critical = 3
        
        static func < (lhs: Priority, rhs: Priority) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
    
    enum RecommendationCategory: String, CaseIterable {
        case schedule, environment, feeding, health, routine
        
        var displayName: String {
            switch self {
            case .schedule: return "Расписание"
            case .environment: return "Окружение"
            case .feeding: return "Кормление"
            case .health: return "Здоровье"
            case .routine: return "Ритуалы"
            }
        }
    }
    
    struct RecommendationAction {
        let title: String
        let handler: () -> Void
    }
}

// MARK: - SleepRecommendationService
class SleepRecommendationService: ObservableObject {
    static let shared = SleepRecommendationService()
    
    @Published var recommendations: [SleepRecommendation] = []
    @Published var dailyTip: String = ""
    
    private let dataStorageService: DataStorageService
    private let calendar = Calendar.current
    private let tips: [String]
    
    init(dataStorageService: DataStorageService = DataStorageService()) {
        self.dataStorageService = dataStorageService
        self.tips = [
            "Температура в комнате должна быть 18-22°C",
            "Используйте спальный мешок вместо одеяла",
            "Проветривайте комнату перед сном",
            "Избегайте активных игр за час до сна",
            "Соблюдайте ритуал укладывания"
        ]
        setDailyTip()
        loadRecommendations()
    }
    
    // MARK: - Public Methods
    
    func refreshRecommendations(for child: ChildProfile? = nil) {
        guard let child = child else {
            recommendations = getGeneralRecommendations()
            return
        }
        
        let sessions = dataStorageService.loadSleepSessions(for: child.id)
        let newRecommendations = generateRecommendations(for: child, sessions: sessions)
        recommendations = newRecommendations
    }
    
    func getDailyTip(for child: ChildProfile? = nil) -> String {
        if let child = child {
            return getPersonalizedTip(for: child)
        }
        return dailyTip
    }
    
    // MARK: - Private Methods
    
    private func setDailyTip() {
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let tipIndex = dayOfYear % tips.count
        dailyTip = tips[tipIndex]
    }
    
    private func loadRecommendations() {
        recommendations = getGeneralRecommendations()
    }
    
    private func getGeneralRecommendations() -> [SleepRecommendation] {
        return [
            SleepRecommendation(
                id: UUID(),
                title: "Начните отслеживать сон",
                description: "Ведите дневник сна, чтобы понимать паттерны и улучшать режим",
                category: .schedule,
                priority: .medium,
                action: nil
            ),
            SleepRecommendation(
                id: UUID(),
                title: "Создайте уютную атмосферу",
                description: "Подготовьте комнату ко сну: приглушите свет, проветрите",
                category: .environment,
                priority: .medium,
                action: SleepRecommendation.RecommendationAction(
                    title: "Включить звуки",
                    handler: {
                        // Будешь реализовывать позже
                        print("Включить звуки")
                    }
                )
            )
        ]
    }
    
    private func generateRecommendations(for child: ChildProfile, sessions: [SleepSession]) -> [SleepRecommendation] {
        var recommendations: [SleepRecommendation] = []
        
        // Возрастные рекомендации
        recommendations.append(contentsOf: getAgeBasedRecommendations(for: child))
        
        // Рекомендации по расписанию
        recommendations.append(contentsOf: getScheduleRecommendations(for: child, sessions: sessions))
        
        return recommendations.sorted { $0.priority > $1.priority }
    }
    
    private func getAgeBasedRecommendations(for child: ChildProfile) -> [SleepRecommendation] {
        let ageInMonths = child.ageInMonths
        var recommendations: [SleepRecommendation] = []
        
        if ageInMonths <= 3 {
            recommendations.append(SleepRecommendation(
                id: UUID(),
                title: "Кормление по требованию",
                description: "Новорожденные просыпаются каждые 2-3 часа для кормления.",
                category: .feeding,
                priority: .high,
                action: nil
            ))
        }
        
        if ageInMonths >= 4 && ageInMonths <= 6 {
            recommendations.append(SleepRecommendation(
                id: UUID(),
                title: "Время укладывания",
                description: "Идеальное время укладывания: 18:30-19:30",
                category: .schedule,
                priority: .high,
                action: nil
            ))
        }
        
        return recommendations
    }
    
    private func getScheduleRecommendations(for child: ChildProfile, sessions: [SleepSession]) -> [SleepRecommendation] {
        var recommendations: [SleepRecommendation] = []
        
        guard !sessions.isEmpty else { return recommendations }
        
        let lastWeekSessions = sessions.filter { session in
            calendar.dateComponents([.day], from: session.endDate, to: Date()).day ?? 7 <= 7
        }
        
        if lastWeekSessions.isEmpty {
            recommendations.append(SleepRecommendation(
                id: UUID(),
                title: "Начните отслеживание",
                description: "Отслеживайте сон, чтобы получать персонализированные рекомендации",
                category: .schedule,
                priority: .medium,
                action: nil
            ))
        }
        
        return recommendations
    }
    
    private func getPersonalizedTip(for child: ChildProfile) -> String {
        let ageInMonths = child.ageInMonths
        
        if ageInMonths < 3 {
            return "Новорожденным важно кормление по требованию и контакт кожа-к-коже"
        } else if ageInMonths < 6 {
            return "В 3-6 месяцев формируется режим сна. Старайтесь укладывать в одно время"
        } else {
            return "Соблюдайте ритуал укладывания для лучшего засыпания"
        }
    }
}
