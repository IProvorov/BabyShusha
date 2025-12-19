import Foundation

struct SleepStatistics {
    let period: String // "week", "month", "year"
    let sessions: [SleepSession]
    
    var totalSleepTime: TimeInterval {
        sessions.reduce(0) { $0 + $1.duration }
    }
    
    var averageSleepPerDay: TimeInterval {
        guard !sessions.isEmpty else { return 0 }
        return totalSleepTime / Double(sessions.count)
    }
    
    var averageQuality: Double {
        let qualities = sessions.compactMap { $0.quality }
        guard !qualities.isEmpty else { return 0 }
        return Double(qualities.reduce(0, +)) / Double(qualities.count)
    }
    
    var longestSession: SleepSession? {
        sessions.max(by: { $0.duration < $1.duration })
    }
    
    var shortestSession: SleepSession? {
        sessions.min(by: { $0.duration < $1.duration })
    }
    
    var totalSleepFormatted: String {
        formatDuration(totalSleepTime)
    }
    
    var averageSleepFormatted: String {
        formatDuration(averageSleepPerDay)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)ч \(minutes)м"
        } else {
            return "\(minutes)м"
        }
    }
    
    var sleepByDayOfWeek: [String: TimeInterval] {
        var result: [String: TimeInterval] = [:]
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE"
        
        for session in sessions {
            let day = formatter.string(from: session.startTime)
            result[day, default: 0] += session.duration
        }
        
        return result
    }
}
