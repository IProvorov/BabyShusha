// Services/DataStorageService.swift
import Foundation

class DataStorageService {
    static let shared = DataStorageService()
    
    private let userDefaults = UserDefaults.standard
    private let sleepSessionsKey = "sleep_sessions"
    private let childProfilesKey = "child_profiles"
    private let activeChildIdKey = "active_child_id"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Child Profiles
    
    func saveChildProfile(_ profile: ChildProfile) {
        var profiles = loadChildProfiles()
        
        // Если профиль уже существует, обновляем его
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index] = profile
        } else {
            // Иначе добавляем новый
            profiles.append(profile)
        }
        
        saveChildProfiles(profiles)
    }
    
    func loadChildProfiles() -> [ChildProfile] {
        guard let data = userDefaults.data(forKey: childProfilesKey) else {
            return []
        }
        
        do {
            return try decoder.decode([ChildProfile].self, from: data)
        } catch {
            print("Error decoding child profiles: \(error)")
            return []
        }
    }
    
    func deleteChildProfile(_ profile: ChildProfile) {
        var profiles = loadChildProfiles()
        profiles.removeAll { $0.id == profile.id }
        saveChildProfiles(profiles)
        
        // Если удаляем активного ребенка, сбрасываем активный ID
        if getActiveChildId() == profile.id {
            clearActiveChildProfile()
        }
    }
    
    func getActiveChildProfile() -> ChildProfile? {
        guard let activeId = getActiveChildId() else {
            return nil
        }
        
        let profiles = loadChildProfiles()
        return profiles.first { $0.id == activeId }
    }
    
    func setActiveChildProfile(_ profile: ChildProfile) {
        setActiveChildId(profile.id)
    }
    
    func clearActiveChildProfile() {
        userDefaults.removeObject(forKey: activeChildIdKey)
    }
    
    private func saveChildProfiles(_ profiles: [ChildProfile]) {
        do {
            let data = try encoder.encode(profiles)
            userDefaults.set(data, forKey: childProfilesKey)
        } catch {
            print("Error encoding child profiles: \(error)")
        }
    }
    
    private func getActiveChildId() -> UUID? {
        guard let uuidString = userDefaults.string(forKey: activeChildIdKey) else {
            return nil
        }
        return UUID(uuidString: uuidString)
    }
    
    private func setActiveChildId(_ id: UUID) {
        userDefaults.set(id.uuidString, forKey: activeChildIdKey)
    }
    
    // MARK: - Sleep Sessions
    
    func saveSleepSession(_ session: SleepSession) {
        var sessions = loadSleepSessions()
        sessions.append(session)
        saveSleepSessions(sessions)
    }
    
    func loadSleepSessions() -> [SleepSession] {
        guard let data = userDefaults.data(forKey: sleepSessionsKey) else {
            return []
        }
        
        do {
            return try decoder.decode([SleepSession].self, from: data)
        } catch {
            print("Error decoding sleep sessions: \(error)")
            return []
        }
    }
    
    // Загрузка сессий конкретного ребенка
    func loadSleepSessions(for childId: UUID) -> [SleepSession] {
        let allSessions = loadSleepSessions()
        return allSessions.filter { $0.childId == childId }
    }
    
    func deleteSleepSession(_ session: SleepSession) {
        var sessions = loadSleepSessions()
        sessions.removeAll { $0.id == session.id }
        saveSleepSessions(sessions)
    }
    
    // Удаление всех сессий ребенка
    func deleteAllSessions(for childId: UUID) {
        var sessions = loadSleepSessions()
        sessions.removeAll { $0.childId == childId }
        saveSleepSessions(sessions)
    }
    
    private func saveSleepSessions(_ sessions: [SleepSession]) {
        do {
            let data = try encoder.encode(sessions)
            userDefaults.set(data, forKey: sleepSessionsKey)
        } catch {
            print("Error encoding sleep sessions: \(error)")
        }
    }
    
    // MARK: - Statistics
    
    func getSleepSessions(for period: TimeInterval) -> [SleepSession] {
        let sessions = loadSleepSessions()
        let cutoffDate = Date().addingTimeInterval(-period)
        
        return sessions.filter { $0.endTime > cutoffDate }
    }
    
    // Сессии за период для конкретного ребенка
    func getSleepSessions(for period: TimeInterval, childId: UUID) -> [SleepSession] {
        let sessions = loadSleepSessions(for: childId)
        let cutoffDate = Date().addingTimeInterval(-period)
        
        return sessions.filter { $0.endTime > cutoffDate }
    }
    
    func getWeeklyStatistics() -> SleepStatistics {
        let weekInSeconds: TimeInterval = 7 * 24 * 60 * 60
        let sessions = getSleepSessions(for: weekInSeconds)
        
        return SleepStatistics(period: "week", sessions: sessions)
    }
    
    // Статистика за неделю для конкретного ребенка
    func getWeeklyStatistics(for childId: UUID) -> SleepStatistics {
        let weekInSeconds: TimeInterval = 7 * 24 * 60 * 60
        let sessions = getSleepSessions(for: weekInSeconds, childId: childId)
        
        return SleepStatistics(period: "week", sessions: sessions)
    }
    
    func getMonthlyStatistics() -> SleepStatistics {
        let monthInSeconds: TimeInterval = 30 * 24 * 60 * 60
        let sessions = getSleepSessions(for: monthInSeconds)
        
        return SleepStatistics(period: "month", sessions: sessions)
    }
    
    // Статистика за месяц для конкретного ребенка
    func getMonthlyStatistics(for childId: UUID) -> SleepStatistics {
        let monthInSeconds: TimeInterval = 30 * 24 * 60 * 60
        let sessions = getSleepSessions(for: monthInSeconds, childId: childId)
        
        return SleepStatistics(period: "month", sessions: sessions)
    }
    
    // Общая статистика для ребенка
    func getChildStatistics(_ childId: UUID) -> ChildSleepStatistics {
        let allSessions = loadSleepSessions(for: childId)
        let weeklySessions = getSleepSessions(for: 7 * 24 * 60 * 60, childId: childId)
        let monthlySessions = getSleepSessions(for: 30 * 24 * 60 * 60, childId: childId)
        
        let totalDuration = allSessions.reduce(0) { $0 + $1.duration }
        let weeklyDuration = weeklySessions.reduce(0) { $0 + $1.duration }
        let monthlyDuration = monthlySessions.reduce(0) { $0 + $1.duration }
        
        return ChildSleepStatistics(
            childId: childId,
            totalSessions: allSessions.count,
            totalSleepTime: totalDuration,
            weeklySleepTime: weeklyDuration,
            monthlySleepTime: monthlyDuration,
            averageQuality: calculateAverageQuality(sessions: allSessions),
            favoriteSleepTime: calculateFavoriteSleepTime(sessions: allSessions)
        )
    }
    
    // Статистика по всем детям
    func getAllChildrenStatistics() -> [ChildSleepStatistics] {
        let allSessions = loadSleepSessions()
        
        // Группируем сессии по childId
        let groupedSessions = Dictionary(grouping: allSessions, by: { $0.childId })
        
        // Создаем статистику для каждого ребенка
        return groupedSessions.map { childId, sessions in
            let weeklySessions = sessions.filter {
                $0.endTime > Date().addingTimeInterval(-7 * 24 * 60 * 60)
            }
            let monthlySessions = sessions.filter {
                $0.endTime > Date().addingTimeInterval(-30 * 24 * 60 * 60)
            }
            
            return ChildSleepStatistics(
                childId: childId,
                totalSessions: sessions.count,
                totalSleepTime: sessions.reduce(0) { $0 + $1.duration },
                weeklySleepTime: weeklySessions.reduce(0) { $0 + $1.duration },
                monthlySleepTime: monthlySessions.reduce(0) { $0 + $1.duration },
                averageQuality: calculateAverageQuality(sessions: sessions),
                favoriteSleepTime: calculateFavoriteSleepTime(sessions: sessions)
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func calculateAverageQuality(sessions: [SleepSession]) -> Double {
        let sessionsWithQuality = sessions.filter { $0.quality != nil }
        guard !sessionsWithQuality.isEmpty else { return 0 }
        
        let totalQuality = sessionsWithQuality.reduce(0) { $0 + Double($1.quality ?? 0) }
        return totalQuality / Double(sessionsWithQuality.count)
    }
    
    private func calculateFavoriteSleepTime(sessions: [SleepSession]) -> String {
        guard !sessions.isEmpty else { return "Нет данных" }
        
        // Группируем по часу начала сна
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "HH"
        
        let hourCounts = Dictionary(grouping: sessions) { session in
            hourFormatter.string(from: session.startTime)
        }.mapValues { $0.count }
        
        if let favoriteHour = hourCounts.max(by: { $0.value < $1.value })?.key,
           let hourInt = Int(favoriteHour) {
            return String(format: "%02d:00", hourInt)
        }
        
        return "Нет данных"
    }
    
    // MARK: - Data Management
    
    func clearAllData() {
        userDefaults.removeObject(forKey: sleepSessionsKey)
        userDefaults.removeObject(forKey: childProfilesKey)
        userDefaults.removeObject(forKey: activeChildIdKey)
    }
    
    func exportData() -> Data? {
        let sessions = loadSleepSessions()
        let profiles = loadChildProfiles()
        
        let exportData = ExportData(
            sleepSessions: sessions,
            childProfiles: profiles,
            activeChildId: getActiveChildId()?.uuidString
        )
        
        do {
            return try encoder.encode(exportData)
        } catch {
            print("Error exporting data: \(error)")
            return nil
        }
    }
    
    func importData(_ data: Data) -> Bool {
        do {
            let importData = try decoder.decode(ExportData.self, from: data)
            
            // Сохраняем данные
            saveSleepSessions(importData.sleepSessions)
            saveChildProfiles(importData.childProfiles)
            
            // Восстанавливаем активного ребенка
            if let activeChildIdString = importData.activeChildId,
               let activeChildId = UUID(uuidString: activeChildIdString) {
                setActiveChildId(activeChildId)
            }
            
            return true
        } catch {
            print("Error importing data: \(error)")
            return false
        }
    }
}

// MARK: - Supporting Structures

// Структура для экспорта/импорта данных
struct ExportData: Codable {
    let sleepSessions: [SleepSession]
    let childProfiles: [ChildProfile]
    let activeChildId: String?
}



// Статистика по ребенку
struct ChildSleepStatistics {
    let childId: UUID
    let totalSessions: Int
    let totalSleepTime: TimeInterval
    let weeklySleepTime: TimeInterval
    let monthlySleepTime: TimeInterval
    let averageQuality: Double
    let favoriteSleepTime: String
    
    var totalSleepFormatted: String {
        let hours = Int(totalSleepTime) / 3600
        let minutes = (Int(totalSleepTime) % 3600) / 60
        return "\(hours)ч \(minutes)м"
    }
    
    var weeklySleepFormatted: String {
        let hours = Int(weeklySleepTime) / 3600
        let minutes = (Int(weeklySleepTime) % 3600) / 60
        return "\(hours)ч \(minutes)м"
    }
    
    var monthlySleepFormatted: String {
        let hours = Int(monthlySleepTime) / 3600
        let minutes = (Int(monthlySleepTime) % 3600) / 60
        return "\(hours)ч \(minutes)м"
    }
    
    var averageQualityFormatted: String {
        return String(format: "%.1f", averageQuality)
    }
}
