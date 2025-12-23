import SwiftUI
import UIKit

// MARK: - NightModeService (Обновленная версия для SwiftUI)
class NightModeService: ObservableObject {
    static let shared = NightModeService()
    
    @Published var isNightModeEnabled = false
    @Published var autoNightMode = false
    @Published var nightModeStartTime: Date
    @Published var nightModeEndTime: Date
    
    private let defaults = UserDefaults.standard
    private let screen = UIScreen.main
    private var redFilterView: UIView?
    private var previousBrightness: CGFloat = 0.5
    
    private init() {
        // Загружаем сохраненные настройки
        self.isNightModeEnabled = defaults.bool(forKey: "night_mode_enabled")
        self.autoNightMode = defaults.bool(forKey: "auto_night_mode")
        
        if let start = defaults.object(forKey: "night_mode_start") as? Date {
            self.nightModeStartTime = start
        } else {
            self.nightModeStartTime = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
        }
        
        if let end = defaults.object(forKey: "night_mode_end") as? Date {
            self.nightModeEndTime = end
        } else {
            self.nightModeEndTime = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!
        }
        
        self.previousBrightness = CGFloat(defaults.float(forKey: "previous_brightness"))
        if self.previousBrightness == 0 {
            self.previousBrightness = screen.brightness
        }
        
        setupNotifications()
    }
    
    // MARK: - Public Methods
    
    func toggleNightMode() {
        if isNightModeEnabled {
            disableNightMode()
        } else {
            enableNightMode()
        }
        saveSettings()
    }
    
    func enableNightMode() {
        previousBrightness = screen.brightness
        defaults.set(previousBrightness, forKey: "previous_brightness")
        
        // Уменьшаем яркость
        screen.brightness = 0.1
        
        // Включаем красный фильтр
        enableRedFilter()
        
        // Отключаем авто-лок
        UIApplication.shared.isIdleTimerDisabled = true
        
        isNightModeEnabled = true
        
        // Записываем время начала
        defaults.set(Date().timeIntervalSince1970, forKey: "night_mode_last_start")
        
        incrementSessionCount()
    }
    
    func disableNightMode() {
        // Восстанавливаем яркость
        screen.brightness = previousBrightness
        
        // Отключаем фильтр
        disableRedFilter()
        
        // Восстанавливаем авто-лок
        UIApplication.shared.isIdleTimerDisabled = false
        
        isNightModeEnabled = false
        
        // Записываем длительность
        if let startTime = defaults.value(forKey: "night_mode_last_start") as? TimeInterval {
            let duration = Date().timeIntervalSince1970 - startTime
            let totalDuration = defaults.double(forKey: "night_mode_total_duration") + duration
            defaults.set(totalDuration, forKey: "night_mode_total_duration")
        }
    }
    
    func startNightFeedingMode() {
        enableNightMode()
        
        // Запускаем звук сердцебиения на низкой громкости
        AudioService.shared.playSound(named: "heartbeat.mp3", volume: 0.2, loop: true) { _ in }
        
        // Автоматически выключаем через 20 минут
        DispatchQueue.main.asyncAfter(deadline: .now() + 20 * 60) {
            AudioService.shared.stopAll()
            self.disableNightMode()
        }
    }
    
    func checkAutoNightMode() {
        guard autoNightMode else { return }
        
        let currentTime = Date()
        let calendar = Calendar.current
        
        let currentComponents = calendar.dateComponents([.hour, .minute], from: currentTime)
        let startComponents = calendar.dateComponents([.hour, .minute], from: nightModeStartTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: nightModeEndTime)
        
        let currentMinutes = (currentComponents.hour ?? 0) * 60 + (currentComponents.minute ?? 0)
        let startMinutes = (startComponents.hour ?? 0) * 60 + (startComponents.minute ?? 0)
        let endMinutes = (endComponents.hour ?? 0) * 60 + (endComponents.minute ?? 0)
        
        let shouldEnable: Bool
        
        if startMinutes < endMinutes {
            // Нормальный интервал (например, 20:00 - 7:00)
            shouldEnable = currentMinutes >= startMinutes && currentMinutes < endMinutes
        } else {
            // Интервал через полночь (например, 22:00 - 6:00)
            shouldEnable = currentMinutes >= startMinutes || currentMinutes < endMinutes
        }
        
        if shouldEnable && !isNightModeEnabled {
            enableNightMode()
        } else if !shouldEnable && isNightModeEnabled {
            disableNightMode()
        }
    }
    
