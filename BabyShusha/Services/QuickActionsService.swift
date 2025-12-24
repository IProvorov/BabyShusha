import Foundation
import Combine

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
    
    // Убираем soundType или делаем опциональным
    var soundType: SoundType? {
        switch self {
        case .whiteNoise: return .whiteNoise
        case .heartbeat: return .heartbeat
        case .rain: return .rain
        case .lullaby: return .lullaby
        default: return nil
        }
    }
    
    // Добавляем тип SoundType
    enum SoundType: String {
        case whiteNoise, heartbeat, rain, lullaby
    }
}

class QuickActionsService: ObservableObject {
    @Published var lastAction: QuickActionType? = nil
    @Published var isActionInProgress = false
    @Published var availableActions: [QuickActionType] = []
    
    private let audioService: AudioService
    private var cancellables = Set<AnyCancellable>()
    
    // Инициализатор с дефолтным значением
    public init(audioService: AudioService = AudioService.shared) {
        self.audioService = audioService
        self.availableActions = QuickActionType.allCases
    }
    
    func performQuickAction(_ action: QuickActionType, completion: @escaping (Bool) -> Void) {
        guard !isActionInProgress else {
            completion(false)
            return
        }
        
        isActionInProgress = true
        lastAction = action
        
        switch action {
        case .whiteNoise, .heartbeat, .rain, .lullaby:
            if let soundType = action.soundType {
                playSound(soundType: soundType, action: action, completion: completion)
            } else {
                isActionInProgress = false
                completion(false)
            }
            
        case .timer30, .timer60:
            startSleepTimer(action, completion: completion)
        }
    }
    
    private func playSound(soundType: QuickActionType.SoundType, action: QuickActionType, completion: @escaping (Bool) -> Void) {
        let fileName: String
        
        switch soundType {
        case .whiteNoise: fileName = "white_noise"
        case .heartbeat: fileName = "heartbeat"
        case .rain: fileName = "rain"
        case .lullaby: fileName = "lullaby"
        }
        
        audioService.playSound(named: fileName, volume: 0.7, loop: true) { [weak self] success in
            DispatchQueue.main.async {
                self?.isActionInProgress = false
                completion(success)
            }
        }
    }
    
    private func startSleepTimer(_ action: QuickActionType, completion: @escaping (Bool) -> Void) {
        let duration: TimeInterval = action == .timer30 ? 30 * 60 : 60 * 60
        
        print("Таймер сна на \(Int(duration/60)) минут запущен")
        
        // Здесь можно добавить вызов SleepTrackerViewModel
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isActionInProgress = false
            completion(true)
        }
    }
    
    func stopCurrentAction() {
        audioService.stopAll()
        isActionInProgress = false
        lastAction = nil
    }
    
    func getQuickActions(for child: ChildProfile? = nil) -> [QuickActionType] {
        return QuickActionType.allCases
    }
}
