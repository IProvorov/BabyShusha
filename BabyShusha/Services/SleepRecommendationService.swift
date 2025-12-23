import Foundation

// MARK: - SleepRecommendation Model
struct SleepRecommendation: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let category: RecommendationCategory
    let priority: Priority
    let action: RecommendationAction?
    let conditions: [RecommendationCondition]
    
    enum Priority: Int, Comparable {
        case low = 0
        case medium = 1
        case high = 2
        case critical = 3
        
        static func < (lhs: Priority, rhs: Priority) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
    
    enum RecommendationCategory: String, CaseIterable {
        case schedule = "schedule"
        case environment = "environment"
        case feeding = "feeding"
        case health = "health"
        case routine = "routine"
        
        var displayName: String {
            switch self {
            case .schedule: return "Расписание"
            case .environment: return "Окружение"
            case .feeding: return "Кормление"
            case .health: return "Здоровье"
            case .routine: return "Ритуалы"
            }
        }
        
        var iconName: String {
            switch self {
            case .schedule: return "clock.fill"
            case .environment: return "house.fill"
            case .feeding: return "drop.fill"
            case .health: return "heart.fill"
            case .routine: return "moon.fill"
            }
        }
        
        var colorName: String {
            switch self {
            case .schedule: return "blue"
            case .environment: return "green"
            case .feeding: return "orange"
            case .health: return "red"
            case .routine: return "purple"
            }
        }
    }
    
    struct RecommendationAction {
        let title: String
        let handler: () -> Void
    }
    
    struct RecommendationCondition {
        let check: (ChildProfile, [SleepSession]) -> Bool
    }
}

// MARK: - SleepRecommendationService
final class SleepRecommendationService: ObservableObject {
    static let shared = SleepRecommendationService()
    
    @Published var recommendations: [SleepRecommendation] = []
    @Published var dailyTip: String = ""
    
    private let sleepService: SleepTrackingService
    private let childService: ChildProfileService
    private let calendar = Calendar.current
    private let tips: [String]
    
    private init() {
        self.sleepService = SleepTrackingService.shared
        self.childService = ChildProfileService.shared
        
        // Инициализируем список советов
        self.tips = [
            "Температура в комнате должна быть 18-22°C",
            "Используйте спальный мешок вместо одеяла",
            "Проветривайте комнату перед сном",
            "Избегайте активных игр за час до сна",
            "Соблюдайте ритуал укладывания",
            "Дневной свет помогает настроить биоритмы",
            "Кормление перед сном улучшает засыпание",
            "Регулярное время отхода ко сну важно для режима",
            "Темнота в комнате способствует выработке мелатонина",
            "Белый шум помогает маскировать внешние звуки",
            "Купание перед сном расслабляет малыша",
            "Массаж помогает улучшить качество сна",
            "Избегайте экранов за 2 часа до сна",
            "Убедитесь, что подгузник сухой перед сном",
            "Комфортная одежда для сна важна",
            "Положение на спине - самое безопасное для сна",
            "Не перегревайте комнату",
            "Влажность воздуха должна быть 40-60%",
            "Проверьте, не режутся ли зубки",
            "При коликах поможет теплая пеленка на животик"
        ]
        
        // Устанавливаем первый совет дня
        setDailyTip()
        
        // Загружаем начальные рекомендации
        loadInitialRecommendations()
    }
    
    // MARK: - Public Methods
    
    func refreshRecommendations() {
        guard let child = childService.activeChild else {
            recommendations = getGeneralRecommendations()
            return
        }
        
        sleepService.getSleepSessions(for: child.id) { [weak self] sessions in
            guard let self = self else { return }
            
            let newRecommendations = self.generateRecommendations(for: child, sessions: sessions)
            DispatchQueue.main.async {
                self.recommendations = newRecommendations
            }
        }
    }
    
