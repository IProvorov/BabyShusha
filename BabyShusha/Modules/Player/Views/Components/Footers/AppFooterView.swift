// Modules/Player/Views/Components/Footers/AppFooterView.swift
import SwiftUI

struct AppFooterView: View {
    @State private var showDetails = false
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Основная информация
            VStack(spacing: 8) {
                // Первая строка с иконками
                HStack(spacing: 12) {
                    FeatureBadge(
                        icon: "hand.tap.fill",
                        text: "Одной рукой",
                        color: .blue
                    )
                    
                    FeatureBadge(
                        icon: "xmark.circle.fill",
                        text: "Нет рекламы",
                        color: .green
                    )
                    
                    FeatureBadge(
                        icon: "moon.zzz.fill",
                        text: "В фоне",
                        color: .purple
                    )
                }
                
                // Вторая строка с важным сообщением
                HStack(spacing: 8) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                        .symbolEffect(.pulse, isActive: pulseAnimation)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 2).repeatForever()) {
                                pulseAnimation.toggle()
                            }
                        }
                    
                    Text("Кнопки громкости меняют ползунок!")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.blue)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.15))
                        .overlay(
                            Capsule()
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            
            // Кнопка подробнее
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showDetails.toggle()
                }
            }) {
                HStack(spacing: 6) {
                    Text(showDetails ? "Скрыть детали" : "Подробнее о приложении")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                    
                    Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(.white.opacity(0.1), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(ScaleButtonStyle())
            
            // Детальная информация (раскрывается)
            if showDetails {
                VStack(spacing: 10) {
                    DetailRow(
                        icon: "app.badge.checkmark.fill",
                        title: "Безопасность",
                        description: "Без отслеживания и сбора данных"
                    )
                    
                    DetailRow(
                        icon: "battery.100.bolt",
                        title: "Энергия",
                        description: "Оптимизировано для экономии батареи"
                    )
                    
                    DetailRow(
                        icon: "headphones.circle.fill",
                        title: "Аудио",
                        description: "Высокое качество • 256 kbps"
                    )
                }
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Версия и копирайт
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Text("Baby Shusha")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text("Версия 1.0")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text("iOS 26")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.accentColor)
                }
                
                Text("Liquid Glass Design • 2024")
                    .font(.system(size: 10))
                    .foregroundColor(.gray.opacity(0.7))
            }
            .padding(.top, 4)
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
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        )
    }
}

// MARK: - Вспомогательные компоненты

// Бейдж функции
struct FeatureBadge: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color)
            
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(color.opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// Строка детальной информации
struct DetailRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview
struct AppFooterView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            
            AppFooterView()
                .padding(.horizontal)
            
            Spacer()
        }
        .background(
            LinearGradient(
                colors: [Color(red: 0.07, green: 0.1, blue: 0.2),
                        Color(red: 0.12, green: 0.08, blue: 0.25)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .preferredColorScheme(.dark)
    }
}
