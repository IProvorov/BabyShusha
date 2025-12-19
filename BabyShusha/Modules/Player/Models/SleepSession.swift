import Foundation

struct SleepSession: Identifiable, Codable {
    let id: UUID
    let childId: UUID // ID ребенка
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval
    let quality: Int? // 1-10
    let notes: String?
    let mood: String?
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        childId: UUID,
        startTime: Date = Date(),
        endTime: Date = Date(),
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
    
    // ... остальные computed properties без изменений
}
