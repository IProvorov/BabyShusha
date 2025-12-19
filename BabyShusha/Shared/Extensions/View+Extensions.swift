// Shared/Extensions/View+Extensions.swift
import SwiftUI

// MARK: - Модификаторы для "жидкого стекла"
extension View {
    /// Применяет эффект "жидкого стекла" iOS 26
    func liquidGlassEffect(intensity: CGFloat = 0.3, cornerRadius: CGFloat = 20) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .opacity(intensity)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
    }
    
    /// Адаптивный padding для разных размеров экрана
    func adaptivePadding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        self.padding(edges, length ?? adaptiveSpacing())
    }
    
    /// Адаптивный corner radius
    func adaptiveCornerRadius(_ radius: CGFloat? = nil) -> some View {
        self.cornerRadius(radius ?? adaptiveSpacing() * 1.5)
    }
    
    /// Пульсирующая анимация
    func pulseAnimation(isActive: Bool, color: Color, duration: TimeInterval = 1.5) -> some View {
        self
            .overlay(
                Group {
                    if isActive {
                        RoundedRectangle(cornerRadius: adaptiveSpacing() * 1.5)
                            .stroke(color.opacity(0.4), lineWidth: 3)
                            .scaleEffect(1.1)
                            .opacity(0)
                            .animation(
                                Animation.easeInOut(duration: duration)
                                    .repeatForever(autoreverses: false),
                                value: isActive
                            )
                    }
                }
            )
    }
    
    /// Адаптивный шрифт
    func adaptiveFont(_ style: Font.TextStyle, weight: Font.Weight? = nil, design: Font.Design = .rounded) -> some View {
        self.font(.system(style, design: design).weight(weight ?? .regular))
    }
}

// MARK: - Вспомогательные функции
func adaptiveSpacing() -> CGFloat {
    switch UIScreen.main.bounds.height {
    case ..<700: return 12  // iPhone SE, mini
    case 700..<850: return 16 // Стандартные iPhone
    default: return 20      // Большие экраны
    }
}

func adaptiveFontSize(for textStyle: Font.TextStyle) -> CGFloat {
    switch textStyle {
    case .largeTitle: return UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
    case .title: return UIFont.preferredFont(forTextStyle: .title1).pointSize
    case .headline: return UIFont.preferredFont(forTextStyle: .headline).pointSize
    case .body: return UIFont.preferredFont(forTextStyle: .body).pointSize
    case .callout: return UIFont.preferredFont(forTextStyle: .callout).pointSize
    case .footnote: return UIFont.preferredFont(forTextStyle: .footnote).pointSize
    case .caption2: return UIFont.preferredFont(forTextStyle: .caption2).pointSize
    default: return 16
    }
}

// MARK: - Модификатор для плавного появления
struct FadeInModifier: ViewModifier {
    let delay: Double
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.5).delay(delay)) {
                    opacity = 1
                }
            }
    }
}

extension View {
    func fadeIn(delay: Double = 0) -> some View {
        modifier(FadeInModifier(delay: delay))
    }
}

// MARK: - Модификатор для стеклянной карточки
struct GlassCardModifier: ViewModifier {
    let style: GlassCardStyle
    
    enum GlassCardStyle {
        case floating, panel, tabBar
        
        var cornerRadius: CGFloat {
            switch self {
            case .floating: return 25
            case .panel: return 28
            case .tabBar: return 30
            }
        }
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: style.cornerRadius)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.2), radius: style == .floating ? 30 : 20, y: 10)
            )
    }
}

extension View {
    func glassCard(style: GlassCardModifier.GlassCardStyle = .floating) -> some View {
        modifier(GlassCardModifier(style: style))
    }
}
