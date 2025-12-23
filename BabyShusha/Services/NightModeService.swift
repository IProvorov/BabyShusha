import UIKit
import AVFoundation

final class NightModeService {
    static let shared = NightModeService()
    
    private let userDefaults = UserDefaults.standard
    private let notificationCenter = NotificationCenter.default
    
    // MARK: - Properties
    
    var isNightModeEnabled: Bool {
        get { userDefaults.bool(forKey: "night_mode_enabled") }
        set {
            userDefaults.set(newValue, forKey: "night_mode_enabled")
            if newValue {
                enableNightMode()
            } else {
                disableNightMode()
            }
            notificationCenter.post(name: .nightModeChanged, object: newValue)
        }
    }
    
    var autoNightMode: Bool {
        get { userDefaults.bool(forKey: "auto_night_mode") }
        set { userDefaults.set(newValue, forKey: "auto_night_mode") }
    }
    
    var nightModeStartTime: Date? {
        get {
            guard let timeInterval = userDefaults.value(forKey: "night_mode_start") as? TimeInterval else {
                return Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())
            }
            return Date(timeIntervalSince1970: timeInterval)
        }
        set {
            userDefaults.set(newValue?.timeIntervalSince1970, forKey: "night_mode_start")
        }
    }
    
    var nightModeEndTime: Date? {
        get {
            guard let timeInterval = userDefaults.value(forKey: "night_mode_end") as? TimeInterval else {
                return Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())
            }
            return Date(timeIntervalSince1970: timeInterval)
        }
        set {
            userDefaults.set(newValue?.timeIntervalSince1970, forKey: "night_mode_end")
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        setupNotifications()
        checkAutoNightMode()
    }
    
    // MARK: - Setup
    
    private func setupNotifications() {
        notificationCenter.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    // MARK: - Night Mode Control
    
    func enableNightMode() {
        // Уменьшаем яркость экрана
        UIScreen.main.brightness = 0.1
        
        // Включаем фильтр красного (для ночных кормлений)
        enableRedFilter()
        
        // Настраиваем аудиосессию для фонового воспроизведения
        setupAudioSessionForNightMode()
        
        // Отключаем авто-лок
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Записываем время начала ночного режима
        userDefaults.set(Date().timeIntervalSince1970, forKey: "night_mode_last_start")
        
        AnalyticsService.logNightModeEnabled()
    }
    
    func disableNightMode() {
        // Восстанавливаем яркость
        if let savedBrightness = userDefaults.value(forKey: "previous_brightness") as? CGFloat {
            UIScreen.main.brightness = savedBrightness
        }
        
        // Отключаем фильтр
        disableRedFilter()
        
        // Восстанавливаем аудиосессию
        restoreAudioSession()
        
        // Включаем авто-лок
        UIApplication.shared.isIdleTimerDisabled = false
        
        // Записываем длительность ночного режима
        if let startTime = userDefaults.value(forKey: "night_mode_last_start") as? TimeInterval {
            let duration = Date().timeIntervalSince1970 - startTime
            AnalyticsService.logNightModeDuration(duration)
        }
    }
    
    func toggleNightMode() {
        if isNightModeEnabled {
            // Сохраняем текущую яркость перед выключением
            userDefaults.set(UIScreen.main.brightness, forKey: "previous_brightness")
        }
        isNightModeEnabled.toggle()
    }
    
    // MARK: - Red Filter (для ночных кормлений)
    
    private func enableRedFilter() {
        guard let window = UIApplication.shared.windows.first else { return }
        
        let redFilterView = UIView(frame: window.bounds)
        redFilterView.backgroundColor = UIColor.red.withAlphaComponent(0.05)
        redFilterView.tag = 9999 // Для идентификации
        redFilterView.isUserInteractionEnabled = false
        
        window.addSubview(redFilterView)
    }
    
    private func disableRedFilter() {
        UIApplication.shared.windows.forEach { window in
            window.viewWithTag(9999)?.removeFromSuperview()
        }
    }
    
    // MARK: - Audio Session
    
    private func setupAudioSessionForNightMode() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .duckOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }
    }
    
    private func restoreAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: []
            )
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Error restoring audio session: \(error)")
        }
    }
    
    // MARK: - Auto Night Mode
    
    private func checkAutoNightMode() {
        guard autoNightMode else { return }
        
        let currentTime = Date()
        let calendar = Calendar.current
        
        guard let startTime = nightModeStartTime,
              let endTime = nightModeEndTime else { return }
        
        let currentComponents = calendar.dateComponents([.hour, .minute], from: currentTime)
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        
        let currentMinutes = (currentComponents.hour ?? 0) * 60 + (currentComponents.minute ?? 0)
        let startMinutes = (startComponents.hour ?? 0) * 60 + (startComponents.minute ?? 0)
        let endMinutes = (endComponents.hour ?? 0) * 60 + (endComponents.minute ?? 0)
        
        // Проверяем, нужно ли включать ночной режим
        let shouldEnable: Bool
        
        if startMinutes < endMinutes {
            // Нормальный интервал (например, 20:00 - 7:00)
            shouldEnable = currentMinutes >= startMinutes && currentMinutes < endMinutes
        } else {
            // Интервал через полночь (например, 22:00 - 6:00)
            shouldEnable = currentMinutes >= startMinutes || currentMinutes < endMinutes
        }
        
        if shouldEnable && !isNightModeEnabled {
            // Сохраняем текущую яркость
            userDefaults.set(UIScreen.main.brightness, forKey: "previous_brightness")
            isNightModeEnabled = true
        } else if !shouldEnable && isNightModeEnabled {
            isNightModeEnabled = false
        }
    }
    
    // MARK: - Quick Actions для ночного режима
    
    func setupNightModeQuickActions() {
        let playWhiteNoiseAction = UIMutableApplicationShortcutItem(
            type: "com.babyshusha.nightmode.whitenoise",
            localizedTitle: "Белый шум",
            localizedSubtitle: "Ночной режим",
            icon: UIApplicationShortcutIcon(systemImageName: "moon.zzz.fill"),
            userInfo: nil
        )
        
        let startTimerAction = UIMutableApplicationShortcutItem(
            type: "com.babyshusha.nightmode.timer",
            localizedTitle: "Таймер сна",
            localizedSubtitle: "30 минут",
            icon: UIApplicationShortcutIcon(systemImageName: "timer"),
            userInfo: nil
        )
        
        UIApplication.shared.shortcutItems = [playWhiteNoiseAction, startTimerAction]
    }
    
    // MARK: - Notification Handlers
    
    @objc private func appDidBecomeActive() {
        checkAutoNightMode()
    }
    
    @objc private func appWillResignActive() {
        // При уходе в фон можно уменьшить громкость
        if isNightModeEnabled {
            AudioService.shared.setVolume(0.3)
        }
    }
    
    // MARK: - Night Mode Features
    
    func startNightFeedingMode() {
        // Специальный режим для ночных кормлений
        enableNightMode()
        
        // Запускаем мягкий звук
        AudioService.shared.playSound(named: "heartbeat.mp3", volume: 0.2, loop: true) { _ in }
        
        // Запускаем таймер на 20 минут (среднее время кормления)
        Timer.scheduledTimer(withTimeInterval: 20 * 60, repeats: false) { _ in
            AudioService.shared.stopAll()
            self.disableNightMode()
        }
    }
    
    func getNightModeStats() -> NightModeStats {
        let totalDuration = userDefaults.double(forKey: "night_mode_total_duration")
        let sessionsCount = userDefaults.integer(forKey: "night_mode_sessions_count")
        
        return NightModeStats(
            totalDuration: totalDuration,
            sessionsCount: sessionsCount,
            averageDuration: sessionsCount > 0 ? totalDuration / Double(sessionsCount) : 0
        )
    }
}

// MARK: - Extensions

extension Notification.Name {
    static let nightModeChanged = Notification.Name("nightModeChanged")
}

struct NightModeStats {
    let totalDuration: TimeInterval // в секундах
    let sessionsCount: Int
    let averageDuration: TimeInterval
}
