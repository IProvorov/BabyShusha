import Foundation

final class SoundPresetService {
    static let shared = SoundPresetService()
    
    private let userDefaultsKey = "sound_presets"
    private let fileManager = FileManager.default
    private let presetsDirectory: URL
    
    private init() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        presetsDirectory = documentsURL.appendingPathComponent("SoundPresets")
        createPresetsDirectoryIfNeeded()
    }
    
    private func createPresetsDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: presetsDirectory.path) {
            try? fileManager.createDirectory(at: presetsDirectory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - CRUD Operations
    
    func createPreset(name: String, sounds: [SoundType], volume: Float) -> SoundPreset {
        let soundConfigs = sounds.map { type in
            SoundPreset.SoundConfiguration(type: type, isEnabled: true, individualVolume: volume)
        }
        
        let preset = SoundPreset(
            id: UUID(),
            name: name,
            sounds: soundConfigs,
            volume: volume,
            isFavorite: false,
            createdAt: Date()
        )
        
        savePreset(preset)
        return preset
    }
    
    func savePreset(_ preset: SoundPreset) {
        var presets = getAllPresets()
        
        if let index = presets.firstIndex(where: { $0.id == preset.id }) {
            presets[index] = preset
        } else {
            presets.append(preset)
        }
        
        saveAllPresets(presets)
    }
    
    func deletePreset(_ preset: SoundPreset) {
        var presets = getAllPresets()
        presets.removeAll { $0.id == preset.id }
        saveAllPresets(presets)
    }
    
    func getPreset(by id: UUID) -> SoundPreset? {
        return getAllPresets().first { $0.id == id }
    }
    
    func getAllPresets() -> [SoundPreset] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return createDefaultPresets()
        }
        
        do {
            let presets = try JSONDecoder().decode([SoundPreset].self, from: data)
            return presets.sorted { $0.lastUsed ?? $0.createdAt > $1.lastUsed ?? $1.createdAt }
        } catch {
            print("Error decoding presets: \(error)")
            return createDefaultPresets()
        }
    }
    
    func getFavoritePresets() -> [SoundPreset] {
        return getAllPresets().filter { $0.isFavorite }
    }
    
    func markPresetAsUsed(_ preset: SoundPreset) {
        var updatedPreset = preset
        updatedPreset.lastUsed = Date()
        savePreset(updatedPreset)
    }
    
    // MARK: - Default Presets
    
    private func createDefaultPresets() -> [SoundPreset] {
        let defaultPresets = [
            createNewbornPreset(),
            createDeepSleepPreset(),
            createCarRidePreset()
        ]
        
        saveAllPresets(defaultPresets)
        return defaultPresets
    }
    
    private func createNewbornPreset() -> SoundPreset {
        let sounds: [SoundPreset.SoundConfiguration] = [
            .init(type: .heartbeat, isEnabled: true, individualVolume: 0.7),
            .init(type: .whiteNoise, isEnabled: true, individualVolume: 0.5)
        ]
        
        return SoundPreset(
            id: UUID(),
            name: "Для новорожденного",
            sounds: sounds,
            volume: 0.6,
            isFavorite: true,
            createdAt: Date()
        )
    }
    
    private func createDeepSleepPreset() -> SoundPreset {
        let sounds: [SoundPreset.SoundConfiguration] = [
            .init(type: .rain, isEnabled: true, individualVolume: 0.8),
            .init(type: .whiteNoise, isEnabled: false, individualVolume: 0.0)
        ]
        
        return SoundPreset(
            id: UUID(),
            name: "Глубокий сон",
            sounds: sounds,
            volume: 0.5,
            isFavorite: true,
            createdAt: Date()
        )
    }
    
    private func createCarRidePreset() -> SoundPreset {
        let sounds: [SoundPreset.SoundConfiguration] = [
            .init(type: .carRide, isEnabled: true, individualVolume: 0.9)
        ]
        
        return SoundPreset(
            id: UUID(),
            name: "Поездка на машине",
            sounds: sounds,
            volume: 0.7,
            isFavorite: false,
            createdAt: Date()
        )
    }
    
    private func saveAllPresets(_ presets: [SoundPreset]) {
        do {
            let data = try JSONEncoder().encode(presets)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Error encoding presets: \(error)")
        }
    }
    
    // MARK: - Preset Recommendations
    
    func recommendPresets(for child: ChildProfile?) -> [SoundPreset] {
        let allPresets = getAllPresets()
        guard let child = child else { return allPresets }
        
        let ageInMonths = child.ageInMonths
        
        return allPresets.filter { preset in
            // Проверяем, подходят ли звуки в пресете по возрасту
            let suitableSounds = preset.sounds.filter { config in
                guard let ageRange = config.type.recommendedForAge else { return true }
                return ageRange.contains(ageInMonths)
            }
            
            return !suitableSounds.isEmpty || preset.sounds.isEmpty
        }
    }
    
    // MARK: - Audio Playback
    
    func playPreset(_ preset: SoundPreset, completion: @escaping (Bool) -> Void) {
        let audioService = AudioService.shared
        
        // Останавливаем текущее воспроизведение
        audioService.stopAll()
        
        // Запускаем все звуки из пресета
        let enabledSounds = preset.sounds.filter { $0.isEnabled }
        
        guard !enabledSounds.isEmpty else {
            completion(false)
            return
        }
        
        var successfulPlays = 0
        
        for soundConfig in enabledSounds {
            let volume = preset.volume * soundConfig.individualVolume
            
            audioService.playSound(
                named: soundConfig.type.fileName,
                volume: volume,
                loop: true
            ) { success in
                if success {
                    successfulPlays += 1
                }
                
                // Когда все звуки обработаны
                if successfulPlays + (enabledSounds.count - successfulPlays) == enabledSounds.count {
                    let allSuccessful = successfulPlays == enabledSounds.count
                    
                    if allSuccessful {
                        self.markPresetAsUsed(preset)
                        AnalyticsService.logPresetUsed(preset)
                    }
                    
                    completion(allSuccessful)
                }
            }
        }
    }
}
