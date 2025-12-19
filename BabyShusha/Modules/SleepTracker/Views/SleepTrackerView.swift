// Modules/SleepTracker/Views/SleepTrackerView.swift
import SwiftUI

struct SleepTrackerView: View {
    @StateObject private var viewModel = SleepTrackerViewModel()
    @StateObject private var profileViewModel = ChildProfileViewModel()
    @State private var tabBarHeight: CGFloat = 85 // Высота TabBar + отступы
    @State private var showingAddNoteSheet = false
    @State private var showingHistorySheet = false
    @State private var showingStatisticsSheet = false
    @State private var showingDataManagement = false
    @State private var showToast = false
    @State private var toastMessage = ""
    
    let onBackToSounds: (() -> Void)?
    
    var body: some View {
        ZStack {
            // Фон для вкладки сна
            backgroundView
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Заголовок
                    headerView
                    
                    // Статистика сна
                    statsView
                    
                    // Кнопка отслеживания
                    trackingButtonView
                    
                    // Текущая сессия (если активна)
                    if viewModel.isTracking {
                        currentSessionView
                    }
                    
                    // Прогресс недели
                    weeklyProgressView
                    
                    // Быстрые действия
                    quickActionsView
                    
                    // История сна (превью)
                    if !viewModel.sleepHistory.isEmpty {
                        historyPreviewView
                    }
                    
                    // Советы для сна
                    sleepTipsView
                    
                    // Отступ для TabBar
                    Spacer(minLength: tabBarHeight)
                }
                .padding(.horizontal, 20)
                .padding(.vertical)
            }
            
