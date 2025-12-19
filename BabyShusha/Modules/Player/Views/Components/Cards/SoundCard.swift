// Modules/Player/Views/Components/Cards/SoundCard.swift
import SwiftUI

struct SoundCard: View {
    let sound: Sound
    let isSelected: Bool
    let isPlaying: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            VStack(spacing: 12) {
                ZStack {
                    // Стеклянный круг
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .fill(sound.color.opacity(isSelected ? 0.25 : 0.15))
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(isSelected ? 0.3 : 0.1),
                                            sound.color.opacity(isSelected ? 0.6 : 0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: isSelected ? 2.5 : 1.5
                                )
                        )
                        .shadow(
                            color: sound.color.opacity(isSelected ? 0.4 : 0.2),
                            radius: isSelected ? 12 : 8,
                            y: isSelected ? 4 : 2
                        )
                    
                    // Иконка звука
                    Image(systemName: sound.icon)
                        .font(.system(size: 26, weight: .medium))
                        .foregroundColor(isSelected ? .white : sound.color)
                        .symbolEffect(.bounce, value: isSelected)
                    
                    // Индикатор воспроизведения
                    if isPlaying && isSelected {
                        Circle()
                            .stroke(sound.color, lineWidth: 2)
                            .frame(width: 70, height: 70)
                            .scaleEffect(pulseScale)
                            .opacity(0.8)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                    pulseScale = 1.2
                                }
                            }
                    }
                }
                
                // Название звука
                Text(sound.title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 80)
            }
            .frame(width: 100, height: 120)
        }
        .buttonStyle(ScaleButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
