// Views/SleepTrackerView.swift
import SwiftUI



struct SleepTrackerView: View {
    @EnvironmentObject var viewModel: SleepTrackerViewModel
    @EnvironmentObject var childProfileVM: ChildProfileViewModel
    @EnvironmentObject var soundVM: SoundPlayerViewModel
    
    @State private var showQualitySheet = false
    @State private var showNotesSheet = false
    @State private var showMoodSheet = false
    @State private var showSoundQuickAccess = false
    @State private var selectedQuality: Int = 8
    @State private var notesText: String = ""
    @State private var selectedMood: String = "Спокойный"
    
    
    
    let moods = ["Счастливый", "Спокойный", "Уставший", "Беспокойный", "Больной"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Заголовок
                    headerSection
                    
                    // Информация о ребенке
                    childInfoSection
                    
                    // Таймер
                    timerSection
                    
                    // Быстрый доступ к звукам
                    soundQuickAccessSection
                    
                    // Контроль качества сна
                    sleepQualitySection
                    
                    // Кнопка старт/стоп
                    trackingButtonSection
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .sheet(isPresented: $showQualitySheet) {
                qualitySelectionSheet
            }
            .sheet(isPresented: $showNotesSheet) {
                notesInputSheet
            }
            .sheet(isPresented: $showMoodSheet) {
                moodSelectionSheet
            }
            .sheet(isPresented: $showSoundQuickAccess) {
                SoundQuickAccessView()
                    .environmentObject(soundVM)
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Отслеживание сна")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            Text(viewModel.isTracking ? "Сон в процессе..." : "Готов к отслеживанию")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var childInfoSection: some View {
        Group {
            if let activeChild = childProfileVM.activeChild {
                HStack(spacing: 15) {
                    // Аватар
                    Text(activeChild.avatarEmoji)
                        .font(.system(size: 50))
                        .frame(width: 70, height: 70)
                        .background(
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        )
                    
                    // Информация
                    VStack(alignment: .leading, spacing: 4) {
                        Text(activeChild.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(activeChild.ageDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "bed.double.fill")
                                .font(.caption)
                            Text("Режим сна")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    // Индикатор активности
                    Circle()
                        .fill(viewModel.isTracking ? Color.green : Color.gray)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                )
            } else {
                VStack(spacing: 15) {
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    
                    Text("Ребенок не выбран")
                        .font(.headline)
                    
                    Text("Перейдите в профиль, чтобы добавить или выбрать ребенка для отслеживания сна")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                )
            }
        }
    }
    
    private var timerSection: some View {
        VStack(spacing: 10) {
            Text(viewModel.isTracking ? "Длительность сна" : "Таймер сна")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(viewModel.elapsedTime)
                .font(.system(size: 56, weight: .bold, design: .monospaced))
                .foregroundColor(viewModel.isTracking ? .blue : .gray)
                .frame(height: 70)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                )
            
            if viewModel.isTracking {
                Text("Начало: \(viewModel.currentSession?.startTime.formatted(date: .omitted, time: .shortened) ?? "--:--")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var soundQuickAccessSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Звуки для сна")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    showSoundQuickAccess = true
                }) {
                    Image(systemName: "plus")
                        .font(.caption)
                        .padding(6)
                        .background(Circle().fill(Color.blue.opacity(0.1)))
                }
            }
            
            if soundVM.selectedSounds.isEmpty {
                HStack {
                    Image(systemName: "speaker.slash")
                        .foregroundColor(.gray)
                    Text("Нет выбранных звуков")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(soundVM.selectedSounds) { sound in
                            SoundCapsuleView(sound: sound)
                                .environmentObject(soundVM)
                        }
                    }
                }
            }
            
            // Контроль громкости
            if !soundVM.selectedSounds.isEmpty {
                HStack {
                    Image(systemName: "speaker.fill")
                        .foregroundColor(.gray)
                        .frame(width: 24)
                    
                    Slider(value: $soundVM.masterVolume, in: 0...1)
                        .onChange(of: soundVM.masterVolume) { newValue in
                            soundVM.updateMasterVolume(newValue)
                        }
                    
                    Image(systemName: "speaker.wave.3.fill")
                        .foregroundColor(.gray)
                        .frame(width: 24)
                    
                    Button(action: {
                        soundVM.togglePlayback()
                    }) {
                        Image(systemName: soundVM.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.title3)
                            .foregroundColor(soundVM.isPlaying ? .red : .green)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var sleepQualitySection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Детали сна")
                .font(.headline)
            
            HStack(spacing: 15) {
                // Качество сна
                Button(action: {
                    showQualitySheet = true
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.title2)
                            .foregroundColor(viewModel.currentSession?.quality != nil ? .yellow : .gray)
                        Text("Качество")
                            .font(.caption)
                        if let quality = viewModel.currentSession?.quality {
                            Text("\(quality)/10")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Не оценено")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
                    )
                }
                
                // Заметки
                Button(action: {
                    showNotesSheet = true
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: "note.text")
                            .font(.title2)
                            .foregroundColor(viewModel.currentSession?.notes != nil ? .blue : .gray)
                        Text("Заметки")
                            .font(.caption)
                        Text(viewModel.currentSession?.notes != nil ? "Есть" : "Нет")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
                    )
                }
                
                // Настроение
                Button(action: {
                    showMoodSheet = true
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: "face.smiling")
                            .font(.title2)
                            .foregroundColor(viewModel.currentSession?.mood != nil ? .green : .gray)
                        Text("Настроение")
                            .font(.caption)
                        Text(viewModel.currentSession?.mood ?? "Не указано")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var trackingButtonSection: some View {
        Button(action: {
            viewModel.toggleTracking()
        }) {
            HStack(spacing: 12) {
                Image(systemName: viewModel.isTracking ? "stop.fill" : "play.fill")
                    .font(.title2)
                
                Text(viewModel.isTracking ? "Завершить сон" : "Начать отслеживание сна")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: viewModel.isTracking ?
                                      [Color.red, Color.red.opacity(0.8)] :
                                      [Color.blue, Color.purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .cornerRadius(20)
                .shadow(color: viewModel.isTracking ? .red.opacity(0.3) : .blue.opacity(0.3),
                       radius: 10, x: 0, y: 5)
            )
        }
        .disabled(childProfileVM.activeChild == nil)
        .opacity(childProfileVM.activeChild == nil ? 0.6 : 1)
        .padding(.top, 20)
    }
    
    // MARK: - Sheets
    
    private var qualitySelectionSheet: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Оцените качество сна")
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.top)
                
                // Рейтинг звездами
                HStack(spacing: 8) {
                    ForEach(1...10, id: \.self) { number in
                        Button(action: {
                            selectedQuality = number
                            viewModel.currentSession?.quality = number
                        }) {
                            Image(systemName: number <= selectedQuality ? "star.fill" : "star")
                                .font(.system(size: 40))
                                .foregroundColor(number <= selectedQuality ? .yellow : .gray)
                        }
                    }
                }
                
                // Описание качества
                VStack(spacing: 10) {
                    Text("\(selectedQuality)/10")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(qualityColor)
                    
                    Text(qualityDescription)
                        .font(.headline)
                        .foregroundColor(qualityColor)
                    
                    Text(qualityDetail)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                Button(action: {
                    showQualitySheet = false
                }) {
                    Text("Готово")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.cornerRadius(15))
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Качество сна")
            .navigationBarItems(trailing: Button("Отмена") {
                showQualitySheet = false
            })
        }
    }
    
    private var notesInputSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Добавьте заметки о сне")
                    .font(.title3)
                    .fontWeight(.medium)
                    .padding(.top)
                
                TextEditor(text: $notesText)
                    .frame(height: 200)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .onChange(of: notesText) { newValue in
                        viewModel.currentSession?.notes = newValue.isEmpty ? nil : newValue
                    }
                
                Text("Примеры: 'Беспокойно ворочался', 'Проснулся 2 раза', 'Спал очень крепко'")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    viewModel.currentSession?.notes = notesText.isEmpty ? nil : notesText
                    showNotesSheet = false
                }) {
                    Text("Сохранить заметки")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.cornerRadius(15))
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Заметки")
            .navigationBarItems(
                leading: Button("Очистить") {
                    notesText = ""
                    viewModel.currentSession?.notes = nil
                }
                .foregroundColor(.red),
                trailing: Button("Готово") {
                    showNotesSheet = false
                }
            )
        }
    }
    
