import Foundation

struct SleepStatistics {
    let period: String
    let sessions: [SleepSession]
    
    var totalSleepTime: TimeInterval {
        sessions.reduce(0) { $0 + $1.duration }
    }
    
    var averageSleepTime: TimeInterval {
        sessions.isEmpty ? 0 : totalSleepTime / Double(sessions.count)
    }
    
    var totalSleepFormatted: String {
        formatDuration(totalSleepTime)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return hours > 0 ? "\(hours)ч \(minutes)м" : "\(minutes)м"
    }
}
