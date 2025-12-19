// Modules/Player/Views/Components/Controls/TimerCapsule.swift
import SwiftUI

struct TimerCapsule: View {
    let minutes: Int
    let isSelected: Bool
    let isActive: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            ZStack {
                // Стеклянный фон (используем ZStack вместо тернарного оператора)
                if isSelected {
                    Capsule()
                        .fill(isActive ? Color.orange : accentColor)
                        .overlay(
                            Capsule()
                                .stroke(
                                    isActive ? Color.orange.opacity(0.5) : accentColor.opacity(0.5),
                                    lineWidth: 1
                                )
                        )
                } else {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(.white.opacity(0.1), lineWidth: 1)
                        )
                }
                
                // Контент
                HStack(spacing: 6) {
                    // Иконка для активного таймера
//                    if isActive {
//                        Image(systemName: "clock.fill")
//                            .font(.system(size: 12))
//                            .foregroundColor(.white)
//                    }
                    
                    // Текст
                    Text(labelText)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    // MARK: - Computed Properties
    
    private var labelText: String {
        minutes == 0 ? "Выкл" : "\(minutes) мин"
    }
    
    private var accentColor: Color {
        switch minutes {
        case 15: return .blue
        case 30: return .green
        case 60: return .purple
        case 0: return .gray
        default: return .blue
        }
    }
}

// MARK: - Preview
struct TimerCapsule_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                TimerCapsule(
                    minutes: 15,
                    isSelected: true,
                    isActive: true,
                    action: {}
                )
                
                TimerCapsule(
                    minutes: 30,
                    isSelected: false,
                    isActive: false,
                    action: {}
                )
                
                TimerCapsule(
                    minutes: 60,
                    isSelected: false,
                    isActive: false,
                    action: {}
                )
                
                TimerCapsule(
                    minutes: 0,
                    isSelected: false,
                    isActive: false,
                    action: {}
                )
            }
            
            HStack(spacing: 12) {
                TimerCapsule(
                    minutes: 15,
                    isSelected: true,
                    isActive: false,
                    action: {}
                )
                
                TimerCapsule(
                    minutes: 30,
                    isSelected: true,
                    isActive: true,
                    action: {}
                )
                
                TimerCapsule(
                    minutes: 60,
                    isSelected: false,
                    isActive: false,
                    action: {}
                )
                
                TimerCapsule(
                    minutes: 0,
                    isSelected: true,
                    isActive: false,
                    action: {}
                )
            }
        }
        .padding()
        .background(Color.black)
        .previewLayout(.sizeThatFits)
    }
}
