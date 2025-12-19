// Modules/Player/Services/VolumeButtonService.swift
import UIKit
import MediaPlayer
import Combine

protocol VolumeButtonServiceProtocol {
    var systemVolume: Float { get }
    var systemVolumePublisher: AnyPublisher<Float, Never> { get }
    func setup()
    func cleanup()
    func setSystemVolume(_ volume: Float)
}

class VolumeButtonService: VolumeButtonServiceProtocol, ObservableObject {
    // MARK: - Properties
    @Published var systemVolume: Float = 0.5
    private var volumeView: MPVolumeView?
    private var volumeObserver: NSObjectProtocol?
    private let volumeSubject = PassthroughSubject<Float, Never>()
    
    var systemVolumePublisher: AnyPublisher<Float, Never> {
        volumeSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Setup
    func setup() {
        setupVolumeView()
        setupVolumeObserver()
        updateCurrentVolume()
        print("🔊 Volume button service initialized")
    }
    
    private func setupVolumeView() {
        let volumeView = MPVolumeView(frame: CGRect(x: -100, y: -100, width: 1, height: 1))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.addSubview(volumeView)
            self.volumeView = volumeView
        }
    }
    
    private func setupVolumeObserver() {
        // Удаляем старый observer если есть
        if let oldObserver = volumeObserver {
            NotificationCenter.default.removeObserver(oldObserver)
        }
        
        // Создаем нового observer для системных изменений громкости
        volumeObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("AVSystemController_SystemVolumeDidChangeNotification"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let volume = notification.userInfo?["AVSystemController_AudioVolumeNotificationParameter"] as? Float else {
                return
            }
            
            // Обновляем значение БЕЗ withAnimation
            let oldVolume = self.systemVolume
            self.systemVolume = volume
            self.volumeSubject.send(volume)
            
            print("🔊 System volume changed: \(oldVolume) → \(volume)")
        }
    }
    
    private func updateCurrentVolume() {
        // Получаем текущую системную громкость
        let audioSession = AVAudioSession.sharedInstance()
        systemVolume = audioSession.outputVolume
        
        // Принудительно обновляем системный слайдер
        updateSystemSlider(to: systemVolume)
    }
    
    // MARK: - Volume Control
    func setSystemVolume(_ volume: Float) {
        let clampedVolume = max(0.0, min(1.0, volume))
        
        // Обновляем наше значение
        systemVolume = clampedVolume
        
        // Обновляем системный слайдер
        updateSystemSlider(to: clampedVolume)
        
        // Отправляем событие
        volumeSubject.send(clampedVolume)
    }
    
    private func updateSystemSlider(to volume: Float) {
        guard let slider = volumeView?.subviews.first(where: { $0 is UISlider }) as? UISlider else {
            return
        }
        
        // Устанавливаем значение без анимации
        DispatchQueue.main.async {
            slider.value = volume
            slider.sendActions(for: .valueChanged)
        }
    }
    
    // MARK: - Cleanup
    func cleanup() {
        // Удаляем observer
        if let observer = volumeObserver {
            NotificationCenter.default.removeObserver(observer)
            volumeObserver = nil
        }
        
        // Удаляем volume view
        volumeView?.removeFromSuperview()
        volumeView = nil
        
        print("🔊 Volume button service cleaned up")
    }
    
    deinit {
        cleanup()
    }
}
