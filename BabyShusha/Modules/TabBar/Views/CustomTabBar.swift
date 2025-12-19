// Modules/TabBar/Views/CustomTabBar.swift
import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack {
            Spacer() // Пушит TabBar в самый низ
            
            HStack(spacing: 0) {
                // Вкладка "Звуки"
                TabBarButton(
                    icon: "waveform",
                    title: "Звуки",
                    isSelected: selectedTab == 0,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = 0
                        }
                    }
                )
                
                // Вкладка "Сон"
                TabBarButton(
                    icon: "moon.stars.fill",
                    title: "Сон",
                    isSelected: selectedTab == 1,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = 1
                        }
                    }
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .frame(height: 65)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 0) // Убрали padding снизу
        }
        .frame(maxHeight: .infinity, alignment: .bottom) // Выравнивание по низу
        .ignoresSafeArea(.keyboard) // Чтобы не прыгал при клавиатуре
    }
}
