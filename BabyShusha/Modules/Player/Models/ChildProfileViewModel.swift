import Foundation
import SwiftUI
import Combine

@MainActor
class ChildProfileViewModel: ObservableObject {
    @Published var children: [ChildProfile] = []
    @Published var activeChild: ChildProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var childrenStatistics: [UUID: ChildSleepStatistics] = [:] // Статистика для каждого ребенка
    
    private let storageService = DataStorageService.shared
    
    init() {
        loadChildren()
        loadChildrenStatistics()
    }
    
    // MARK: - Data Loading
    
    func loadChildren() {
        isLoading = true
        children = storageService.loadChildProfiles()
        activeChild = storageService.getActiveChildProfile()
        isLoading = false
        
        // После загрузки детей загружаем статистику
        loadChildrenStatistics()
    }
    
    func loadChildrenStatistics() {
        // Загружаем статистику для всех детей
        let stats = storageService.getAllChildrenStatistics()
        childrenStatistics = Dictionary(uniqueKeysWithValues: stats.map { ($0.childId, $0) })
    }
    
    // MARK: - Child Management
    
    func addChild(name: String, birthDate: Date, avatarEmoji: String = "👶") {
        let newChild = ChildProfile(
            name: name,
            birthDate: birthDate,
            avatarEmoji: avatarEmoji
        )
        
        storageService.saveChildProfile(newChild)
        setActiveChild(newChild)
        loadChildren()
    }
    
    func updateChild(_ child: ChildProfile) {
        storageService.saveChildProfile(child)
        
        // Если обновляем активного ребенка, обновляем его
        if child.id == activeChild?.id {
            activeChild = child
        }
        
        loadChildren()
    }
    
    func deleteChild(_ child: ChildProfile) {
        // Удаляем профиль ребенка
        storageService.deleteChildProfile(child)
        
        // Удаляем все сессии сна этого ребенка
        storageService.deleteAllSessions(for: child.id)
        
        // Удаляем статистику
        childrenStatistics.removeValue(forKey: child.id)
        
        // Если удаляем активного ребенка, выбираем другого
        if child.id == activeChild?.id {
            if let firstChild = children.first(where: { $0.id != child.id }) {
                setActiveChild(firstChild)
            } else {
                activeChild = nil
                storageService.clearActiveChildProfile()
            }
        }
        
        loadChildren()
    }
    
    func setActiveChild(_ child: ChildProfile) {
        storageService.setActiveChildProfile(child)
        activeChild = child
        objectWillChange.send()
        
        // Оповещаем другие ViewModel об изменении активного ребенка
        NotificationCenter.default.post(
            name: Notification.Name("ActiveChildChanged"),
            object: nil,
            userInfo: ["childId": child.id]
        )
    }
    
    // MARK: - Statistics
    
    func getChildStatistics(_ childId: UUID) -> ChildSleepStatistics? {
        // Используем кэшированную статистику или загружаем новую
        if let cachedStats = childrenStatistics[childId] {
            return cachedStats
        }
        
        let stats = storageService.getChildStatistics(childId)
        childrenStatistics[childId] = stats
        return stats
    }
    
    func getWeeklyStatistics(for childId: UUID) -> SleepStatistics? {
        // Получаем недельную статистику
        return storageService.getWeeklyStatistics(for: childId)
    }
    
    func getMonthlyStatistics(for childId: UUID) -> SleepStatistics? {
        // Получаем месячную статистику
        return storageService.getMonthlyStatistics(for: childId)
    }
    
    // MARK: - Age Calculation
    
    func calculateAge(for child: ChildProfile) -> (years: Int, months: Int) {
        let calendar = Calendar.current
        let now = Date()
        let birthDate = child.birthDate
        
        let ageComponents = calendar.dateComponents([.year, .month], from: birthDate, to: now)
        let years = ageComponents.year ?? 0
        let months = ageComponents.month ?? 0
        
        return (years, months)
    }
    
    func ageDescription(for child: ChildProfile) -> String {
        let age = calculateAge(for: child)
        
        if age.years == 0 {
            return "\(age.months) мес"
        } else if age.months == 0 {
            return "\(age.years) год"
        } else {
            return "\(age.years) год \(age.months) мес"
        }
    }
    
    // MARK: - Validation
    
    func validateChildName(_ name: String) -> Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func isNameAvailable(_ name: String, excluding childId: UUID? = nil) -> Bool {
        let filteredChildren = children.filter {
            if let excludingId = childId {
                return $0.id != excludingId
            }
            return true
        }
        
        return !filteredChildren.contains { $0.name.lowercased() == name.lowercased() }
    }
    
    // MARK: - Sleep Session Management
    
    func getSleepSessions(for childId: UUID, limit: Int? = nil) -> [SleepSession] {
        var sessions = storageService.loadSleepSessions(for: childId)
            .sorted { $0.startTime > $1.startTime }
        
        if let limit = limit {
            sessions = Array(sessions.prefix(limit))
        }
        
        return sessions
    }
    
    func deleteSleepSession(_ session: SleepSession) {
        storageService.deleteSleepSession(session)
        
        // Обновляем статистику после удаления
        let childId = session.childId
        
        // getChildStatistics возвращает ChildSleepStatistics, а не ChildSleepStatistics?
        let updatedStats = storageService.getChildStatistics(childId)
        childrenStatistics[childId] = updatedStats
    }
    
    // MARK: - Recommendations
    
    func getSleepRecommendation(for child: ChildProfile) -> String {
        let age = calculateAge(for: child)
        let stats = getChildStatistics(child.id)
        
        var recommendations: [String] = []
        
        // Рекомендации по возрасту
        if age.years == 0 { // Младенец
            if age.months < 3 {
                recommendations.append("Новорожденным нужно 14-17 часов сна в сутки")
            } else if age.months < 12 {
                recommendations.append("Младенцам нужно 12-16 часов сна в сутки")
            }
        } else if age.years < 3 {
            recommendations.append("Малышам нужно 11-14 часов сна в сутки")
        } else if age.years < 6 {
            recommendations.append("Дошкольникам нужно 10-13 часов сна в сутки")
        } else if age.years < 13 {
            recommendations.append("Школьникам нужно 9-11 часов сна в сутки")
        }
        
        // Рекомендации по статистике
        if let stats = stats {
            let dailyAverage = stats.weeklySleepTime / 7.0
            let hoursPerDay = dailyAverage / 3600
            
            if hoursPerDay < 8 {
                recommendations.append("Увеличьте продолжительность сна на \(String(format: "%.1f", 9 - hoursPerDay)) часов в день")
            }
            
            if stats.averageQuality < 5 {
                recommendations.append("Попробуйте установить регулярное время отхода ко сну")
            }
        }
        
        return recommendations.isEmpty ?
            "Сон соответствует возрастным нормам" :
            recommendations.joined(separator: "\n\n")
    }
    
    // MARK: - Quick Actions
    
    func quickAddSleepSession(for childId: UUID, duration: TimeInterval) {
        let session = SleepSession(
            childId: childId,
            startTime: Date().addingTimeInterval(-duration),
            endTime: Date(),
            quality: nil,
            notes: "Быстрое добавление",
            mood: nil
        )
        
        storageService.saveSleepSession(session)
        
        // Обновляем статистику
        let updatedStats = storageService.getChildStatistics(childId)
        childrenStatistics[childId] = updatedStats
    }
}
