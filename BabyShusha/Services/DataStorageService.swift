import Foundation

class DataStorageService {
    static let shared = DataStorageService()
    
    private let userDefaults = UserDefaults.standard
    private let sleepSessionsKey = "sleep_sessions"
    private let childProfilesKey = "child_profiles"
    private let activeChildIdKey = "active_child_id"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Sleep Sessions
    
    func saveSleepSession(_ session: SleepSession) {
        var sessions = loadSleepSessions()
        sessions.append(session)
        saveSleepSessions(sessions)
    }
    
    func loadSleepSessions() -> [SleepSession] {
        guard let data = userDefaults.data(forKey: sleepSessionsKey) else {
            return []
        }
        
        do {
            return try decoder.decode([SleepSession].self, from: data)
        } catch {
            print("Error loading sleep sessions: \(error)")
            return []
        }
    }
    
    func loadSleepSessions(for childId: UUID) -> [SleepSession] {
        let allSessions = loadSleepSessions()
        return allSessions.filter { $0.childId == childId }
    }
    
    func deleteSleepSession(_ session: SleepSession) {
        var sessions = loadSleepSessions()
        sessions.removeAll { $0.id == session.id }
        saveSleepSessions(sessions)
    }
    
    private func saveSleepSessions(_ sessions: [SleepSession]) {
        do {
            let data = try encoder.encode(sessions)
            userDefaults.set(data, forKey: sleepSessionsKey)
        } catch {
            print("Error saving sleep sessions: \(error)")
        }
    }
    
    // MARK: - Child Profiles
    
    func saveChildProfile(_ profile: ChildProfile) {
        var profiles = loadChildProfiles()
        
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index] = profile
        } else {
            profiles.append(profile)
        }
        
        saveChildProfiles(profiles)
    }
    
    func loadChildProfiles() -> [ChildProfile] {
        guard let data = userDefaults.data(forKey: childProfilesKey) else {
            return []
        }
        
        do {
            return try decoder.decode([ChildProfile].self, from: data)
        } catch {
            print("Error loading child profiles: \(error)")
            return []
        }
    }
    
    func deleteChildProfile(_ profile: ChildProfile) {
        var profiles = loadChildProfiles()
        profiles.removeAll { $0.id == profile.id }
        saveChildProfiles(profiles)
        
        if getActiveChildId() == profile.id {
            clearActiveChildProfile()
        }
    }
    
    func getActiveChildProfile() -> ChildProfile? {
        guard let activeId = getActiveChildId() else {
            return nil
        }
        return loadChildProfiles().first { $0.id == activeId }
    }
    
    func setActiveChildProfile(_ profile: ChildProfile) {
        setActiveChildId(profile.id)
    }
    
    func clearActiveChildProfile() {
        userDefaults.removeObject(forKey: activeChildIdKey)
    }
    
    private func saveChildProfiles(_ profiles: [ChildProfile]) {
        do {
            let data = try encoder.encode(profiles)
            userDefaults.set(data, forKey: childProfilesKey)
        } catch {
            print("Error saving child profiles: \(error)")
        }
    }
    
    private func getActiveChildId() -> UUID? {
        guard let uuidString = userDefaults.string(forKey: activeChildIdKey) else {
            return nil
        }
        return UUID(uuidString: uuidString)
    }
    
    private func setActiveChildId(_ id: UUID) {
        userDefaults.set(id.uuidString, forKey: activeChildIdKey)
    }
    
    // MARK: - Data Management
    
    func clearAllData() {
        userDefaults.removeObject(forKey: sleepSessionsKey)
        userDefaults.removeObject(forKey: childProfilesKey)
        userDefaults.removeObject(forKey: activeChildIdKey)
    }
}
