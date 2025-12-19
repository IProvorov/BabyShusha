// Shared/Styles/ScaleButtonStyle.swift
import SwiftUI

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7),
                      value: configuration.isPressed)
    }
}

// Если нужен вариант с кастомным isPressed
struct ScaleButtonStyleWithParam: ButtonStyle {
    let isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7),
                      value: isPressed)
    }
}
