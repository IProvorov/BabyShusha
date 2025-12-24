import Foundation
import Combine

class SoundPresetService: ObservableObject {
    @Published var presets: [SoundPreset] = []
    
    private let defaults = UserDefaults.standard
    private let presetsKey = "sound_presets"
    
    public init() {
        loadPresets()
    }
    
    // MARK: - CRUD Operations
    
    func createPreset(name: String, soundIds: [UUID], volume: Float = 0.7) -> SoundPreset {
        let soundConfigs = soundIds.map { soundId in
            SoundPreset.SoundConfiguration(
                soundId: soundId,
                isEnabled: true,
                volume: volume
            )
        }
        
        let preset = SoundPreset(
            id: UUID(),
            name: name,
            sounds: soundConfigs,
            isFavorite: false,
            createdAt: Date()
        )
        
        savePreset(preset)
        return preset
    }
    
    func savePreset(_ preset: SoundPreset) {
        if let index = presets.firstIndex(where: { $0.id == preset.id }) {
            presets[index] = preset
        } else {
            presets.append(preset)
        }
        saveAllPresets()
    }
    
    func deletePreset(_ preset: SoundPreset) {
        presets.removeAll { $0.id == preset.id }
        saveAllPresets()
    }
    
    func getPreset(by id: UUID) -> SoundPreset? {
        return presets.first { $0.id == id }
    }
    
    func getAllPresets() -> [SoundPreset] {
        return presets.sorted {
            ($0.isFavorite && !$1.isFavorite) ||
            ($0.createdAt > $1.createdAt)
        }
    }
    
    func getFavoritePresets() -> [SoundPreset] {
        return presets.filter { $0.isFavorite }
    }
    
    func toggleFavorite(_ preset: SoundPreset) {
        if var existingPreset = getPreset(by: preset.id) {
            existingPreset.isFavorite.toggle()
            savePreset(existingPreset)
        }
    }
    
    // MARK: - Audio Playback
    
    func playPreset(_ preset: SoundPreset, audioService: AudioService, availableSounds: [Sound], completion: @escaping (Bool) -> Void) {
        audioService.stopAll()
        
        let enabledConfigs = preset.sounds.filter { $0.isEnabled }
        guard !enabledConfigs.isEmpty else {
            completion(false)
            return
        }
        
        var successfulPlays = 0
        
        for config in enabledConfigs {
            // Находим звук по ID
            if let sound = availableSounds.first(where: { $0.id == config.soundId }) {
                let volume = config.volume
                
                audioService.playSound(named: sound.filename, volume: volume, loop: true) { success in
                    if success {
                        successfulPlays += 1
                    }
                    
                    // Проверяем когда все звуки обработаны
                    if successfulPlays + (enabledConfigs.count - successfulPlays) == enabledConfigs.count {
                        completion(successfulPlays == enabledConfigs.count)
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func loadPresets() {
        guard let data = defaults.data(forKey: presetsKey) else {
            createDefaultPresets()
            return
        }
        
        do {
            presets = try JSONDecoder().decode([SoundPreset].self, from: data)
        } catch {
            print("Error loading presets: \(error)")
            createDefaultPresets()
        }
    }
    
    private func saveAllPresets() {
        do {
            let data = try JSONEncoder().encode(presets)
            defaults.set(data, forKey: presetsKey)
        } catch {
            print("Error saving presets: \(error)")
        }
    }
    
    private func createDefaultPresets() {
        // Создаем дефолтные пресеты
        let defaultPresets = [
            createDefaultNewbornPreset(),
            createDefaultDeepSleepPreset(),
            createDefaultCarRidePreset()
        ]
        
        presets = defaultPresets
        saveAllPresets()
    }
    
    private func createDefaultNewbornPreset() -> SoundPreset {
        // Создаем тестовые ID для звуков
        let heartbeatId = UUID()
        let whiteNoiseId = UUID()
        
        return SoundPreset(
            id: UUID(),
            name: "Для новорожденного",
            sounds: [
                SoundPreset.SoundConfiguration(
                    soundId: heartbeatId,
                    isEnabled: true,
                    volume: 0.7
                ),
                SoundPreset.SoundConfiguration(
                    soundId: whiteNoiseId,
                    isEnabled: true,
                    volume: 0.5
                )
            ],
            isFavorite: true,
            createdAt: Date()
        )
    }
    
    private func createDefaultDeepSleepPreset() -> SoundPreset {
        let rainId = UUID()
        
        return SoundPreset(
            id: UUID(),
            name: "Глубокий сон",
            sounds: [
                SoundPreset.SoundConfiguration(
                    soundId: rainId,
                    isEnabled: true,
                    volume: 0.8
                )
            ],
            isFavorite: true,
            createdAt: Date()
        )
    }
    
    private func createDefaultCarRidePreset() -> SoundPreset {
        let carRideId = UUID()
        
        return SoundPreset(
            id: UUID(),
            name: "Поездка на машине",
            sounds: [
                SoundPreset.SoundConfiguration(
                    soundId: carRideId,
                    isEnabled: true,
                    volume: 0.9
                )
            ],
            isFavorite: false,
            createdAt: Date()
        )
    }
    
    // MARK: - Recommendation Methods
    
    func recommendPresets(for child: ChildProfile?, availableSounds: [Sound]) -> [SoundPreset] {
        let allPresets = getAllPresets()
        
        guard let child = child else { return allPresets }
        
        let ageInMonths = child.ageInMonths
        
        // Фильтруем пресеты по возрасту
        return allPresets.filter { preset in
            // Проверяем, подходят ли звуки в пресете по возрасту
            let suitableSounds = preset.sounds.filter { config in
                // Находим звук по ID
                if let sound = availableSounds.first(where: { $0.id == config.soundId }) {
                    return isSoundSuitableForAge(sound.type, ageInMonths: ageInMonths)
                }
                return true
            }
            
            return !suitableSounds.isEmpty || preset.sounds.isEmpty
        }
    }
    
    private func isSoundSuitableForAge(_ soundType: Sound.SoundType, ageInMonths: Int) -> Bool {
        switch soundType {
        case .heartbeat:
            return ageInMonths <= 6 // Сердцебиение подходит до 6 месяцев
        case .whiteNoise:
            return ageInMonths <= 24 // Белый шум до 2 лет
        case .lullaby:
            return ageInMonths >= 3 // Колыбельные с 3 месяцев
        default:
            return true // Остальные звуки для всех возрастов
        }
    }
}
