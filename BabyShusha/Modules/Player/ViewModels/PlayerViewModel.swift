// Modules/Player/ViewModels/PlayerViewModel.swift
import SwiftUI
import Combine
import AVFoundation
import Foundation


@MainActor
class PlayerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isPlaying = false
    @Published var volume: Float = 0.5
    @Published var selectedSound: Sound
    @Published var timerDuration = 30
    @Published var isTimerActive = false
    @Published var isNightMode = false
    @Published var timeRemaining = 0
    @Published var errorMessage: String? = nil
    
    // MARK: - Private Properties
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var fadeWorkItems: [DispatchWorkItem] = []
    
    // MARK: - Services
    private let audioService = AudioService()
    private let hapticService = HapticService()
    
    // MARK: - Computed Properties
    var accentColor: Color {
        selectedSound.color
    }
    
    var sounds: [Sound] {
        Sound.defaultSounds
    }
    
    var formattedTimeRemaining: String {
        formatTime(timeRemaining)
    }
    
    // MARK: - Initialization
    init() {
        // Начинаем с первого звука по умолчанию
        self.selectedSound = Sound.defaultSounds.first!
        setupAudio()
    }
    
    // MARK: - Audio Setup
    private func setupAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .allowBluetooth, .allowAirPlay]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio setup error: \(error)")
            errorMessage = "Ошибка настройки аудио"
        }
    }
    
    // MARK: - Public Methods
    
    // Выбор звука
    func selectSound(_ sound: Sound) {
        selectedSound = sound
        if isPlaying {
            Task {
                await playCurrentSound()
            }
        }
    }
    
    func playSleepSound() {
           // Находим звуки для сна (белый шум, колыбельные)
           if let sleepSound = sounds.first(where: {
               $0.title.lowercased().contains("белый") ||
               $0.title.lowercased().contains("колыбель")
           }) {
               selectSound(sleepSound)
               if !isPlaying {
                   togglePlayback()
               }
           }
       }
    // Воспроизведение/пауза
    func togglePlayback() {
        if isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
    }
    
    private func startPlayback() {
        Task {
            await playCurrentSound()
            isPlaying = true
            hapticService.trigger(.medium)
            
            if timerDuration > 0 {
                startTimer()
            }
        }
    }
    
    private func stopPlayback() {
        Task {
            await audioService.stop()
            isPlaying = false
            stopTimer()
            hapticService.trigger(.light)
        }
    }
    
    // Воспроизведение звука с обработкой ошибок
    private func playCurrentSound() async {
        do {
            try await audioService.play(sound: selectedSound, volume: volume)
        } catch {
            print("Playback error: \(error)")
            errorMessage = "Ошибка воспроизведения: \(error.localizedDescription)"
            
            // Автоматически останавливаем воспроизведение при ошибке
            await MainActor.run {
                self.isPlaying = false
            }
        }
    }
    
    // Таймер сна
    func setTimerDuration(_ minutes: Int) {
           timerDuration = minutes
           
           if minutes > 0 && isPlaying {
               startTimer()
           } else {
               stopTimer()
           }
       }
    
    func startTimer() {
        stopTimer() // Останавливаем предыдущий
        
        timeRemaining = timerDuration * 60
        isTimerActive = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stopTimer()
                Task {
                    await self.stopWithFade() // Плавное затухание
                    await MainActor.run {
                        self.isPlaying = false
                        self.hapticService.trigger(.heavy)
                    }
                }
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerActive = false
        timeRemaining = 0
    }
    
    // Плавное затухание
    private func stopWithFade() async {
        await audioService.fadeOut(duration: 3.0)
    }
    
    // Обновление громкости
    func updateVolume(_ newVolume: Float) {
        volume = newVolume
        audioService.setVolume(newVolume)
    }
    
    // MARK: - Helper Methods
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    // Очистка ошибки
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Cleanup
    deinit {
        timer?.invalidate()
        cancellables.forEach { $0.cancel() }
        Task {
            await audioService.stop()
        }
    }
}
