//
//  ContentView.swift
//  BabyShusha
//
//  Created by  Igor Provorov on 15.12.25.
//

import SwiftUI
import AVFoundation // Добавляем аудио-фреймворк

struct ContentView: View {
    // Создаем аудиоплеер
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(isPlaying ? .red : .white)
                    .padding()
                
                Text(isPlaying ? "Шум играет" : "Шум выключен")
                    .font(.title)
                    .foregroundColor(.white)
                
                Button(action: {
                    togglePlayback()
                }) {
                    Text(isPlaying ? "Остановить" : "Включить шум")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(width: 200, height: 60)
                        .background(isPlaying ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .padding(.top, 40)
            }
        }
        .onAppear {
            setupAudio()
        }
    }
    
    func setupAudio() {
        // Находим файл в проекте
        guard let url = Bundle.main.url(forResource: "white_noise", withExtension: "mp3") else {
            print("Файл не найден")
            return
        }
        
        do {
            // Создаем аудиоплеер
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Бесконечный повтор
            audioPlayer?.prepareToPlay()
            
            // Настраиваем аудиосессию
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
        } catch {
            print("Ошибка аудио: \(error)")
        }
    }
    
    func togglePlayback() {
        if isPlaying {
            audioPlayer?.pause()
        } else {
            audioPlayer?.play()
        }
        isPlaying.toggle()
    }
}
