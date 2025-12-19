// Modules/Player/Views/Layouts/ControlPanelView.swift
import SwiftUI

struct ControlPanelView: View {
    @Binding var volume: Float
    @Binding var timerDuration: Int
    let isTimerActive: Bool
    let timeRemaining: String
    let accentColor: Color
    let onTimerDurationChange: (Int) -> Void
    
    private let timerOptions = [15, 30, 60, 0]
    
    var body: some View {
        VStack(spacing: 24) {
            // Регулятор громкости
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 16))
                        .foregroundColor(accentColor)
                    
                    Text("Громкость")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    Text("\(Int(volume * 100))%")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                VolumeSlider(value: $volume, accentColor: accentColor)
            }
            
            Divider()
                .background(.white.opacity(0.1))
            
            // Таймер сна
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "timer")
                        .font(.system(size: 16))
                        .foregroundColor(.orange)
                    
                    Text("Таймер сна")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    if isTimerActive {
                        Text(timeRemaining)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.orange)
                    } else {
                        Text(timerDuration == 0 ? "Выкл" : "\(timerDuration) мин")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                HStack(spacing: 12) {
                    ForEach(timerOptions, id: \.self) { minutes in
                        TimerCapsule(
                            minutes: minutes,
                            isSelected: timerDuration == minutes,
                            isActive: isTimerActive && timerDuration == minutes,
                            action: { onTimerDurationChange(minutes) }
                        )
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
        )
    }
}
