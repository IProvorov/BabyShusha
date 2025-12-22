import Foundation
import SwiftUI
import Combine

@MainActor
class SleepTrackerViewModel: ObservableObject {
    @Published var isTracking = false
    @Published var currentSession: CurrentSleepSession?
    @Published var sleepHistory: [SleepSession] = []
    @Published var weeklyStats: SleepStatistics?
    @Published var selectedChildId: UUID?
    
    private let storageService = DataStorageService.shared
    
    // Вычисляемые свойства
    var elapsedTime: String {
        guard let startTime = currentSession?.startTime else { return "00:00" }
        let duration = Date().timeIntervalSince(startTime)
        return formatDuration(duration)
    }
    
    // Инициализация
    init() {
        loadSleepHistory()
        loadWeeklyStats()
    }
    
    // MARK: - Sleep Tracking
    
    func toggleTracking() {
        if isTracking {
            stopTracking()
        } else {
            startTracking()
        }
    }
    
    private func startTracking() {
        guard let childId = selectedChildId else {
            print("Ошибка: не выбран ребенок")
            return
        }
        
        currentSession = CurrentSleepSession(childId: childId)
        isTracking = true
    }
    
    func stopTracking() {
        guard let session = currentSession else { return }
        
        let completedSession = SleepSession(
            childId: session.childId,
            startTime: session.startTime,
            endTime: Date(),
            quality: session.quality,
            notes: session.notes,
            mood: session.mood
        )
        
        storageService.saveSleepSession(completedSession)
        currentSession = nil
        isTracking = false
        
        loadSleepHistory()
        loadWeeklyStats()
    }
    
    // MARK: - Data Loading
    
    func loadSleepHistory() {
        let allSessions = storageService.loadSleepSessions()
        
        if let childId = selectedChildId {
            sleepHistory = allSessions
                .filter { $0.childId == childId }
                .sorted { $0.startTime > $1.startTime }
                .prefix(50)
                .map { $0 }
        } else {
            sleepHistory = allSessions
                .sorted { $0.startTime > $1.startTime }
                .prefix(50)
                .map { $0 }
        }
    }
    
    func loadWeeklyStats() {
        let allSessions = storageService.loadSleepSessions()
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let weeklySessions = allSessions.filter { $0.endTime > weekAgo }
        
        if let childId = selectedChildId {
            let childSessions = weeklySessions.filter { $0.childId == childId }
            weeklyStats = SleepStatistics(period: "week", sessions: childSessions)
        } else {
            weeklyStats = SleepStatistics(period: "week", sessions: weeklySessions)
        }
    }
    
    // MARK: - Helper
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
