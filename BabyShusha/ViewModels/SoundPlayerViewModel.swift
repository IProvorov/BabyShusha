// ViewModels/SoundPlayerViewModel.swift
import Foundation
import Combine

class SoundPlayerViewModel: ObservableObject {
    @Published var sounds: [Sound] = []
    @Published var selectedSounds: [Sound] = []
    @Published var isPlaying = false
    @Published var masterVolume: Float = 0.5
    
    private let audioService: AudioService
    private var cancellables = Set<AnyCancellable>()
    
    init(audioService: AudioService = AudioService.shared) {
        self.audioService = audioService
        loadDefaultSounds()
        setupAudioObservers()
    }
    
    // MARK: - Sound Management
    
    private func loadDefaultSounds() {
        sounds = [
            Sound(
                id: UUID(),
                name: "Белый шум",
                filename: "white_noise.mp3",
                type: .whiteNoise,
                iconName: "speaker.wave.3",
                volume: 0.7
            ),
            Sound(
                id: UUID(),
                name: "Сердцебиение",
                filename: "heartbeat.mp3",
                type: .heartbeat,
                iconName: "heart.fill",
                volume: 0.6
            ),
            Sound(
                id: UUID(),
                name: "Дождь",
                filename: "rain.mp3",
                type: .rain,
                iconName: "cloud.rain.fill",
                volume: 0.8
            ),
            Sound(
                id: UUID(),
                name: "Колыбельная",
                filename: "lullaby.mp3",
                type: .lullaby,
                iconName: "music.note",
                volume: 0.5
            ),
            Sound(
                id: UUID(),
                name: "Волны",
                filename: "waves.mp3",
                type: .nature,
                iconName: "water.waves",
                volume: 0.7
            ),
            Sound(
                id: UUID(),
                name: "Вентилятор",
                filename: "fan.mp3",
                type: .whiteNoise,
                iconName: "fan",
                volume: 0.6
            ),
            Sound(
                id: UUID(),
                name: "Леса",
                filename: "forest.mp3",
                type: .nature,
                iconName: "leaf.fill",
                volume: 0.5
            )
        ]
    }
    
    private func setupAudioObservers() {
        audioService.$isPlaying
            .receive(on: RunLoop.main)
            .assign(to: \.isPlaying, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Playback Control
    
    func toggleSound(_ sound: Sound) {
        if let index = selectedSounds.firstIndex(where: { $0.id == sound.id }) {
            // Отключаем звук
            selectedSounds.remove(at: index)
            stopSound(sound)
        } else {
            // Включаем звук
            var updatedSound = sound
            updatedSound.volume = updatedSound.volume * masterVolume
            selectedSounds.append(updatedSound)
            playSound(updatedSound)
        }
        
        updateIsPlayingState()
    }
    
    func playSound(_ sound: Sound) {
        let volume = sound.volume * masterVolume
        audioService.playSound(named: sound.filename, volume: volume, loop: true) { success in
            if success {
                print("Воспроизведение звука: \(sound.name)")
            }
        }
    }
    
    func stopSound(_ sound: Sound) {
        // В AudioService нет отдельного метода stopSound, поэтому просто перестаем воспроизводить
        // В реальности нужно будет остановить конкретный звук
        print("Остановка звука: \(sound.name)")
    }
    
    func togglePlayback() {
        if isPlaying {
            stopAll()
        } else {
            startPlayback()
        }
    }
    
    func startPlayback() {
        guard !selectedSounds.isEmpty else { return }
        
        for sound in selectedSounds {
            let volume = sound.volume * masterVolume
            audioService.playSound(named: sound.filename, volume: volume, loop: true) { _ in }
        }
        
        isPlaying = true
    }
    
    func stopAll() {
        audioService.stopAll()
        isPlaying = false
    }
    
    // MARK: - Volume Control
    
    func updateVolume(for soundId: UUID, volume: Float) {
        // Обновляем громкость в списке звуков
        if let index = sounds.firstIndex(where: { $0.id == soundId }) {
            sounds[index].volume = volume
            
            // Если звук выбран, обновляем его громкость
            if let selectedIndex = selectedSounds.firstIndex(where: { $0.id == soundId }) {
                selectedSounds[selectedIndex].volume = volume
                
                // Обновляем громкость воспроизведения
                let adjustedVolume = volume * masterVolume
                // Здесь нужно обновить громкость в AudioService
                // В текущей реализации AudioService не поддерживает обновление отдельного звука
            }
        }
    }
    
    func updateMasterVolume(_ volume: Float) {
        masterVolume = volume
        
        // Обновляем громкость всех выбранных звуков
        for (index, sound) in selectedSounds.enumerated() {
            selectedSounds[index].volume = sound.volume * masterVolume
        }
        
        // Обновляем общую громкость в AudioService
        audioService.setVolume(masterVolume)
    }
    
    func setSoundVolume(_ sound: Sound, volume: Float) {
        guard let index = sounds.firstIndex(where: { $0.id == sound.id }) else { return }
        
        sounds[index].volume = volume
        
        if isSoundSelected(sound) {
            // Обновляем в выбранных звуках
            if let selectedIndex = selectedSounds.firstIndex(where: { $0.id == sound.id }) {
                selectedSounds[selectedIndex].volume = volume
                
                // Обновляем воспроизведение
                let adjustedVolume = volume * masterVolume
                // Здесь нужно обновить громкость конкретного звука
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func isSoundSelected(_ sound: Sound) -> Bool {
        return selectedSounds.contains(where: { $0.id == sound.id })
    }
    
    func getSoundVolume(_ sound: Sound) -> Float {
        return sounds.first(where: { $0.id == sound.id })?.volume ?? 0.5
    }
    
    private func updateIsPlayingState() {
        isPlaying = !selectedSounds.isEmpty && audioService.isPlaying
    }
    
    func clearSelection() {
        selectedSounds.removeAll()
        stopAll()
    }
    
    // MARK: - Sound Presets
    
    func createPreset(name: String) -> SoundPreset {
        let soundConfigurations = selectedSounds.map { sound in
            SoundPreset.SoundConfiguration(
                soundId: sound.id,
                isEnabled: true,
                volume: sound.volume
            )
        }
        
        return SoundPreset(
            id: UUID(),
            name: name,
            sounds: soundConfigurations,
            isFavorite: false,
            createdAt: Date()
        )
    }
    
    func loadPreset(_ preset: SoundPreset) {
        clearSelection()
        
        for config in preset.sounds where config.isEnabled {
            if let sound = sounds.first(where: { $0.id == config.soundId }) {
                var soundWithVolume = sound
                soundWithVolume.volume = config.volume
                selectedSounds.append(soundWithVolume)
            }
        }
        
        if !selectedSounds.isEmpty {
            startPlayback()
        }
    }
}