    func getRecommendations(for child: ChildProfile, completion: @escaping ([SleepRecommendation]) -> Void) {
        sleepService.getSleepSessions(for: child.id) { [weak self] sessions in
            guard let self = self else {
                completion([])
                return
            }
            
            let recommendations = self.generateRecommendations(for: child, sessions: sessions)
            completion(recommendations)
        }
    }
    
    func getDailyTip(for child: ChildProfile? = nil) -> String {
        if let child = child {
            return getPersonalizedTip(for: child)
        }
        return dailyTip
    }
    
    func markRecommendationAsRead(_ recommendation: SleepRecommendation) {
        // Сохраняем в UserDefaults, что рекомендация прочитана
        var readRecommendations = UserDefaults.standard.stringArray(forKey: "read_recommendations") ?? []
        readRecommendations.append(recommendation.id.uuidString)
        UserDefaults.standard.set(readRecommendations, forKey: "read_recommendations")
        
        // Убираем из списка
        recommendations.removeAll { $0.id == recommendation.id }
    }
    
    // MARK: - Private Methods
    
    private func loadInitialRecommendations() {
        recommendations = getGeneralRecommendations()
    }
    
    private func setDailyTip() {
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let tipIndex = dayOfYear % tips.count
        dailyTip = tips[tipIndex]
    }
    
    private func getPersonalizedTip(for child: ChildProfile) -> String {
        let ageInMonths = child.ageInMonths
        
        if ageInMonths < 3 {
            return "Новорожденным важно кормление по требованию и контакт кожа-к-коже"
        } else if ageInMonths < 6 {
            return "В 3-6 месяцев формируется режим сна. Старайтесь укладывать в одно время"
        } else if ageInMonths < 12 {
            return "После 6 месяцев вводите ритуал укладывания: купание, книга, колыбельная"
        } else {
            return "После года можно переходить на один дневной сон после обеда"
        }
    }
    
    private func getGeneralRecommendations() -> [SleepRecommendation] {
        return [
            SleepRecommendation(
                id: UUID(),
                title: "Начните отслеживать сон",
                description: "Ведите дневник сна, чтобы понимать паттерны и улучшать режим",
                category: .schedule,
                priority: .medium,
                action: nil,
                conditions: []
            ),
            SleepRecommendation(
                id: UUID(),
                title: "Создайте уютную атмосферу",
                description: "Подготовьте комнату ко сну: приглушите свет, проветрите, включите белый шум",
                category: .environment,
                priority: .medium,
                action: SleepRecommendation.RecommendationAction(
                    title: "Включить белый шум",
                    handler: {
                        QuickActionsService.shared.performQuickAction(.whiteNoise) { _ in }
                    }
                ),
                conditions: []
            )
        ]
    }
    
    private func generateRecommendations(for child: ChildProfile, sessions: [SleepSession]) -> [SleepRecommendation] {
        var recommendations: [SleepRecommendation] = []
        
        // Рекомендации по возрасту
        recommendations.append(contentsOf: getAgeBasedRecommendations(for: child))
        
        // Рекомендации по расписанию
        recommendations.append(contentsOf: getScheduleRecommendations(for: child, sessions: sessions))
        
        // Рекомендации по качеству сна
        recommendations.append(contentsOf: getSleepQualityRecommendations(for: child, sessions: sessions))
        
        // Фильтруем уже прочитанные рекомендации
        let readRecommendations = UserDefaults.standard.stringArray(forKey: "read_recommendations") ?? []
        recommendations = recommendations.filter { recommendation in
            !readRecommendations.contains(recommendation.id.uuidString)
        }
        
        // Сортируем по приоритету
        return recommendations.sorted { $0.priority > $1.priority }
    }
    
    // MARK: - Возрастные рекомендации
    
