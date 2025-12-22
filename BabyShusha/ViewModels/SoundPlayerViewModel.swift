// ViewModels/SoundPlayerViewModel.swift
import Foundation
import AVFoundation
import SwiftUI
import Combine

class SoundPlayerViewModel: ObservableObject {
    @Published var sounds: [Sound] = []
    @Published var selectedSounds: [Sound] = []
    @Published var isPlaying = false
    @Published var masterVolume: Float = 0.5
    
    private var audioPlayers: [AVAudioPlayer] = []
    private let audioService = AudioService.shared
    
    init() {
        loadDefaultSounds()
    }
    
    private func loadDefaultSounds() {
        sounds = [
            Sound(name: "Белый шум", icon: "wind", filename: "white_noise", category: .whiteNoise),
            Sound(name: "Сердцебиение", icon: "heart.fill", filename: "heartbeat", category: .heartbeat),
            Sound(name: "Дождь", icon: "cloud.rain", filename: "rain", category: .nature),
            Sound(name: "Волны", icon: "water.waves", filename: "waves", category: .nature),
            Sound(name: "Леса", icon: "leaf", filename: "forest", category: .nature),
            Sound(name: "Вентилятор", icon: "fan", filename: "fan", category: .whiteNoise),
            Sound(name: "Утроба", icon: "heart.circle", filename: "womb", category: .heartbeat, isPremium: true),
            Sound(name: "Колыбельная", icon: "music.note", filename: "lullaby", category: .melodies, isPremium: true)
        ]
    }
    
    func toggleSound(_ sound: Sound) {
        if selectedSounds.contains(where: { $0.id == sound.id }) {
            selectedSounds.removeAll { $0.id == sound.id }
            audioService.stopSound(named: sound.filename)
        } else {
            selectedSounds.append(sound)
            audioService.playSound(named: sound.filename, volume: sound.volume * masterVolume)
        }
    }
    
    func togglePlayback() {
        if isPlaying {
            audioService.stopAll()
            isPlaying = false
        } else {
            isPlaying = true
            for sound in selectedSounds {
                audioService.playSound(named: sound.filename, volume: sound.volume * masterVolume)
            }
        }
    }
    
    func updateVolume(for sound: Sound, volume: Float) {
        if let index = sounds.firstIndex(where: { $0.id == sound.id }) {
            sounds[index].volume = volume
            audioService.updateVolume(for: sound.filename, volume: volume * masterVolume)
        }
    }
    
    func updateMasterVolume(_ volume: Float) {
        masterVolume = volume
        for sound in selectedSounds {
            audioService.updateVolume(for: sound.filename, volume: sound.volume * masterVolume)
        }
    }
    
    func stopAll() {
        audioService.stopAll()
        selectedSounds.removeAll()
        isPlaying = false
    }
}
