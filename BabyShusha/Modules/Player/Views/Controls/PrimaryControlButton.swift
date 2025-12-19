// Modules/Player/Views/Components/Controls/PrimaryControlButton.swift
import SwiftUI

struct PrimaryControlButton: View {
    let isPlaying: Bool
    let soundName: String
    let accentColor: Color
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var pulseAnimation = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                action()
            }
        }) {
            ZStack {
                // Основной фон кнопки
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                accentColor.opacity(0.9),
                                accentColor.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 70)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: accentColor.opacity(isPlaying ? 0.6 : 0.4),
                        radius: isPlaying ? 20 : 15,
                        y: isPlaying ? 8 : 5
                    )
                
                // Контент кнопки
                HStack(spacing: 16) {
                    Image(systemName: buttonIcon)
                        .font(.system(size: 28, weight: .bold))
                        .symbolEffect(.bounce, value: isPlaying)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(buttonTitle)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        
                        Text(soundName)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .opacity(0.9)
                    }
                    
                    Spacer()
                    
                    // Индикатор воспроизведения
                    if isPlaying {
                        Circle()
                            .fill(.white)
                            .frame(width: 12, height: 12)
                            .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                            .opacity(pulseAnimation ? 0.6 : 1.0)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                    pulseAnimation.toggle()
                                }
                            }
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                // Анимация пульсации при воспроизведении
                if isPlaying {
                    ForEach(0..<2) { index in
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(accentColor.opacity(0.4 - Double(index) * 0.1), lineWidth: 3)
                            .scaleEffect(pulseAnimation ? 1.1 + CGFloat(index) * 0.05 : 1.0)
                            .opacity(pulseAnimation ? 0 : 1)
                            .animation(
                                Animation.easeInOut(duration: 2.0)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(index) * 0.3),
                                value: pulseAnimation
                            )
                    }
                }
            }
        }
        .buttonStyle(PrimaryButtonStyle(isPressed: isPressed))
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    private var buttonIcon: String {
        isPlaying ? "pause.fill" : "play.fill"
    }
    
    private var buttonTitle: String {
        isPlaying ? "Остановить" : "Запустить"
    }
}

// Стиль для главной кнопки
struct PrimaryButtonStyle: ButtonStyle {
    let isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
}