    private func getAgeBasedRecommendations(for child: ChildProfile) -> [SleepRecommendation] {
        let ageInMonths = child.ageInMonths
        var recommendations: [SleepRecommendation] = []
        
        // Новорожденные (0-3 месяца)
        if ageInMonths <= 3 {
            recommendations.append(SleepRecommendation(
                id: UUID(),
                title: "Кормление по требованию",
                description: "Новорожденные просыпаются каждые 2-3 часа для кормления. Это нормально и полезно для установления лактации.",
                category: .feeding,
                priority: .high,
                action: nil,
                conditions: []
            ))
            
            recommendations.append(SleepRecommendation(
                id: UUID(),
                title: "Белый шум для успокоения",
                description: "Используйте белый шум для воссоздания условий матки. Это помогает малышам быстрее засыпать и лучше спать.",
                category: .environment,
                priority: .medium,
                action: SleepRecommendation.RecommendationAction(
                    title: "Включить белый шум",
                    handler: {
                        QuickActionsService.shared.performQuickAction(.whiteNoise) { _ in }
                    }
                ),
                conditions: []
            ))
            
            recommendations.append(SleepRecommendation(
                id: UUID(),
                title: "Контакта кожа-к-коже",
                description: "Практикуйте контакт кожа-к-коже перед сном. Это успокаивает ребенка и регулирует его температуру и дыхание.",
                category: .health,
                priority: .medium,
                action: nil,
                conditions: []
            ))
        }
        
        // 4-6 месяцев
        if ageInMonths >= 4 && ageInMonths <= 6 {
            recommendations.append(SleepRecommendation(
                id: UUID(),
                title: "Оптимальное время укладывания",
                description: "Идеальное время укладывания на ночь: 18:30-19:30. В этом возрасте формируются циркадные ритмы.",
                category: .schedule,
                priority: .high,
                action: nil,
                conditions: []
            ))
            
            recommendations.append(SleepRecommendation(
                id: UUID(),
                title: "Создайте ритуал перед сном",
                description: "Последовательность действий помогает настроить на сон: купание, массаж, книга, колыбельная.",
                category: .routine,
                priority: .medium,
                action: SleepRecommendation.RecommendationAction(
                    title: "Включить колыбельную",
                    handler: {
                        QuickActionsService.shared.performQuickAction(.lullaby) { _ in }
                    }
                ),
                conditions: []
            ))
            
            recommendations.append(SleepRecommendation(
                id: UUID(),
                title: "Режим дневного сна",
                description: "В этом возрасте обычно 3-4 дневных сна. Следите за признаками усталости: зевание, потирание глаз.",
                category: .schedule,
                priority: .medium,
                action: nil,
                conditions: []
            ))
        }
        
        // 7-12 месяцев
        if ageInMonths >= 7 && ageInMonths <= 12 {
            recommendations.append(SleepRecommendation(
                id: UUID(),
                title: "Два дневных сна",
                description: "В этом возрасте переходите на 2 дневных сна: утренний (9-10) и послеобеденный (13-15).",
                category: .schedule,
                priority: .high,
                action: nil,
                conditions: []
            ))
            
            recommendations.append(SleepRecommendation(
                id: UUID(),
                title: "Самостоятельное засыпание",
                description: "Постепенно учите засыпать самостоятельно. Можно использовать метод 'посидеть рядом'.",
                category: .routine,
                priority: .medium,
                action: nil,
                conditions: []
            ))
            
            recommendations.append(SleepRecommendation(
                id: UUID(),
                title: "Вечерняя рутина",
                description: "Ужин, спокойные игры, купание, книга, колыбельная. Последовательность важна для настроя на сон.",
                category: .routine,
                priority: .medium,
                action: nil,
                conditions: []
            ))
        }
        
        // После года
        if ageInMonths > 12 {
            recommendations.append(SleepRecommendation(
                id: UUID(),
                title: "Переход на один дневной сон",
                description: "Малыш готов перейти на один дневной сон после обеда (примерно с 13 до 15 часов).",
                category: .schedule,
                priority: .medium,
                action: nil,
                conditions: []
            ))
            
            recommendations.append(SleepRecommendation(
                id: UUID(),
                title: "Расширение вечерней рутины",
                description: "Добавьте больше элементов: чистка зубов, выбор пижамы, разговор о прошедшем дне.",
                category: .routine,
                priority: .low,
                action: nil,
                conditions: []
            ))
            
            recommendations.append(SleepRecommendation(
                id: UUID(),
                title: "Сон без ассоциаций",
                description: "Постепенно убирайте ассоциации на засыпание (укачивание, грудь). Дайте возможность заснуть самому.",
                category: .routine,
                priority: .medium,
                action: nil,
                conditions: []
            ))
        }
        
        return recommendations
    }
    
