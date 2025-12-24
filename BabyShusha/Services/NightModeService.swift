import SwiftUI
import UIKit
import Combine

class NightModeService: ObservableObject {
    static let shared = NightModeService()
    
    @Published var isNightModeEnabled = false
    @Published var autoNightMode = false
    @Published var nightModeStartTime = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
    @Published var nightModeEndTime = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!
    
    private let defaults = UserDefaults.standard
    private var redFilterView: UIView?
    private var previousBrightness: CGFloat = UIScreen.main.brightness
    
    // Делаем init public
    public init() {
        loadSettings()
        setupNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func loadSettings() {
        isNightModeEnabled = defaults.bool(forKey: "night_mode_enabled")
        autoNightMode = defaults.bool(forKey: "auto_night_mode")
        
        if let start = defaults.object(forKey: "night_mode_start") as? Date {
            nightModeStartTime = start
        }
        if let end = defaults.object(forKey: "night_mode_end") as? Date {
            nightModeEndTime = end
        }
        previousBrightness = CGFloat(defaults.float(forKey: "previous_brightness"))
        if previousBrightness == 0 {
            previousBrightness = UIScreen.main.brightness
        }
    }
    
    private func saveSettings() {
        defaults.set(isNightModeEnabled, forKey: "night_mode_enabled")
        defaults.set(autoNightMode, forKey: "auto_night_mode")
        defaults.set(nightModeStartTime, forKey: "night_mode_start")
        defaults.set(nightModeEndTime, forKey: "night_mode_end")
        defaults.set(Float(previousBrightness), forKey: "previous_brightness")
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
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
        previousBrightness = UIScreen.main.brightness
        defaults.set(Float(previousBrightness), forKey: "previous_brightness")
        
        // Уменьшаем яркость
        UIScreen.main.brightness = 0.1
        
        // Включаем красный фильтр
        enableRedFilter()
        
        // Отключаем авто-лок
        UIApplication.shared.isIdleTimerDisabled = true
        
        isNightModeEnabled = true
        saveSettings()
    }
    
    func disableNightMode() {
        // Восстанавливаем яркость
        UIScreen.main.brightness = previousBrightness
        
        // Отключаем фильтр
        disableRedFilter()
        
        // Восстанавливаем авто-лок
        UIApplication.shared.isIdleTimerDisabled = false
        
        isNightModeEnabled = false
        saveSettings()
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
            shouldEnable = currentMinutes >= startMinutes && currentMinutes < endMinutes
        } else {
            shouldEnable = currentMinutes >= startMinutes || currentMinutes < endMinutes
        }
        
        if shouldEnable && !isNightModeEnabled {
            enableNightMode()
        } else if !shouldEnable && isNightModeEnabled {
            disableNightMode()
        }
    }
    
    // MARK: - Red Filter
    
    private func enableRedFilter() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            
            let redFilterView = UIView(frame: window.bounds)
            redFilterView.backgroundColor = UIColor.red.withAlphaComponent(0.05)
            redFilterView.tag = 9999
            redFilterView.isUserInteractionEnabled = false
            
            window.addSubview(redFilterView)
            self.redFilterView = redFilterView
        }
    }
    
    private func disableRedFilter() {
        DispatchQueue.main.async {
            self.redFilterView?.removeFromSuperview()
            self.redFilterView = nil
        }
    }
    
    // MARK: - Notification Handlers
    
    @objc private func appDidBecomeActive() {
        checkAutoNightMode()
    }
}
