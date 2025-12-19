// Modules/Player/Services/AudioService.swift
import Foundation
import AVFoundation

class AudioService {
    private var audioPlayer: AVAudioPlayer?
    private var currentVolume: Float = 0.5
    
    // Воспроизведение с обработкой ошибок
    func play(sound: Sound, volume: Float) async throws {
        // Останавливаем текущее воспроизведение
        audioPlayer?.stop()
        
        guard let url = Bundle.main.url(forResource: sound.fileName, withExtension: "mp3") else {
            throw AudioError.fileNotFound(fileName: sound.fileName)
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.volume = 0.0 // Начинаем с тишины
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            currentVolume = volume
            // Плавное увеличение громкости
            await fadeIn(to: volume, duration: 2.0)
            
        } catch {
            throw AudioError.playbackFailed(error: error)
        }
    }
    
    func stop() async {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    func setVolume(_ volume: Float) {
        currentVolume = volume
        audioPlayer?.volume = volume
    }
    
    func fadeIn(to targetVolume: Float, duration: TimeInterval) async {
        await performFade(from: 0.0, to: targetVolume, duration: duration)
    }
    
    func fadeOut(duration: TimeInterval) async {
        await performFade(from: currentVolume, to: 0.0, duration: duration)
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    private func performFade(from startVolume: Float, to endVolume: Float, duration: TimeInterval) async {
        let steps = 60
        let stepDuration = duration / Double(steps)
        let volumeStep = (endVolume - startVolume) / Float(steps)
        
        var currentVolume = startVolume
        
        for _ in 0...steps {
            // Обновляем громкость
            currentVolume += volumeStep
            let clampedVolume = max(0.0, min(1.0, currentVolume))
            
            await MainActor.run {
                self.audioPlayer?.volume = clampedVolume
                self.currentVolume = clampedVolume
            }
            
            // Ждем перед следующим шагом
            try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
        }
    }
}

enum AudioError: LocalizedError {
    case fileNotFound(fileName: String)
    case playbackFailed(error: Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let fileName):
            return "Файл '\(fileName).mp3' не найден"
        case .playbackFailed(let error):
            return "Ошибка воспроизведения: \(error.localizedDescription)"
        }
    }
}