            // Индикатор загрузки
            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .sheet(isPresented: $showingAddNoteSheet) {
            AddNoteSheet { quality, notes, mood in
                viewModel.updateCurrentSession(quality: quality, notes: notes, mood: mood)
                viewModel.stopTracking()
                showToast(message: "Сеанс сна сохранён!", icon: "checkmark.circle.fill", color: .green)
            }
        }
        .sheet(isPresented: $showingHistorySheet) {
            SleepHistoryView(
                sessions: viewModel.sleepHistory,
                onDelete: { session in
                    viewModel.deleteSession(session)
                    showToast(message: "Запись удалена", icon: "trash.circle.fill", color: .red)
                }
            )
        }
        .sheet(isPresented: $showingStatisticsSheet) {
            if let stats = viewModel.weeklyStats {
                StatisticsSheet(stats: stats)
            }
        }
        .sheet(isPresented: $showingDataManagement) {
            DataManagementView()
        }
        .onAppear {
            // Загружаем данные при появлении
            viewModel.loadSleepHistory()
            viewModel.loadWeeklyStats()
        }
        .toast(isShowing: $showToast, message: toastMessage)
    }
    
    // MARK: - Компоненты
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color(red: 0.07, green: 0.1, blue: 0.2),
                Color(red: 0.12, green: 0.08, blue: 0.25),
                Color(red: 0.15, green: 0.05, blue: 0.3)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("Загружаем данные...")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            )
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Отслеживание сна")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Кнопка статистики
                Button {
                    showingStatisticsSheet = true
                } label: {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.purple)
                        .padding(10)
                        .background(Circle().fill(.ultraThinMaterial))
                }
            }
            
            Text("Анализ качества и продолжительности сна")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Милый персонаж
            HStack {
                Text("😴")
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Сладких снов малышу!")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Качественный сон — залог здоровья")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    private var statsView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                StatCard(
                    title: "Среднее",
                    value: viewModel.weeklyStats?.averageSleepFormatted ?? "0ч 0м",
                    icon: "clock.fill",
                    color: .blue,
                    subtitle: "за 7 дней"
                )
                
                StatCard(
                    title: "Качество",
                    value: String(format: "%.1f/10", viewModel.weeklyStats?.averageQuality ?? 0),
                    icon: "star.fill",
                    color: .yellow,
                    subtitle: "оценка сна"
                )
            }
            
            HStack(spacing: 12) {
                StatCard(
                    title: "Всего",
                    value: viewModel.weeklyStats?.totalSleepFormatted ?? "0ч 0м",
                    icon: "chart.bar.fill",
                    color: .green,
                    subtitle: "за неделю"
                )
                
                StatCard(
                    title: "Сессий",
                    value: "\(viewModel.weeklyStats?.sessions.count ?? 0)",
                    icon: "moon.zzz.fill",
                    color: .purple,
                    subtitle: "количество"
                )
            }
        }
    }
    
    private var currentSessionView: some View {
        HStack {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 18))
                .foregroundColor(.purple)
                .symbolEffect(.bounce, options: .repeating)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Идёт отслеживание")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text(viewModel.elapsedTime)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(.purple)
            }
            
            Spacer()
            
            Button("Завершить") {
                showingAddNoteSheet = true
            }
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var trackingButtonView: some View {
        Button(action: {
            if viewModel.isTracking {
                showingAddNoteSheet = true
            } else {
                viewModel.toggleTracking()
                showToast(message: "Отслеживание сна начато", icon: "moon.zzz.fill", color: .purple)
            }
        }) {
            HStack(spacing: 16) {
                Image(systemName: viewModel.isTracking ? "moon.zzz.fill" : "moon.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .symbolEffect(.bounce, value: viewModel.isTracking)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.isTracking ? "Отслеживается" : "Начать отслеживание")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(viewModel.isTracking ?
                         "Начато: \(viewModel.startTimeFormatted)" :
                         "Запустите когда ребёнок засыпает")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                if viewModel.isTracking {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .shadow(color: .green, radius: 3)
                }
            }
            .foregroundColor(.white)
            .padding()
            .background(
                LinearGradient(
                    colors: viewModel.isTracking ?
                        [.purple, .blue] :
                        [.blue.opacity(0.7), .purple.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
            )
            .shadow(color: .purple.opacity(viewModel.isTracking ? 0.5 : 0.3),
                   radius: viewModel.isTracking ? 20 : 15,
                   y: viewModel.isTracking ? 8 : 5)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var weeklyProgressView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Прогресс за неделю")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(viewModel.weeklyGoalProgress)%")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(viewModel.weeklyGoalProgress >= 80 ? .green :
                                    viewModel.weeklyGoalProgress >= 60 ? .yellow : .orange)
            }
            
            // Прогресс-бар
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: getProgressBarColors(),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: CGFloat(min(viewModel.weeklyGoalProgress, 100)) * 2.8, height: 8)
                    .animation(.spring(response: 0.5), value: viewModel.weeklyGoalProgress)
            }
            
            HStack {
                Text("Цель: 56 часов")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Text("\(viewModel.weeklyTotalHours) из 56ч")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func getProgressBarColors() -> [Color] {
        switch viewModel.weeklyGoalProgress {
        case 0..<40:
            return [.red, .orange]
        case 40..<70:
            return [.orange, .yellow]
        case 70..<90:
            return [.yellow, .green]
        default:
            return [.green, .blue]
        }
    }
    
    private var quickActionsView: some View {
        HStack(spacing: 12) {
            // Кнопка истории
            Button {
                showingHistorySheet = true
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 22))
                        .foregroundColor(.blue)
                    
                    Text("История")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.ultraThinMaterial)
                )
            }
            
            // Кнопка статистики
            Button {
                showingStatisticsSheet = true
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.green)
                    
                    Text("Статистика")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.ultraThinMaterial)
                )
            }
            
            // Кнопка управления данными
            Button {
                showingDataManagement = true
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: "gear")
                        .font(.system(size: 22))
                        .foregroundColor(.gray)
                    
                    Text("Данные")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.ultraThinMaterial)
                )
            }
            
            // Кнопка возврата к звукам
            if let onBackToSounds = onBackToSounds {
                Button {
                    onBackToSounds()
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.purple)
                        
                        Text("Звуки")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.ultraThinMaterial)
                    )
                }
            }
        }
    }
    
    private var historyPreviewView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Последние сеансы")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Все") {
                    showingHistorySheet = true
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.purple)
            }
            
            ForEach(viewModel.sleepHistory.prefix(3)) { session in
                HistoryRow(session: session)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var sleepTipsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Советы для лучшего сна")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                TipRow(
                    icon: "drop.fill",
                    title: "Оптимальная температура",
                    description: "18-22°C в комнате",
                    color: .blue
                )
                
                TipRow(
                    icon: "lightbulb.fill",
                    title: "Приглушённый свет",
                    description: "За 30 минут до сна",
                    color: .yellow
                )
                
                TipRow(
                    icon: "speaker.wave.2.fill",
                    title: "Белый шум",
                    description: "Маскирует фоновые звуки",
                    color: .purple
                )
                
                TipRow(
                    icon: "clock.fill",
                    title: "Режим сна",
                    description: "Стабильное время засыпания",
                    color: .green
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Helper Methods
    
    private func showToast(message: String, icon: String = "checkmark.circle.fill", color: Color = .green) {
        toastMessage = message
        showToast = true
    }
}