    private var moodSelectionSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Как настроение после сна?")
                    .font(.title3)
                    .fontWeight(.medium)
                    .padding(.top)
                
                ForEach(moods, id: \.self) { mood in
                    Button(action: {
                        selectedMood = mood
                        viewModel.currentSession?.mood = mood
                    }) {
                        HStack {
                            Text(moodEmoji(for: mood))
                                .font(.title2)
                            Text(mood)
                                .font(.headline)
                            Spacer()
                            if selectedMood == mood {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedMood == mood ? Color.blue.opacity(0.1) : Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedMood == mood ? Color.blue : Color.clear, lineWidth: 2)
                        )
                    }
                    .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: {
                    showMoodSheet = false
                }) {
                    Text("Выбрать")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.cornerRadius(15))
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Настроение")
            .navigationBarItems(trailing: Button("Отмена") {
                showMoodSheet = false
            })
        }
    }
    
    // MARK: - Helper Computed Properties
    
    private var qualityColor: Color {
        switch selectedQuality {
        case 1...3: return .red
        case 4...6: return .orange
        case 7...8: return .yellow
        case 9...10: return .green
        default: return .gray
        }
    }
    
    private var qualityDescription: String {
        switch selectedQuality {
        case 1...3: return "Плохой сон"
        case 4...6: return "Средний сон"
        case 7...8: return "Хороший сон"
        case 9...10: return "Отличный сон"
        default: return "Не оценено"
        }
    }
    
    private var qualityDetail: String {
        switch selectedQuality {
        case 1...3: return "Частые пробуждения, беспокойный сон"
        case 4...6: return "Некоторые пробуждения, среднее качество"
        case 7...8: return "Крепкий сон с минимальными пробуждениями"
        case 9...10: return "Идеальный непрерывный сон"
        default: return ""
        }
    }
    
    private func moodEmoji(for mood: String) -> String {
        switch mood {
        case "Счастливый": return "😊"
        case "Спокойный": return "😌"
        case "Уставший": return "😴"
        case "Беспокойный": return "😟"
        case "Больной": return "🤒"
        default: return "😐"
        }
    }
}

