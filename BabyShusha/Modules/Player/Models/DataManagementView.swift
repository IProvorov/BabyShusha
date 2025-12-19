// Modules/SleepTracker/Views/DataManagementView.swift
import SwiftUI

struct DataManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingExportAlert = false
    @State private var showingClearAlert = false
    @State private var exportData: Data?
    @State private var dataStats = DataStats()
    
    let storageService = DataStorageService.shared
    
    var body: some View {
        NavigationView {
            List {
                Section("Экспорт данных") {
                    Button {
                        exportData = storageService.exportData()
                        showingExportAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                            
                            Text("Экспортировать все данные")
                            
                            Spacer()
                        }
                    }
                    
                    if let data = exportData {
                        ShareLink(
                            item: data,
                            preview: SharePreview("Данные сна.json")
                        ) {
                            HStack {
                                Image(systemName: "doc.fill")
                                    .foregroundColor(.green)
                                
                                Text("Поделиться файлом")
                                
                                Spacer()
                            }
                        }
                    }
                }
                
                Section("Статистика данных") {
                    HStack {
                        Text("Всего записей")
                        Spacer()
                        Text("\(dataStats.totalSessions)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Сон за неделю")
                        Spacer()
                        Text(dataStats.weeklySleep)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Сон за месяц")
                        Spacer()
                        Text(dataStats.monthlySleep)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Очистка данных") {
                    Button(role: .destructive) {
                        showingClearAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Удалить все данные")
                        }
                    }
                }
                
                Section("Информация") {
                    HStack {
                        Text("Версия данных")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Последнее обновление")
                        Spacer()
                        Text(dataStats.lastUpdate)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Управление данными")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
            .alert("Данные экспортированы", isPresented: $showingExportAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Данные готовы к отправке. Нажмите 'Поделиться файлом' для отправки.")
            }
            .alert("Удалить все данные?", isPresented: $showingClearAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Удалить", role: .destructive) {
                    storageService.clearAllData()
                    loadDataStats()
                }
            } message: {
                Text("Это действие невозможно отменить. Все данные о сне будут удалены.")
            }
            .onAppear {
                loadDataStats()
            }
        }
    }
    
    private func loadDataStats() {
        let sessions = storageService.loadSleepSessions()
        let weeklyStats = storageService.getWeeklyStatistics()
        let monthlyStats = storageService.getMonthlyStatistics()
        
        dataStats = DataStats(
            totalSessions: sessions.count,
            weeklySleep: weeklyStats.totalSleepFormatted,
            monthlySleep: monthlyStats.totalSleepFormatted,
            lastUpdate: getLastUpdateDate(sessions: sessions)
        )
    }
    
    private func getLastUpdateDate(sessions: [SleepSession]) -> String {
        guard let lastSession = sessions.max(by: { $0.createdAt < $1.createdAt }) else {
            return "Нет данных"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        
        return formatter.string(from: lastSession.createdAt)
    }
}

// Вспомогательная структура для статистики данных
struct DataStats {
    var totalSessions: Int = 0
    var weeklySleep: String = "0ч 0м"
    var monthlySleep: String = "0ч 0м"
    var lastUpdate: String = "Нет данных"
    
    init() {}
    
    init(totalSessions: Int, weeklySleep: String, monthlySleep: String, lastUpdate: String) {
        self.totalSessions = totalSessions
        self.weeklySleep = weeklySleep
        self.monthlySleep = monthlySleep
        self.lastUpdate = lastUpdate
    }
}
