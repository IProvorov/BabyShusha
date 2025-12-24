import Foundation
import Combine

class DataStorageService: ObservableObject {
    // Можно оставить shared для других мест, но для @StateObject нужен public init
    static let shared = DataStorageService()
    
    @Published var sleepSessions: [SleepSession] = []
    @Published var soundPresets: [SoundPreset] = []
    @Published var children: [ChildProfile] = []
    
    private let defaults = UserDefaults.standard
    private let sleepSessionsKey = "sleep_sessions"
    private let soundPresetsKey = "sound_presets"
    private let childrenKey = "children"
    
    // Делаем init public
    public init() {
        loadAllData()
    }
    
    // MARK: - Sleep Sessions
    
    func saveSleepSession(_ session: SleepSession) {
        if let index = sleepSessions.firstIndex(where: { $0.id == session.id }) {
            sleepSessions[index] = session
        } else {
            sleepSessions.append(session)
        }
        saveSleepSessions()
    }
    
    func deleteSleepSession(_ session: SleepSession) {
        sleepSessions.removeAll { $0.id == session.id }
        saveSleepSessions()
    }
    
    func loadSleepSessions(for childId: UUID) -> [SleepSession] {
        return sleepSessions.filter { $0.childId == childId }
            .sorted { $0.startDate > $1.startDate }
    }
    
    func getSleepSessions(for childId: UUID, completion: @escaping ([SleepSession]) -> Void) {
        let sessions = loadSleepSessions(for: childId)
        completion(sessions)
    }
    
    // MARK: - Sound Presets
    
    func saveSoundPreset(_ preset: SoundPreset) {
        if let index = soundPresets.firstIndex(where: { $0.id == preset.id }) {
            soundPresets[index] = preset
        } else {
            soundPresets.append(preset)
        }
        saveSoundPresets()
    }
    
    func deleteSoundPreset(_ preset: SoundPreset) {
        soundPresets.removeAll { $0.id == preset.id }
        saveSoundPresets()
    }
    
    func getSoundPreset(by id: UUID) -> SoundPreset? {
        return soundPresets.first { $0.id == id }
    }
    
    func getAllSoundPresets() -> [SoundPreset] {
        return soundPresets.sorted { $0.isFavorite && !$1.isFavorite }
    }
    
    func getFavoriteSoundPresets() -> [SoundPreset] {
        return soundPresets.filter { $0.isFavorite }
    }
    
    // MARK: - Children
    
    func saveChild(_ child: ChildProfile) {
        if let index = children.firstIndex(where: { $0.id == child.id }) {
            children[index] = child
        } else {
            children.append(child)
        }
        saveChildren()
    }
    
    func deleteChild(_ child: ChildProfile) {
        children.removeAll { $0.id == child.id }
        saveChildren()
    }
    
    func getChild(by id: UUID) -> ChildProfile? {
        return children.first { $0.id == id }
    }
    
    // MARK: - Private Methods
    
    private func loadAllData() {
        loadSleepSessions()
        loadSoundPresets()
        loadChildren()
    }
    
    private func loadSleepSessions() {
        guard let data = defaults.data(forKey: sleepSessionsKey) else {
            sleepSessions = []
            return
        }
        
        do {
            sleepSessions = try JSONDecoder().decode([SleepSession].self, from: data)
        } catch {
            print("Error loading sleep sessions: \(error)")
            sleepSessions = []
        }
    }
    
    private func saveSleepSessions() {
        do {
            let data = try JSONEncoder().encode(sleepSessions)
            defaults.set(data, forKey: sleepSessionsKey)
        } catch {
            print("Error saving sleep sessions: \(error)")
        }
    }
    
    private func loadSoundPresets() {
        guard let data = defaults.data(forKey: soundPresetsKey) else {
            // Создаем дефолтные пресеты при первом запуске
            createDefaultPresets()
            return
        }
        
        do {
            soundPresets = try JSONDecoder().decode([SoundPreset].self, from: data)
        } catch {
            print("Error loading sound presets: \(error)")
            createDefaultPresets()
        }
    }
    
    private func saveSoundPresets() {
        do {
            let data = try JSONEncoder().encode(soundPresets)
            defaults.set(data, forKey: soundPresetsKey)
        } catch {
            print("Error saving sound presets: \(error)")
        }
    }
    
    private func loadChildren() {
        guard let data = defaults.data(forKey: childrenKey) else {
            children = []
            return
        }
        
        do {
            children = try JSONDecoder().decode([ChildProfile].self, from: data)
        } catch {
            print("Error loading children: \(error)")
            children = []
        }
    }
    
    private func saveChildren() {
        do {
            let data = try JSONEncoder().encode(children)
            defaults.set(data, forKey: childrenKey)
        } catch {
            print("Error saving children: \(error)")
        }
    }
    
    private func createDefaultPresets() {
        let defaultPresets = [
            SoundPreset(
                id: UUID(),
                name: "Для новорожденного",
                sounds: [
                    SoundPreset.SoundConfiguration(
                        sound: Sound(name: "Сердцебиение", filename: "heartbeat", type: .heartbeat),
                        isEnabled: true,
                        volume: 0.7
                    ),
                    SoundPreset.SoundConfiguration(
                        sound: Sound(name: "Белый шум", filename: "white_noise", type: .whiteNoise),
                        isEnabled: true,
                        volume: 0.5
                    )
                ],
                isFavorite: true,
                createdAt: Date()
            ),
            SoundPreset(
                id: UUID(),
                name: "Глубокий сон",
                sounds: [
                    SoundPreset.SoundConfiguration(
                        sound: Sound(name: "Дождь", filename: "rain", type: .rain),
                        isEnabled: true,
                        volume: 0.8
                    )
                ],
                isFavorite: true,
                createdAt: Date()
            )
        ]
        
        soundPresets = defaultPresets
        saveSoundPresets()
    }
}