    func saveSettings() {
        defaults.set(isNightModeEnabled, forKey: "night_mode_enabled")
        defaults.set(autoNightMode, forKey: "auto_night_mode")
        defaults.set(nightModeStartTime, forKey: "night_mode_start")
        defaults.set(nightModeEndTime, forKey: "night_mode_end")
        defaults.set(previousBrightness, forKey: "previous_brightness")
    }
    
    func getNightModeStats() -> NightModeStats {
        let totalDuration = defaults.double(forKey: "night_mode_total_duration")
        let sessionsCount = defaults.integer(forKey: "night_mode_sessions_count")
        
        return NightModeStats(
            totalDuration: totalDuration,
            sessionsCount: sessionsCount,
            averageDuration: sessionsCount > 0 ? totalDuration / Double(sessionsCount) : 0
        )
    }
    
    // MARK: - Private Methods
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    private func enableRedFilter() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            
            let redFilterView = UIView(frame: window.bounds)
            redFilterView.backgroundColor = UIColor.red.withAlphaComponent(0.05)
            redFilterView.tag = 9999
            redFilterView.isUserInteractionEnabled = false
            redFilterView.layer.zPosition = CGFloat.greatestFiniteMagnitude - 1
            
            window.addSubview(redFilterView)
            self.redFilterView = redFilterView
        }
    }
    
    private func disableRedFilter() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                for window in windowScene.windows {
                    window.viewWithTag(9999)?.removeFromSuperview()
                }
            }
            self.redFilterView = nil
        }
    }
    
    private func incrementSessionCount() {
        let count = defaults.integer(forKey: "night_mode_sessions_count") + 1
        defaults.set(count, forKey: "night_mode_sessions_count")
    }
    
    @objc private func appDidBecomeActive() {
        checkAutoNightMode()
    }
}

struct NightModeStats {
    let totalDuration: TimeInterval // в секундах
    let sessionsCount: Int
    let averageDuration: TimeInterval
}

// MARK: - NightModeView
struct NightModeView: View {
    @EnvironmentObject var nightModeService: NightModeService
    @EnvironmentObject var quickActionsService: QuickActionsService
    @State private var showingTimePicker = false
    @State private var timePickerType: TimePickerType = .start
    @State private var isHapticEnabled = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Основной блок
                mainCard
                
                // Автоматический режим
                autoModeSection
                    .padding(.top, 24)
                
                // Быстрые действия для ночи
                quickActionsSection
                    .padding(.top, 24)
                
