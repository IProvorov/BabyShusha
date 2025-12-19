// Modules/Player/Views/Components/Indicators/StatusIndicator.swift
import SwiftUI

struct StatusIndicator: View {
    let isActive: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            // Анимированная точка
            Circle()
                .fill(isActive ? color : Color.gray.opacity(0.5))
                .frame(width: 8, height: 8)
                .scaleEffect(isActive ? 1.2 : 1.0)
                .animation(.spring(response: 0.3), value: isActive)
            
            // Текст статуса
            Text(isActive ? "В эфире" : "Пауза")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(isActive ? color : .white.opacity(0.6))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(isActive ? color.opacity(0.3) : .white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview
struct StatusIndicator_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            StatusIndicator(isActive: true, color: .blue)
            StatusIndicator(isActive: false, color: .blue)
            StatusIndicator(isActive: true, color: .green)
            StatusIndicator(isActive: false, color: .green)
        }
        .padding()
        .background(Color.black)
        .previewLayout(.sizeThatFits)
    }
}
