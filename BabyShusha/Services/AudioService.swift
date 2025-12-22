// Services/AudioService.swift
import Foundation
import AVFoundation

class AudioService {
    static let shared = AudioService()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private let audioSession = AVAudioSession.sharedInstance()
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playSound(named filename: String, volume: Float = 0.5, loop: Bool = true) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "mp3") else {
            print("Sound file not found: \(filename)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.numberOfLoops = loop ? -1 : 0
            player.prepareToPlay()
            player.play()
            
            audioPlayers[filename] = player
        } catch {
            print("Error playing sound: \(error)")
        }
    }
    
    func stopSound(named filename: String) {
        audioPlayers[filename]?.stop()
        audioPlayers.removeValue(forKey: filename)
    }
    
    func updateVolume(for filename: String, volume: Float) {
        audioPlayers[filename]?.volume = volume
    }
    
    func stopAll() {
        audioPlayers.values.forEach { $0.stop() }
        audioPlayers.removeAll()
    }
    
    func isPlaying(filename: String) -> Bool {
        return audioPlayers[filename]?.isPlaying ?? false
    }
}
