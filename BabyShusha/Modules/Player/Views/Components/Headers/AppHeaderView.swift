// Modules/Player/Views/Components/Headers/AppHeaderView.swift
import SwiftUI

struct AppHeaderView: View {
    let title: String
    let subtitle: String
    let isPlaying: Bool
    let accentColor: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, accentColor.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // StatusIndicator
            HStack(spacing: 6) {
                Circle()
                    .fill(isPlaying ? accentColor : Color.gray.opacity(0.5))
                    .frame(width: 8, height: 8)
                    .scaleEffect(isPlaying ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3), value: isPlaying)
                
                Text(isPlaying ? "В эфире" : "Пауза")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(isPlaying ? accentColor : .white.opacity(0.6))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(isPlaying ? accentColor.opacity(0.3) : .white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
        )
    }
}
