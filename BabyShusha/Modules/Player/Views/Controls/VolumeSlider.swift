// Modules/Player/Views/Components/Controls/VolumeSlider.swift
import SwiftUI

struct VolumeSlider: View {
    @Binding var value: Float
    let accentColor: Color
    let showLabels: Bool
    
    @State private var isDragging = false
    @State private var showBubble = false
    @State private var bubbleValue: String = "50%"
    
    init(value: Binding<Float>, accentColor: Color = .blue, showLabels: Bool = true) {
        self._value = value
        self.accentColor = accentColor
        self.showLabels = false
    }
    
    var body: some View {
        VStack(spacing: 8) {
            if showLabels {
                HStack {
                    Image(systemName: "speaker.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("Громкость")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(Int(value * 100))%")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Фоновый трек
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    
                    // Заполненная часть
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    accentColor.opacity(0.8),
                                    accentColor
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: CGFloat(value) * geometry.size.width, height: 8)
                    
                    // Ползунок с пузырьком значения
                    ZStack {
                        // Пузырек с процентом
                        if showBubble && isDragging {
                            Text("\(Int(value * 100))%")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(accentColor)
                                        .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                                )
                                .offset(y: -35)
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Кружок ползунка
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [.white, accentColor],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 20
                                )
                            )
                            .frame(width: isDragging ? 32 : 28, height: isDragging ? 32 : 28)
                            .shadow(
                                color: accentColor.opacity(isDragging ? 0.6 : 0.4),
                                radius: isDragging ? 10 : 8,
                                y: isDragging ? 4 : 2
                            )
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.3), lineWidth: 2)
                            )
                    }
                    .position(x: CGFloat(value) * geometry.size.width, y: geometry.size.height / 2)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                if !isDragging {
                                    withAnimation(.spring(response: 0.3)) {
                                        isDragging = true
                                        showBubble = true
                                    }
                                }
                                
                                let newValue = min(max(Float(gesture.location.x / geometry.size.width), 0), 1)
                                withAnimation(.interactiveSpring(response: 0.2)) {
                                    value = newValue
                                    bubbleValue = "\(Int(newValue * 100))%"
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.4)) {
                                    isDragging = false
                                }
                                
                                withAnimation(.easeOut(duration: 0.2).delay(0.1)) {
                                    showBubble = false
                                }
                            }
                    )
                }
            }
            .frame(height: 40)
        }
    }
}
