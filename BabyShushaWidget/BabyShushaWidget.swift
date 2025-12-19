import WidgetKit
import SwiftUI
import Intents

// Модель для хранения состояния
struct SoundSetting: Codable {
    let name: String
    let fileName: String
    let isPlaying: Bool
    let volume: Float
}

// Провайдер для виджета
struct Provider: TimelineProvider {
    // Placeholder - для предпросмотра
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), sound: SoundSetting(name: "Белый шум", fileName: "white_noise", isPlaying: false, volume: 0.5))
    }

    // Снимок для виджета
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), sound: SoundSetting(name: "Белый шум", fileName: "white_noise", isPlaying: false, volume: 0.5))
        completion(entry)
    }

    // Таймлайн - когда обновлять виджет
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Текущая дата
        let currentDate = Date()
        
        // Загружаем текущие настройки из UserDefaults
        let sound = loadCurrentSound()
        
        // Создаем entry
        let entry = SimpleEntry(date: currentDate, sound: sound)
        entries.append(entry)
        
        // Создаем timeline (обновляем каждые 15 минут или при изменении)
        let timeline = Timeline(entries: entries, policy: .after(Date().addingTimeInterval(60 * 15)))
        completion(timeline)
    }
    
    // Загрузка текущих настроек
    private func loadCurrentSound() -> SoundSetting {
        // Пытаемся загрузить из UserDefaults (общие для приложения и виджета)
        if let data = UserDefaults(suiteName: "group.com.yourname.BabyShusha")?.data(forKey: "currentSound"),
           let sound = try? JSONDecoder().decode(SoundSetting.self, from: data) {
            return sound
        }
        
        // Если нет сохраненных данных - используем дефолтные
        return SoundSetting(name: "Белый шум", fileName: "white_noise", isPlaying: false, volume: 0.5)
    }
}

// Entry для виджета
struct SimpleEntry: TimelineEntry {
    let date: Date
    let sound: SoundSetting
}

// View виджета
struct BabyShushaWidgetEntryView: View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        ZStack {
            // Фон виджета
            ContainerRelativeShape()
                .fill(Color.black.gradient)
            
            VStack(spacing: 8) {
                // Иконка и заголовок
                HStack {
                    Image(systemName: entry.sound.isPlaying ? "speaker.wave.3.fill" : "speaker.slash.fill")
                        .font(.system(size: widgetFamily == .systemSmall ? 16 : 20))
                        .foregroundColor(entry.sound.isPlaying ? .green : .gray)
                    
                    Text("Baby Shusha")
                        .font(.system(size: widgetFamily == .systemSmall ? 12 : 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Основная информация
                VStack(spacing: 4) {
                    Text(entry.sound.name)
                        .font(.system(size: widgetFamily == .systemSmall ? 14 : 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(entry.sound.isPlaying ? "Играет • \(Int(entry.sound.volume * 100))%" : "Готов к запуску")
                        .font(.system(size: widgetFamily == .systemSmall ? 10 : 12))
                        .foregroundColor(entry.sound.isPlaying ? .green : .gray)
                }
                
                // Кнопка действия
                Link(destination: URL(string: "babyshusha://play")!) {
                    HStack {
                        Image(systemName: entry.sound.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                            .font(.system(size: widgetFamily == .systemSmall ? 20 : 24))
                        
                        Text(entry.sound.isPlaying ? "Остановить" : "Запустить")
                            .font(.system(size: widgetFamily == .systemSmall ? 12 : 14, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(entry.sound.isPlaying ? Color.red.opacity(0.8) : Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
    }
}

// Основная структура виджета
struct BabyShushaWidget: Widget {
    let kind: String = "BabyShushaWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BabyShushaWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Белый шум")
        .description("Быстрый запуск белого шума для сна")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// Предпросмотр
struct BabyShushaWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BabyShushaWidgetEntryView(
                entry: SimpleEntry(
                    date: Date(),
                    sound: SoundSetting(name: "Белый шум", fileName: "white_noise", isPlaying: false, volume: 0.5)
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            BabyShushaWidgetEntryView(
                entry: SimpleEntry(
                    date: Date(),
                    sound: SoundSetting(name: "Дождь", fileName: "rain", isPlaying: true, volume: 0.7)
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