// MARK: - Вспомогательные компоненты

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct TipRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct HistoryRow: View {
    let session: SleepSession
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.dayOfWeek)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text(session.dateString)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(session.durationString)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                if let mood = session.mood {
                    Text(mood)
                        .font(.system(size: 20))
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Statistics Sheet
struct StatisticsSheet: View {
    let stats: SleepStatistics
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Основные метрики
                    VStack(spacing: 16) {
                        StatisticCard(
                            title: "Всего сна за неделю",
                            value: stats.totalSleepFormatted,
                            icon: "clock.fill",
                            color: .blue
                        )
                        
                        StatisticCard(
                            title: "Среднее в день",
                            value: stats.averageSleepFormatted,
                            icon: "chart.bar.fill",
                            color: .green
                        )
                        
                        StatisticCard(
                            title: "Средняя оценка",
                            value: String(format: "%.1f/10", stats.averageQuality),
                            icon: "star.fill",
                            color: .orange
                        )
                        
                        if let longest = stats.longestSession {
                            StatisticCard(
                                title: "Самый долгий сон",
                                value: longest.durationString,
                                icon: "trophy.fill",
                                color: .purple
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Распределение по дням
                    if !stats.sleepByDayOfWeek.isEmpty {
                        DayDistributionView(data: stats.sleepByDayOfWeek)
                            .padding(.horizontal)
                    }
                    
                    // Дополнительная статистика
                    if stats.sessions.count >= 3 {
                        additionalStatsView
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Статистика сна")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var additionalStatsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Дополнительная информация")
                .font(.headline)
            
            HStack {
                StatisticInfoRow(
                    title: "Всего сессий",
                    value: "\(stats.sessions.count)",
                    icon: "number.circle.fill",
                    color: .blue
                )
                
                Spacer()
                
                StatisticInfoRow(
                    title: "Лучшая оценка",
                    value: String(format: "%.0f/10", stats.sessions.compactMap { $0.quality }.max() ?? 0),
                    icon: "star.circle.fill",
                    color: .yellow
                )
            }
            
            HStack {
                StatisticInfoRow(
                    title: "Средняя продолжительность",
                    value: stats.averageSleepFormatted,
                    icon: "clock.circle.fill",
                    color: .green
                )
                
                Spacer()
                
                if let shortest = stats.shortestSession {
                    StatisticInfoRow(
                        title: "Самый короткий сон",
                        value: shortest.durationString,
                        icon: "hourglass.circle.fill",
                        color: .orange
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title2.bold())
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatisticInfoRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.body.bold())
        }
        .frame(maxWidth: .infinity)
    }
}

struct DayDistributionView: View {
    let data: [String: TimeInterval]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Сон по дням недели")
                .font(.headline)
            
            ForEach(getSortedDays(), id: \.0) { day, duration in
                HStack {
                    Text(day.prefix(3))
                        .font(.caption)
                        .frame(width: 40, alignment: .leading)
                    
                    GeometryReader { geometry in
                        let width = geometry.size.width
                        let maxDuration = data.values.max() ?? 1
                        let barWidth = CGFloat(duration / maxDuration) * width * 0.9
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(getBarColor(for: duration))
                            .frame(width: barWidth, height: 20)
                    }
                    .frame(height: 20)
                    
                    Text(formatDuration(duration))
                        .font(.caption)
                        .frame(width: 60, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func getSortedDays() -> [(String, TimeInterval)] {
        let dayOrder = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
        return data.sorted { dayOrder.firstIndex(of: $0.key) ?? 0 < dayOrder.firstIndex(of: $1.key) ?? 0 }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)ч \(minutes)м"
        } else {
            return "\(minutes)м"
        }
    }
    
    private func getBarColor(for duration: TimeInterval) -> Color {
        let hours = duration / 3600
        switch hours {
        case 0..<1:
            return .red.opacity(0.6)
        case 1..<2:
            return .orange.opacity(0.6)
        case 2..<3:
            return .yellow.opacity(0.6)
        case 3..<5:
            return .green.opacity(0.6)
        default:
            return .blue.opacity(0.6)
        }
    }
}

// MARK: - Toast Components

//struct ToastView: View {
//    let message: String
//    let icon: String
//    let color: Color
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            Image(systemName: icon)
//                .font(.system(size: 18))
//                .foregroundColor(color)
//            
//            Text(message)
//                .font(.system(size: 14, weight: .medium))
//                .foregroundColor(.white)
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 12)
//        .background(
//            Capsule()
//                .fill(.ultraThinMaterial)
//                .overlay(
//                    Capsule()
//                        .stroke(color.opacity(0.3), lineWidth: 1)
//                )
//                .shadow(color: color.opacity(0.2), radius: 10, y: 5)
//        )
//        .padding(.top, 10)
//    }
//}
//
//struct ToastModifier: ViewModifier {
//    @Binding var isShowing: Bool
//    let message: String
//    let icon: String
//    let color: Color
//    let duration: TimeInterval
//    
//    func body(content: Content) -> some View {
//        ZStack(alignment: .top) {
//            content
//            
//            if isShowing {
//                ToastView(message: message, icon: icon, color: color)
//                    .transition(.move(edge: .top).combined(with: .opacity))
//                    .onAppear {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
//                            withAnimation {
//                                isShowing = false
//                            }
//                        }
//                    }
//            }
//        }
//    }
//}
//
//extension View {
//    func toast(
//        isShowing: Binding<Bool>,
//        message: String,
//        icon: String = "checkmark.circle.fill",
//        color: Color = .green,
//        duration: TimeInterval = 2
//    ) -> some View {
//        self.modifier(ToastModifier(
//            isShowing: isShowing,
//            message: message,
//            icon: icon,
//            color: color,
//            duration: duration
//        ))
//    }
//}
//
//// MARK: - ScaleButtonStyle
//struct ScaleButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
//            .animation(.spring(response: 0.3, dampingFraction: 0.7),
//                      value: configuration.isPressed)
//    }
//}

// MARK: - Preview
struct SleepTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        SleepTrackerView(onBackToSounds: nil)
    }
}
