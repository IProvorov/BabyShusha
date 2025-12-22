import Foundation

struct ChildSleepStatistics {
    let childId: UUID
    let totalSessions: Int
    let totalSleepTime: TimeInterval
    let weeklySleepTime: TimeInterval
    let monthlySleepTime: TimeInterval
    
    var totalSleepFormatted: String {
        formatDuration(totalSleepTime)
    }
    
    var weeklySleepFormatted: String {
        formatDuration(weeklySleepTime)
    }
    
    var monthlySleepFormatted: String {
        formatDuration(monthlySleepTime)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return hours > 0 ? "\(hours)ч \(minutes)м" : "\(minutes)м"
    }
}
