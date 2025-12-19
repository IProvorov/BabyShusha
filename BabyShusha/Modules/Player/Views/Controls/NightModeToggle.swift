// Modules/Player/Views/Components/Controls/NightModeToggle.swift
import SwiftUI

struct NightModeToggle: View {
    @Binding var isNightMode: Bool
    let accentColor: Color
    
    @State private var isPressed = false
    @State private var rotation: Double = 0
    @State private var starParticles: [StarParticle] = []
    
    // Конфигурация
    private let toggleWidth: CGFloat = 70
    private let toggleHeight: CGFloat = 36
    private let circleSize: CGFloat = 28
    
    var body: some View {
        HStack(spacing: 16) {
            // Иконка с эффектом пульсации
            ZStack {
                // Стеклянный фон иконки
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .fill(isNightMode ? Color.yellow.opacity(0.15) : accentColor.opacity(0.15))
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: isNightMode ?
                                        [.yellow.opacity(0.4), .orange.opacity(0.2)] :
                                        [accentColor.opacity(0.4), .white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: isNightMode ? .yellow.opacity(0.3) : accentColor.opacity(0.2),
                           radius: isNightMode ? 8 : 5)
                
                // Анимированная иконка
                Image(systemName: isNightMode ? "moon.stars.fill" : "sun.max.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isNightMode ? .yellow : .orange)
                    .rotationEffect(.degrees(isNightMode ? 0 : rotation))
                    .symbolEffect(.bounce, value: isNightMode)
                    .onAppear {
                        // Анимация вращения солнца
                        if !isNightMode {
                            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                                rotation = 360
                            }
                        }
                    }
                    .onChange(of: isNightMode) { oldValue, newValue in
                        if !newValue { // Если переключили на дневной режим
                            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                                rotation = 360
                            }
                        } else {
                            rotation = 0
                        }
                    }
            }
            
            // Текст с плавным переходом
            VStack(alignment: .leading, spacing: 4) {
                Text("Режим")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(isNightMode ? "Ночной • Звёзды" : "Дневной • Солнце")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(isNightMode ? .yellow.opacity(0.9) : .orange.opacity(0.9))
                    .transition(.opacity.combined(with: .scale))
            }
            
            Spacer()
            
            // Кастомный переключатель в стиле Liquid Glass
            ZStack {
                // Фон переключателя (стеклянный эффект)
                RoundedRectangle(cornerRadius: toggleHeight / 2)
                    .fill(.ultraThinMaterial)
                    .frame(width: toggleWidth, height: toggleHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: toggleHeight / 2)
                            .fill(
                                LinearGradient(
                                    colors: isNightMode ?
                                        [Color(red: 0.1, green: 0.1, blue: 0.3).opacity(0.6),
                                         Color(red: 0.2, green: 0.1, blue: 0.4).opacity(0.4)] :
                                        [Color(red: 0.9, green: 0.6, blue: 0.1).opacity(0.3),
                                         Color(red: 1.0, green: 0.8, blue: 0.3).opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: toggleHeight / 2)
                            .stroke(
                                LinearGradient(
                                    colors: isNightMode ?
                                        [.white.opacity(0.2), .purple.opacity(0.1)] :
                                        [.white.opacity(0.3), .orange.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: isNightMode ? .purple.opacity(0.2) : .orange.opacity(0.2),
                           radius: 10, y: 5)
                
                // Анимированный фон (волна)
                if isNightMode {
                    RoundedRectangle(cornerRadius: toggleHeight / 2)
                        .fill(
                            LinearGradient(
                                colors: [.purple.opacity(0.3), .blue.opacity(0.1)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: toggleWidth, height: toggleHeight)
                        .mask(
                            RoundedRectangle(cornerRadius: toggleHeight / 2)
                                .frame(width: toggleWidth, height: toggleHeight)
                        )
                        .opacity(0.6)
                        .blur(radius: 2)
                }
                
                // Переключающаяся часть
                Circle()
                    .fill(
                        RadialGradient(
                            colors: isNightMode ?
                                [.white, .yellow, .orange] :
                                [.white, accentColor.opacity(0.8), accentColor],
                            center: .center,
                            startRadius: 0,
                            endRadius: circleSize / 2
                        )
                    )
                    .frame(width: circleSize, height: circleSize)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.5), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: isNightMode ? .yellow.opacity(0.5) : accentColor.opacity(0.5),
                           radius: 8, y: 3)
                    .padding(4)
                    .offset(x: isNightMode ? toggleWidth / 2 - circleSize / 2 - 4 :
                                   -toggleWidth / 2 + circleSize / 2 + 4)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                
                // Звёзды в ночном режиме
                if isNightMode {
                    ForEach(starParticles) { star in
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [.white, .yellow.opacity(0.3), .clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: star.size
                                )
                            )
                            .frame(width: star.size * 2, height: star.size * 2)
                            .position(star.position)
                            .opacity(star.opacity)
                            .blur(radius: 0.5)
                    }
                }
            }
            .frame(width: toggleWidth, height: toggleHeight)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            isPressed = false
                            
                            // Переключение с анимацией
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                isNightMode.toggle()
                            }
                            
                            // Создание звёзд при переключении на ночной режим
                            if isNightMode {
                                createStars()
                            } else {
                                starParticles.removeAll()
                            }
                        }
                    }
            )
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isPressed = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            isPressed = false
                            isNightMode.toggle()
                            
                            if isNightMode {
                                createStars()
                            } else {
                                starParticles.removeAll()
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
        )
        .onAppear {
            if isNightMode {
                createStars()
            }
        }
    }
    
    // MARK: - Звёздные частицы
    
    private func createStars() {
        starParticles.removeAll()
        
        for _ in 0..<8 {
            let size = CGFloat.random(in: 1...3)
            let x = CGFloat.random(in: 10...toggleWidth - 10)
            let y = CGFloat.random(in: 10...toggleHeight - 10)
            let opacity = Double.random(in: 0.4...0.9)
            
            starParticles.append(
                StarParticle(
                    id: UUID(),
                    size: size,
                    position: CGPoint(x: x, y: y),
                    opacity: opacity
                )
            )
        }
    }
}

// Модель для звёздных частиц
struct StarParticle: Identifiable {
    let id: UUID
    let size: CGFloat
    let position: CGPoint
    let opacity: Double
}

// MARK: - Preview
struct NightModeToggle_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var isNightMode = false
        
        var body: some View {
            VStack(spacing: 30) {
                NightModeToggle(
                    isNightMode: $isNightMode,
                    accentColor: .blue
                )
                
                NightModeToggle(
                    isNightMode: $isNightMode,
                    accentColor: .purple
                )
                
                NightModeToggle(
                    isNightMode: $isNightMode,
                    accentColor: .teal
                )
                
                // Информация
                VStack(spacing: 8) {
                    Text("iOS 26 Liquid Glass Toggle")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("• Плавные анимации\n• Эффект жидкого стекла\n• Частицы звёзд\n• Тактильная обратная связь")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(15)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color(red: 0.1, green: 0.1, blue: 0.2),
                            Color(red: 0.2, green: 0.1, blue: 0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
            .preferredColorScheme(.dark)
    }
}
