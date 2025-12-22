// Views/SoundSelectionView.swift
import SwiftUI

struct SoundSelectionView: View {
    @EnvironmentObject var soundVM: SoundPlayerViewModel
    @State private var showVolumeControls = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Панель управления
                ControlPanelView()
                    .padding()
                
                // Список звуков по категориям
                List {
                    ForEach(SoundCategory.allCases, id: \.self) { category in
                        Section(category.rawValue) {
                            let categorySounds = soundVM.sounds.filter { $0.category == category }
                            ForEach(categorySounds) { sound in
                                SoundRowView(sound: sound)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Звуки для сна")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        soundVM.stopAll()
                    }) {
                        Image(systemName: "stop.circle")
                            .font(.title2)
                    }
                }
            }
        }
    }
}

// Компонент строки звука
struct SoundRowView: View {
    @EnvironmentObject var soundVM: SoundPlayerViewModel
    let sound: Sound
    @State private var showVolumeSlider = false
    @State private var currentVolume: Float
    
    init(sound: Sound) {
        self.sound = sound
        _currentVolume = State(initialValue: sound.volume)
    }
    
    var isSelected: Bool {
        soundVM.selectedSounds.contains(where: { $0.id == sound.id })
    }
    
    var body: some View {
        HStack {
            // Иконка
            Image(systemName: sound.icon)
                .font(.title2)
                .foregroundColor(isSelected ? .blue : .gray)
                .frame(width: 40)
            
            // Название
            VStack(alignment: .leading) {
                Text(sound.name)
                    .font(.headline)
                if sound.isPremium {
                    Text("Premium")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            // Управление
            if showVolumeSlider {
                Slider(value: $currentVolume, in: 0...1, step: 0.1)
                    .frame(width: 100)
                    .onChange(of: currentVolume) { newValue in
                        soundVM.updateVolume(for: sound, volume: newValue)
                    }
            }
            
            Button(action: {
                withAnimation {
                    showVolumeSlider.toggle()
                }
            }) {
                Image(systemName: "speaker.wave.2")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            
            Button(action: {
                soundVM.toggleSound(sound)
            }) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
        }
        .padding(.vertical, 4)
    }
}

// Панель управления
struct ControlPanelView: View {
    @EnvironmentObject var soundVM: SoundPlayerViewModel
    @State private var masterVolume: Float = 0.5
    
    var body: some View {
        VStack(spacing: 15) {
            // Кнопка play/pause
            Button(action: {
                soundVM.togglePlayback()
            }) {
                Image(systemName: soundVM.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(soundVM.isPlaying ? .red : .green)
            }
            
            // Громкость
            HStack {
                Image(systemName: "speaker.fill")
                    .foregroundColor(.gray)
                Slider(value: $masterVolume, in: 0...1, step: 0.1)
                    .onChange(of: masterVolume) { newValue in
                        soundVM.updateMasterVolume(newValue)
                    }
                Image(systemName: "speaker.wave.3.fill")
                    .foregroundColor(.gray)
            }
            
            // Выбранные звуки
            if !soundVM.selectedSounds.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(soundVM.selectedSounds) { sound in
                            VStack {
                                Image(systemName: sound.icon)
                                    .font(.title3)
                                    .foregroundColor(.blue)
                                Text(sound.name)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.top, 5)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(15)
    }
}
