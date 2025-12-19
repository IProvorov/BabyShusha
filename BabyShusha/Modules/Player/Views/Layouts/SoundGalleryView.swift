// Modules/Player/Views/Layouts/SoundGalleryView.swift
import SwiftUI

struct SoundGalleryView: View {
    let sounds: [Sound]
    let selectedSound: Sound
    let isPlaying: Bool
    let onSelect: (Sound) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Выберите звук")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(sounds) { sound in
                        // Временная замена SoundCard
                        SoundCardSimple(
                            sound: sound,
                            isSelected: selectedSound.id == sound.id,
                            isPlaying: isPlaying && selectedSound.id == sound.id,
                            action: { onSelect(sound) }
                        )
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
            }
        }
        .padding(20)
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

// MARK: - Временная простая версия SoundCard
struct SoundCardSimple: View {
    let sound: Sound
    let isSelected: Bool
    let isPlaying: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            VStack(spacing: 12) {
                ZStack {
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
                                    isSelected ? sound.color : .white.opacity(0.1),
                                    lineWidth: isSelected ? 2.5 : 1.5
                                )
                        )
                        .shadow(
                            color: sound.color.opacity(isSelected ? 0.4 : 0.2),
                            radius: isSelected ? 12 : 8,
                            y: isSelected ? 4 : 2
                        )
                    
                    Image(systemName: sound.icon)
                        .font(.system(size: 26, weight: .medium))
                        .foregroundColor(isSelected ? .white : sound.color)
                }
                
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
    }
}
