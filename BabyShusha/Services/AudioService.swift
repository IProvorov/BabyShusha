import Foundation
import AVFoundation
import Combine

class AudioService: ObservableObject {
    static let shared = AudioService()
    
    @Published var isPlaying = false
    @Published var currentVolume: Float = 0.7
    
    private var player: AVAudioPlayer?
    
    public init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }
    
    func playSound(named: String, volume: Float = 0.7, loop: Bool = false, completion: @escaping (Bool) -> Void) {
        // Проверяем расширение файла
        let fileName = named.hasSuffix(".mp3") ? named : "\(named).mp3"
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            print("Sound file not found: \(fileName)")
            completion(false)
            return
        }
        
        do {
            player?.stop()
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = volume
            player?.numberOfLoops = loop ? -1 : 0
            player?.play()
            
            isPlaying = true
            currentVolume = volume
            
            completion(true)
            
        } catch {
            print("Playback error: \(error)")
            completion(false)
        }
    }
    
    func stopAll() {
        player?.stop()
        player = nil
        isPlaying = false
    }
    
    func setVolume(_ volume: Float) {
        currentVolume = volume
        player?.volume = volume
    }
    
}