                // Статистика
                statsSection
                    .padding(.top, 24)
                    .padding(.bottom, 40)
            }
            .padding(.horizontal)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Ночной режим")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            nightModeService.checkAutoNightMode()
        }
        .sheet(isPresented: $showingTimePicker) {
            TimePickerView(
                type: timePickerType,
                selectedTime: timePickerType == .start ?
                    nightModeService.nightModeStartTime :
                    nightModeService.nightModeEndTime
            ) { newTime in
                updateNightModeTime(newTime)
            }
        }
    }
    
    // MARK: - Main Card
    private var mainCard: some View {
        VStack(spacing: 0) {
            // Фон с градиентом
            LinearGradient(
                colors: nightModeService.isNightModeEnabled ?
                    [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.2, green: 0.1, blue: 0.3)] :
                    [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 300)
            .overlay(
                VStack(spacing: 24) {
                    // Иконка
                    Image(systemName: nightModeService.isNightModeEnabled ?
                          "moon.stars.fill" : "moon.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.white)
                        .symbolEffect(.bounce, value: nightModeService.isNightModeEnabled)
                    
                    // Текст состояния
                    VStack(spacing: 8) {
                        Text(nightModeService.isNightModeEnabled ?
                             "Ночной режим включен" : "Ночной режим")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(nightModeService.isNightModeEnabled ?
                             "Для ночных кормлений и укачиваний" :
                             "Включите для ночных кормлений")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    
                    // Основная кнопка
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            toggleNightMode()
                        }
                    } label: {
                        HStack {
                            Image(systemName: nightModeService.isNightModeEnabled ?
                                  "moon.zzz" : "moon")
                            
                            Text(nightModeService.isNightModeEnabled ?
                                 "Выключить" : "Включить ночной режим")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(nightModeService.isNightModeEnabled ? .white : .blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            nightModeService.isNightModeEnabled ?
                            Color.white.opacity(0.2) : Color.white
                        )
                        .cornerRadius(15)
                    }
                    .padding(.horizontal, 40)
                }
                .padding()
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }
    
    // MARK: - Auto Mode Section
    private var autoModeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Автоматический режим")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                // Переключатель авторежима
                ToggleRow(
                    icon: "clock.arrow.circlepath",
                    title: "Автовключение",
                    subtitle: "Включать автоматически по расписанию",
                    isOn: $nightModeService.autoNightMode
                )
                .onChange(of: nightModeService.autoNightMode) { newValue in
                    nightModeService.saveSettings()
                }
                
                Divider()
                    .padding(.leading, 50)
                
                // Время начала
                Button {
                    timePickerType = .start
                    showingTimePicker = true
                } label: {
                    TimeRow(
                        icon: "sunset.fill",
                        title: "Время начала",
                        time: nightModeService.nightModeStartTime,
                        isEnabled: nightModeService.autoNightMode
                    )
                }
                .disabled(!nightModeService.autoNightMode)
                
                Divider()
                    .padding(.leading, 50)
                
                // Время окончания
                Button {
                    timePickerType = .end
                    showingTimePicker = true
                } label: {
                    TimeRow(
                        icon: "sunrise.fill",
                        title: "Время окончания",
                        time: nightModeService.nightModeEndTime,
                        isEnabled: nightModeService.autoNightMode
                    )
                }
                .disabled(!nightModeService.autoNightMode)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Быстрые действия для ночи")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    icon: "drop.fill",
                    title: "Кормление",
                    color: .blue,
                    action: startNightFeeding
                )
                
                QuickActionButton(
                    icon: "music.note",
                    title: "Колыбельная",
                    color: .purple,
                    action: playLullaby
                )
                
                QuickActionButton(
                    icon: "timer",
                    title: "Таймер",
                    color: .orange,
                    action: startSleepTimer
                )
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Статистика")
                .font(.headline)
                .padding(.horizontal)
            
            let stats = nightModeService.getNightModeStats()
            
            VStack(spacing: 0) {
                StatRow(
                    icon: "moon.zzz.fill",
                    title: "Всего сессий",
                    value: "\(stats.sessionsCount)"
                )
                
                Divider()
                    .padding(.leading, 50)
                
                StatRow(
                    icon: "clock.fill",
                    title: "Общее время",
                    value: formatDuration(stats.totalDuration)
                )
                
                Divider()
                    .padding(.leading, 50)
                
                StatRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Средняя длительность",
                    value: formatDuration(stats.averageDuration)
                )
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    // MARK: - Actions
    private func toggleNightMode() {
        if isHapticEnabled {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
        
        nightModeService.toggleNightMode()
    }
    
    private func updateNightModeTime(_ time: Date) {
        if timePickerType == .start {
            nightModeService.nightModeStartTime = time
        } else {
            nightModeService.nightModeEndTime = time
        }
        nightModeService.saveSettings()
    }
    
    private func startNightFeeding() {
        nightModeService.startNightFeedingMode()
        
        if isHapticEnabled {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        
        showSuccessMessage("Режим ночного кормления запущен")
    }
    
    private func playLullaby() {
        QuickActionsService.shared.performQuickAction(.lullaby) { success in
            if success {
                showSuccessMessage("Колыбельная запущена")
            }
        }
    }
    
    private func startSleepTimer() {
        QuickActionsService.shared.performQuickAction(.timer30) { success in
            if success {
                showSuccessMessage("Таймер сна на 30 минут запущен")
            }
        }
    }
    
    // MARK: - Helpers
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 2
        
        if let formatted = formatter.string(from: duration) {
            return formatted
        }
        
        // Fallback форматирование
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)ч \(minutes)м"
        } else if hours > 0 {
            return "\(hours)ч"
        } else if minutes > 0 {
            return "\(minutes)м"
        } else {
            return "0м"
        }
    }
    
    private func showSuccessMessage(_ message: String) {
        // Временная реализация - можно заменить на Toast
        print("✅ \(message)")
    }
}

// MARK: - Supporting Views

struct ToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

struct TimeRow: View {
    let icon: String
    let title: String
    let time: Date
    let isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isEnabled ? .orange : .gray)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(isEnabled ? .primary : .secondary)
                
                Text(time.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundColor(isEnabled ? .secondary : .gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .opacity(isEnabled ? 1.0 : 0.6)
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(color)
            .cornerRadius(15)
            .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                
                Text(value)
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

// MARK: - Time Picker Components
enum TimePickerType {
    case start, end
}

struct TimePickerView: View {
    let type: TimePickerType
    @State var selectedTime: Date
    let onSave: (Date) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding()
                
                Spacer()
            }
            .navigationTitle(type == .start ? "Время начала" : "Время окончания")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        onSave(selectedTime)
                        dismiss()
                    }
                }
            }
        }
    }
}




