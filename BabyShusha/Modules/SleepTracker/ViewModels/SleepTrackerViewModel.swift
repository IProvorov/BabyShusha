// Modules/SleepTracker/ViewModels/SleepTrackerViewModel.swift
import Foundation
import SwiftUI
import Combine

class SleepTrackerViewModel: ObservableObject {
    @Published var isTracking = false
    @Published var currentSession: CurrentSleepSession?
    @Published var sleepHistory: [SleepSession] = []
    @Published var weeklyStats: SleepStatistics?
    @Published var isLoading = false
    @Published var selectedChildId: UUID? // Добавляем свойство для хранения выбранного ребенка
    
    private var timer: Timer?
    private let storageService = DataStorageService.shared
    
    // Вычисляемые свойства
    var elapsedTime: String {
        guard let startTime = currentSession?.startTime else { return "00:00:00" }
        let duration = Date().timeIntervalSince(startTime)
        return formatDuration(duration)
    }
    
    var startTimeFormatted: String {
        guard let startTime = currentSession?.startTime else { return "--:--" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: startTime)
    }
    
    var weeklyGoalProgress: Int {
        guard let stats = weeklyStats else { return 0 }
        let goalHours: TimeInterval = 56 * 3600 // 56 часов в неделю
        let progress = Int((stats.totalSleepTime / goalHours) * 100)
        return min(progress, 100) // Ограничиваем максимум 100%
    }
    
    var weeklyTotalHours: String {
        guard let stats = weeklyStats else { return "0ч 0м" }
        return stats.totalSleepFormatted
    }
    
    // Инициализация
    init() {
        loadSleepHistory()
        loadWeeklyStats()
        // Можно загрузить сохраненный childId из UserDefaults
        // loadSelectedChildId()
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
        // Проверяем, что выбран ребенок
        guard let childId = selectedChildId else {
            print("Ошибка: не выбран ребенок для отслеживания сна")
            // Можно добавить алерт или логику выбора ребенка
            return
        }
        
        currentSession = CurrentSleepSession(
            childId: childId, // Используем выбранный childId
            startTime: Date()
        )
        isTracking = true
        startTimer()
    }
    
    func stopTracking() {
        guard let session = currentSession else { return }
        
        // Создаем завершенную сессию
        let completedSession = SleepSession(
            childId: session.childId, // Берем childId из текущей сессии
            startTime: session.startTime,
            endTime: Date(),
            quality: session.quality,
            notes: session.notes,
            mood: session.mood
        )
        
        // Сохраняем
        storageService.saveSleepSession(completedSession)
        
        // Сбрасываем текущую сессию
        currentSession = nil
        isTracking = false
        stopTimer()
        
        // Обновляем данные
        loadSleepHistory()
        loadWeeklyStats()
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Data Management (делаем публичными)
    
    func loadSleepHistory() {
        isLoading = true
        
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
        
        isLoading = false
    }
    
    func loadWeeklyStats() {
        if let childId = selectedChildId {
            // ФИЛЬТРУЕМ ВРУЧНУЮ, так как метода getWeeklyStatistics(for:) нет
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            let allSessions = storageService.loadSleepSessions()
            
            // Фильтруем: 1) сессии за неделю, 2) только для выбранного ребенка
            let childWeeklySessions = allSessions.filter {
                session in
                session.endTime > weekAgo && session.childId == childId
            }
            
            weeklyStats = SleepStatistics(period: "week", sessions: childWeeklySessions)
        } else {
            // Если ребенок не выбран, используем существующий метод
            weeklyStats = storageService.getWeeklyStatistics()
        }
    }
    
    func deleteSession(_ session: SleepSession) {
        storageService.deleteSleepSession(session)
        loadSleepHistory()
        loadWeeklyStats()
    }
    
    func updateCurrentSession(quality: Int? = nil, notes: String? = nil, mood: String? = nil) {
        currentSession?.quality = quality
        currentSession?.notes = notes
        currentSession?.mood = mood
    }
    
    // MARK: - Child Selection Methods
    
    func setSelectedChild(_ childId: UUID) {
        selectedChildId = childId
        // Можно сохранить в UserDefaults
        // UserDefaults.standard.set(childId.uuidString, forKey: "selectedChildId")
        
        // Обновляем данные для выбранного ребенка
        loadSleepHistory()
        loadWeeklyStats()
    }
    
    func clearSelectedChild() {
        selectedChildId = nil
        // UserDefaults.standard.removeObject(forKey: "selectedChildId")
        
        // Обновляем данные (покажем все сессии)
        loadSleepHistory()
        loadWeeklyStats()
    }
    
    private func loadSelectedChildId() {
        // Загрузка сохраненного childId из UserDefaults
        // if let uuidString = UserDefaults.standard.string(forKey: "selectedChildId"),
        //    let uuid = UUID(uuidString: uuidString) {
        //    selectedChildId = uuid
        // }
    }
    
    // MARK: - Helper Methods
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    // MARK: - Deinitialization
    
    deinit {
        stopTimer()
    }
}

// MARK: - Текущая активная сессия
struct CurrentSleepSession {
    let id = UUID()
    let childId: UUID
    let startTime: Date
    var quality: Int?
    var notes: String?
    var mood: String?
    
    init(childId: UUID, startTime: Date, quality: Int? = nil, notes: String? = nil, mood: String? = nil) {
        self.childId = childId
        self.startTime = startTime
        self.quality = quality
        self.notes = notes
        self.mood = mood
    }
}
