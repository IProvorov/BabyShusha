// Extensions/SleepSession+Formatters.swift
import Foundation

extension SleepSession {
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: startTime)
    }
    
    var timeRangeString: String {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.locale = Locale(identifier: "ru_RU")
        
        return "\(timeFormatter.string(from: startTime)) - \(timeFormatter.string(from: endTime))"
    }
    
    var durationString: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)ч \(minutes)м"
        } else {
            return "\(minutes)м"
        }
    }
    
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: startTime).capitalized
    }
    
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: startTime)
    }
    
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: startTime).capitalized
    }
    
    var qualityString: String {
        guard let quality = quality else { return "Нет оценки" }
        return "\(quality)/10"
    }
    
    var moodEmoji: String {
        switch mood?.lowercased() {
        case "happy", "счастливый", "довольный":
            return "😊"
        case "calm", "спокойный", "умиротворенный":
            return "😌"
        case "tired", "уставший", "утомленный":
            return "😴"
        case "restless", "беспокойный", "неспокойный":
            return "😟"
        case "sick", "больной", "нездоровый":
            return "🤒"
        default:
            return "😐"
        }
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(startTime)
    }
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(startTime)
    }
    
    var relativeDateString: String {
        if isToday {
            return "Сегодня"
        } else if isYesterday {
            return "Вчера"
        } else {
            let formatter = RelativeDateTimeFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.unitsStyle = .full
            return formatter.localizedString(for: startTime, relativeTo: Date())
        }
    }
}