    // MARK: - Рекомендации по расписанию
    
    private func getScheduleRecommendations(for child: ChildProfile, sessions: [SleepSession]) -> [SleepRecommendation] {
        var recommendations: [SleepRecommendation] = []
        let ageInMonths = child.ageInMonths
        
        // Анализируем последние 7 дней
        let lastWeekSessions = sessions.filter { session in
            guard let endDate = session.endDate else { return false }
            return calendar.dateComponents([.day], from: endDate, to: Date()).day ?? 7 <= 7
        }
        
        guard !lastWeekSessions.isEmpty else { return recommendations }
        
        // Проверяем общую продолжительность сна
        let totalSleep = lastWeekSessions.reduce(0) { $0 + $1.duration }
        let averageSleepPerDay = totalSleep / 7
        
        let recommendedSleep = getRecommendedSleep(for: ageInMonths)
        
        if averageSleepPerDay < recommendedSleep.min {
            recommendations.append(SleepRecommendation(
                id: UUID(),
                title: "Недостаток сна",
                description: String(format: "Малыш спит в среднем %.1f часов в день, что меньше рекомендованных %.1f-%.1f часов для этого возраста.",
                                  averageSleepPerDay / 3600,
                                  recommendedSleep.min / 3600,
                                  recommendedSleep.max / 3600),
                category: .health,
                priority: .high,
                action: nil,
                conditions: []
            ))
        } else if averageSleepPerDay > recommendedSleep.max {
            recommendations.append(SleepRecommendation(
                id: UUID(),
                title: "Избыток сна",
                description: String(format: "Малыш спит в среднем %.1f часов в день, что больше рекомендованных %.1f-%.1f часов.",
                                  averageSleepPerDay / 3600,
                                  recommendedSleep.min / 3600,
                                  recommendedSleep.max / 3600),
                category: .health,
                priority: .medium,
                action: nil,
                conditions: []
            ))
        }
        
        // Проверяем время утреннего пробуждения
        let wakeUpTimes = lastWeekSessions.compactMap { $0.endDate }
        if let averageWakeUpTime = getAverageTime(from: wakeUpTimes) {
            let components = calendar.dateComponents([.hour, .minute], from: averageWakeUpTime)
            
            if let hour = components.hour, hour < 6 {
                recommendations.append(SleepRecommendation(
                    id: UUID(),
                    title: "Раннее пробуждение",
                    description: "Малыш просыпается в среднем в \(String(format: "%02d:%02d", hour, components.minute ?? 0)). Попробуйте затемнить комнату или сдвинуть время укладывания.",
                    category: .schedule,
                    priority: .medium,
                    action: nil,
                    conditions: []
                ))
            }
        }
        
        // Проверяем регулярность укладывания
        let bedTimes = lastWeekSessions.map { $0.startDate }
        if let bedTimeVariability = calculateTimeVariability(times: bedTimes), bedTimeVariability > 2 {
            recommendations.append(SleepRecommendation(
                id: UUID(),
                title: "Нерегулярное укладывание",
                description: "Время отхода ко сну сильно варьируется. Постарайтесь укладывать ребенка в одно и то же время (±30 минут).",
                category: .schedule,
                priority: .medium,
                action: nil,
                conditions: []
            ))
        }
        
        return recommendations
    }
    
    // MARK: - Рекомендации по качеству сна
    
