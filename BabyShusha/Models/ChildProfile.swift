import Foundation

struct ChildProfile: Identifiable, Codable {
    let id: UUID
    let name: String
    let birthDate: Date
    let avatarEmoji: String
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        birthDate: Date,
        avatarEmoji: String = "👶"
    ) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.avatarEmoji = avatarEmoji
        self.createdAt = Date()
    }
    
    var ageDescription: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: birthDate, to: Date())
        let years = components.year ?? 0
        let months = components.month ?? 0
        
        if years == 0 {
            return "\(months) мес"
        } else if months == 0 {
            return "\(years) год"
        } else {
            return "\(years) год \(months) мес"
        }
    }
}
