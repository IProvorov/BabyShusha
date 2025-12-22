import Foundation

struct SleepSession: Identifiable, Codable {
    let id: UUID
    let childId: UUID
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval
    let quality: Int?
    let notes: String?
    let mood: String?
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        childId: UUID,
        startTime: Date,
        endTime: Date,
        quality: Int? = nil,
        notes: String? = nil,
        mood: String? = nil
    ) {
        self.id = id
        self.childId = childId
        self.startTime = startTime
        self.endTime = endTime
        self.duration = endTime.timeIntervalSince(startTime)
        self.quality = quality
        self.notes = notes
        self.mood = mood
        self.createdAt = Date()
    }
}
