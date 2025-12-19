// Modules/Player/Views/Components/Background/LiquidGlassBackground.swift
import SwiftUI

struct LiquidGlassBackground: View {
    let isNightMode: Bool
    let accentColor: Color
    @State private var animationPhase = 0.0
    
    init(isNightMode: Bool = false, accentColor: Color = .blue) {
        self.isNightMode = isNightMode
        self.accentColor = accentColor
    }
    
    var body: some View {
        ZStack {
            // Базовый градиентный фон
            LinearGradient(
                colors: backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Анимированные стеклянные пузыри
            ForEach(0..<8, id: \.self) { index in
                GlassBubble(index: index, accentColor: accentColor, phase: animationPhase)
            }
            
            // Слой ультра-тонкого материала
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(isNightMode ? 0.2 : 0.3)
                .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                animationPhase = 1.0
            }
        }
    }
    
    private var backgroundColors: [Color] {
        if isNightMode {
            return [
                Color(red: 0.05, green: 0.05, blue: 0.1),
                Color(red: 0.08, green: 0.05, blue: 0.15),
                Color(red: 0.12, green: 0.07, blue: 0.2)
            ]
        } else {
            return [
                Color(red: 0.07, green: 0.1, blue: 0.2),
                Color(red: 0.12, green: 0.08, blue: 0.25),
                Color(red: 0.15, green: 0.1, blue: 0.3)
            ]
        }
    }
}

// Структура GlassBubble должна быть ОТДЕЛЬНОЙ
struct GlassBubble: View {
    let index: Int
    let accentColor: Color
    let phase: Double
    
    @State private var offset = CGSize.zero
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0  // ← ИСПРАВЛЕНО: добавлено 'var'
    
    var body: some View {
        let size = CGFloat.random(in: 80...200)
        let x = CGFloat.random(in: -50...UIScreen.main.bounds.width + 50)
        let y = CGFloat.random(in: -50...UIScreen.main.bounds.height + 50)
        let duration = Double.random(in: 15...30)
        let delay = Double(index) * 0.5
        
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        accentColor.opacity(0.1),
                        accentColor.opacity(0.05),
                        .clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 2
                )
            )
            .frame(width: size, height: size)
            .position(x: x, y: y)
            .offset(offset)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .blur(radius: 20)
            .onAppear {
                // Плавное движение пузырей
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    offset = CGSize(
                        width: CGFloat.random(in: -40...40),
                        height: CGFloat.random(in: -40...40)
                    )
                    scale = CGFloat.random(in: 0.9...1.1)
                    rotation = Double.random(in: -45...45)
                }
            }
            .opacity(0.8 + 0.2 * sin(phase * .pi * 2 + Double(index) * 0.5))
    }
}