// MARK: - Supporting Views

struct SoundCapsuleView: View {
    @EnvironmentObject var soundVM: SoundPlayerViewModel
    let sound: Sound
    @State private var showVolumeControl = false
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: sound.icon)
                .font(.callout)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(sound.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if showVolumeControl {
                    Slider(value: Binding(
                        get: { sound.volume },
                        set: { newValue in
                            soundVM.updateVolume(for: sound, volume: newValue)
                        }
                    ), in: 0...1)
                    .frame(width: 80)
                }
            }
            
            Button(action: {
                withAnimation {
                    showVolumeControl.toggle()
                }
            }) {
                Image(systemName: showVolumeControl ? "speaker.wave.2.fill" : "speaker.fill")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
            
            Button(action: {
                soundVM.toggleSound(sound)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.blue.opacity(0.1))
        )
    }
}

struct SoundQuickAccessView: View {
    @EnvironmentObject var soundVM: SoundPlayerViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let popularSounds = [
        Sound(name: "Белый шум", icon: "wind", filename: "white_noise"),
        Sound(name: "Сердцебиение", icon: "heart.fill", filename: "heartbeat"),
        Sound(name: "Дождь", icon: "cloud.rain", filename: "rain"),
        Sound(name: "Волны", icon: "water.waves", filename: "waves"),
        Sound(name: "Вентилятор", icon: "fan", filename: "fan"),
        Sound(name: "Леса", icon: "leaf", filename: "forest")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Популярные звуки")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 15)], spacing: 15) {
                        ForEach(popularSounds) { sound in
                            SoundQuickAccessButton(sound: sound)
                                .environmentObject(soundVM)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Быстрый выбор")
            .navigationBarItems(trailing: Button("Готово") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct SoundQuickAccessButton: View {
    @EnvironmentObject var soundVM: SoundPlayerViewModel
    let sound: Sound
    
    var isSelected: Bool {
        soundVM.selectedSounds.contains(where: { $0.id == sound.id })
    }
    
    var body: some View {
        Button(action: {
            soundVM.toggleSound(sound)
        }) {
            VStack(spacing: 10) {
                Image(systemName: sound.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .primary)
                
                Text(sound.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .blue : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 100, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
    }
}
