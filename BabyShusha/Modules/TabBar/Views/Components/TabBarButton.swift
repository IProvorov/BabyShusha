// Modules/TabBar/Views/Components/TabBarButton.swift
import SwiftUI

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var bounceAnimation = false
    
    var body: some View {
        Button(action: {
            // Запускаем анимацию нажатия
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
                bounceAnimation = true
            }
            
            // Возвращаем кнопку в исходное состояние
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3)) {
                    isPressed = false
                }
            }
            
            // Выполняем действие
            action()
        }) {
            VStack(spacing: 0) { // ← ОТСТУП 5 ПОИНТОВ МЕЖДУ ИКОНКОЙ И ТЕКСТОМ
                // Иконка с анимацией bounce
                ZStack {
                    // Фон иконки
                    Circle()
                        .fill(isSelected ? Color.blue.opacity(0.2) : .clear)
                        .frame(width: 30, height: 30)
                    
                    // Иконка с анимацией
                    Image(systemName: icon)
                        .font(.system(size: isSelected ? 20 : 18, weight: isSelected ? .semibold : .medium))
                        .foregroundColor(isSelected ? .blue : .white.opacity(0.6))
                        .scaleEffect(bounceAnimation && isSelected ? 1.2 : 1.0)
                        .onChange(of: isSelected) { oldValue, newValue in
                            if newValue {
                                withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
                                    bounceAnimation = true
                                }
                                
                                // Сбрасываем анимацию
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation {
                                        bounceAnimation = false
                                    }
                                }
                            }
                        }
                }
                .frame(width: 44, height: 44)
                
                // Текст
                Text(title)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? .blue : .white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(TabBarButtonStyle())
    }
}

// Стиль для кнопки TabBar
struct TabBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7),
                      value: configuration.isPressed)
    }
}

// MARK: - Preview
struct TabBarButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 40) {
            TabBarButton(
                icon: "waveform",
                title: "Звуки",
                isSelected: true,
                action: {}
            )
            
            TabBarButton(
                icon: "moon.stars.fill",
                title: "Сон",
                isSelected: false,
                action: {}
            )
        }
        .padding()
        .background(Color.black)
        .previewLayout(.sizeThatFits)
    }
}
