import Foundation

struct CurrentSleepSession {
    let id: UUID
    let childId: UUID
    let startTime: Date
    var quality: Int?
    var notes: String?
    var mood: String?
    
    init(
        childId: UUID,
        startTime: Date = Date(),
        quality: Int? = nil,
        notes: String? = nil,
        mood: String? = nil
    ) {
        self.id = UUID()
        self.childId = childId
        self.startTime = startTime
        self.quality = quality
        self.notes = notes
        self.mood = mood
    }
}
