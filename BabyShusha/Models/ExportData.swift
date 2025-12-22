import Foundation

struct ExportData: Codable {
    let sleepSessions: [SleepSession]
    let childProfiles: [ChildProfile]
    let activeChildId: String?
}