    private func getSleepQualityRecommendations(for child: ChildProfile, sessions: [SleepSession]) -> [SleepRecommendation] {
        var recommendations: [SleepRecommendation] = []
        
        guard !sessions.isEmpty else { return recommendations }
        
        // Анализируем ночные пробуждения
        let nightSessions = sessions.filter { session in
            guard let startDate = session.startDate,
                  let endDate = session.endDate else { return false }
            
            let startHour = calendar.component(.hour, from: startDate)
            let endHour = calendar.component(.hour, from: endDate)
            
            // Ночное время: 20:00 - 6:00
            return (startHour >= 20 || startHour <= 6) && (endHour >= 20 || endHour <= 6)
        }
        
        if nightSessions.count > 0 {
            let averageAwakenings = Double(nightSessions.count) / Double(sessions.count)
            
            if averageAwakenings > 2 {
                recommendations.append(SleepRecommendation(
                    id: UUID(),
                    title: "Частые ночные пробуждения",
                    description: "Малыш просыпается в среднем \(String(format: "%.1f", averageAwakenings)) раз за ночь. Это может быть связано с голодом, дискомфортом или привычкой.",
                    category: .health,
                    priority: .medium,
                    action: SleepRecommendation.RecommendationAction(
                        title: "Включить успокаивающий звук",
                        handler: {
                            QuickActionsService.shared.performQuickAction(.heartbeat) { _ in }
                        }
                    ),
                    conditions: []
                ))
            }
        }
        
        // Анализируем качество сна
        let poorSleepSessions = sessions.filter { $0.quality == .poor }
        if Double(poorSleepSessions.count) / Double(sessions.count) > 0.3 {
            recommendations.append(SleepRecommendation(
                id: UUID(),
                title: "Низкое качество сна",
                description: "Более 30% снов оценены как плохие. Обратите внимание на условия сна и самочувствие ребенка.",
                category: .health,
                priority: .high,
                action: nil,
                conditions: []
            ))
        }
        
        return recommendations
    }
    
    // MARK: - Вспомогательные методы
    
    private func getRecommendedSleep(for ageInMonths: Int) -> (min: TimeInterval, max: TimeInterval) {
        switch ageInMonths {
        case 0...3: return (14 * 3600, 17 * 3600)   // 14-17 часов
        case 4...11: return (12 * 3600, 16 * 3600)  // 12-16 часов
        case 12...24: return (11 * 3600, 14 * 3600) // 11-14 часов
        case 25...36: return (10 * 3600, 13 * 3600) // 10-13 часов
        default: return (10 * 3600, 12 * 3600)      // 10-12 часов
        }
    }
    
    private func getAverageTime(from dates: [Date]) -> Date? {
        guard !dates.isEmpty else { return nil }
        
        let totalSeconds = dates.reduce(0) { total, date in
            let components = calendar.dateComponents([.hour, .minute, .second], from: date)
            let seconds = (components.hour ?? 0) * 3600 + (components.minute ?? 0) * 60 + (components.second ?? 0)
            return total + seconds
        }
        
        let averageSeconds = totalSeconds / dates.count
        let hour = averageSeconds / 3600
        let minute = (averageSeconds % 3600) / 60
        
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date())
    }
    
    private func calculateTimeVariability(times: [Date]) -> Double? {
        guard times.count > 1 else { return nil }
        
        let timesInMinutes = times.map { date in
            let components = calendar.dateComponents([.hour, .minute], from: date)
            return Double((components.hour ?? 0) * 60 + (components.minute ?? 0))
        }
        
        let average = timesInMinutes.reduce(0, +) / Double(timesInMinutes.count)
        let variance = timesInMinutes.map { pow($0 - average, 2) }.reduce(0, +) / Double(timesInMinutes.count)
        
        return sqrt(variance) // стандартное отклонение в минутах
    }
}

// MARK: - QuickActionsService заглушка для компиляции
class QuickActionsService {
    static let shared = QuickActionsService()
    
    enum ActionType {
        case whiteNoise, heartbeat, lullaby
    }
    
    func performQuickAction(_ action: ActionType, completion: @escaping (Bool) -> Void) {
        completion(true)
    }
}
