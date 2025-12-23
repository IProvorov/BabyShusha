import UIKit
import AVFoundation

enum QuickActionType: String, CaseIterable {
    case whiteNoise = "white_noise"
    case heartbeat = "heartbeat"
    case rain = "rain"
    case lullaby = "lullaby"
    case timer30 = "timer_30"
    case timer60 = "timer_60"
    
    var title: String {
        switch self {
        case .whiteNoise: return "Белый шум"
        case .heartbeat: return "Сердцебиение"
        case .rain: return "Дождь"
        case .lullaby: return "Колыбельная"
        case .timer30: return "Сон 30 мин"
        case .timer60: return "Сон 60 мин"
        }
    }
    
    var iconName: String {
        switch self {
        case .whiteNoise: return "speaker.wave.3"
        case .heartbeat: return "heart.fill"
        case .rain: return "cloud.rain.fill"
        case .lullaby: return "music.note"
        case .timer30, .timer60: return "timer"
        }
    }
    
    var soundFileName: String? {
        switch self {
        case .whiteNoise: return "white_noise.mp3"
        case .heartbeat: return "heartbeat.mp3"
        case .rain: return "rain.mp3"
        case .lullaby: return "lullaby.mp3"
        default: return nil
        }
    }
    
    var duration: TimeInterval? {
        switch self {
        case .timer30: return 30 * 60
        case .timer60: return 60 * 60
        default: return nil
        }
    }
}

final class QuickActionsService {
    static let shared = QuickActionsService()
    
    private let audioService: AudioService
    private let sleepService: SleepTrackingService
    private let haptic = UIImpactFeedbackGenerator(style: .light)
    
    private init() {
        self.audioService = AudioService()
        self.sleepService = SleepTrackingService()
    }
    
    func performQuickAction(_ action: QuickActionType, completion: @escaping (Bool) -> Void) {
        haptic.impactOccurred()
        
        switch action {
        case .whiteNoise, .heartbeat, .rain, .lullaby:
            playSound(action, completion: completion)
            
        case .timer30, .timer60:
            startSleepTimer(action, completion: completion)
        }
    }
    
    private func playSound(_ action: QuickActionType, completion: @escaping (Bool) -> Void) {
        guard let fileName = action.soundFileName else {
            completion(false)
            return
        }
        
        audioService.playSound(named: fileName) { success in
            if success {
                AnalyticsService.logQuickActionUsed(action)
            }
            completion(success)
        }
    }
    
    private func startSleepTimer(_ action: QuickActionType, completion: @escaping (Bool) -> Void) {
        guard let duration = action.duration else {
            completion(false)
            return
        }
        
        sleepService.startSleepSession(duration: duration) { success in
            if success {
                AnalyticsService.logQuickActionUsed(action)
                NotificationService.scheduleSleepEndNotification(after: duration)
            }
            completion(success)
        }
    }
    
    func getQuickActions(for child: ChildProfile?) -> [QuickActionType] {
        var actions = QuickActionType.allCases
        
        // Персонализация по возрасту ребенка
        if let child = child {
            let ageInMonths = child.ageInMonths
            
            if ageInMonths < 3 {
                // Новорожденные: приоритет сердцебиению
                actions.sort { $0 == .heartbeat }
            } else if ageInMonths < 12 {
                // Младенцы: приоритет белому шуму
                actions.sort { $0 == .whiteNoise }
            }
        }
        
        return actions
    }
}
