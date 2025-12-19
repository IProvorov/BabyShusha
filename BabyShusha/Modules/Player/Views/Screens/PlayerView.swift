// Modules/Player/Views/Screens/PlayerView.swift
import SwiftUI

struct PlayerView: View {
    @StateObject private var viewModel = PlayerViewModel()
    @State private var selectedTab = 0  // 0 - звуки, 1 - отслеживание сна
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Контент вкладок (простой переключатель)
//            Group {
//                if selectedTab == 0 {
//                    soundPlayerTab
//                } else {
//                    SleepTrackerView(onBackToSounds: {
//                        selectedTab = 0
//                    })
//                }
//            }
            
            Group {
                           switch selectedTab {
                           case 0:
                               PlayerView()
                           case 1:
                               SleepTrackerView(onBackToSounds: {
                                   selectedTab = 0
                               })
                           case 2:
                               ChildProfileListView()
                           default:
                               PlayerView()
                           }
                       }
            
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Group {
                    if selectedTab == 0 {
                        LiquidGlassBackground(
                            isNightMode: viewModel.isNightMode,
                            accentColor: viewModel.accentColor
                        )
                    } else {
                        LinearGradient(
                            colors: [
                                Color(red: 0.07, green: 0.1, blue: 0.2),
                                Color(red: 0.12, green: 0.08, blue: 0.25),
                                Color(red: 0.15, green: 0.05, blue: 0.3)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                }
                .ignoresSafeArea()
            )
            
            // Кастомный Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .preferredColorScheme(.dark)
        .ignoresSafeArea(.keyboard)
    }
    
    // MARK: - Вкладка звуков
    private var soundPlayerTab: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Галерея звуков
                SoundGalleryView(
                    sounds: viewModel.sounds,
                    selectedSound: viewModel.selectedSound,
                    isPlaying: viewModel.isPlaying,
                    onSelect: viewModel.selectSound
                )
                
                // Главная кнопка управления
                PrimaryControlButton(
                    isPlaying: viewModel.isPlaying,
                    soundName: viewModel.selectedSound.title,
                    accentColor: viewModel.accentColor,
                    action: viewModel.togglePlayback
                )
                
                // Панель управления
                ControlPanelView(
                    volume: $viewModel.volume,
                    timerDuration: $viewModel.timerDuration,
                    isTimerActive: viewModel.isTimerActive,
                    timeRemaining: viewModel.formattedTimeRemaining,
                    accentColor: viewModel.accentColor,
                    onTimerDurationChange: viewModel.setTimerDuration
                )
                
                // Ночной режим
                NightModeToggle(
                    isNightMode: $viewModel.isNightMode,
                    accentColor: viewModel.accentColor
                )
                
                // Кнопка быстрого перехода к отслеживанию сна
                QuickSleepTrackingButton {
                    selectedTab = 1
                }
                
                // Отступ для TabBar
                Color.clear
                    .frame(height: 90) // Примерная высота TabBar
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 10)
        }
    }
}

// MARK: - Вспомогательные компоненты

// Кнопка быстрого перехода к отслеживанию сна
struct QuickSleepTrackingButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.purple)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Отслеживание сна")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Начать отслеживать сон малыша")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Кастомный Tab Bar
//struct CustomTabBar: View {
//    @Binding var selectedTab: Int
//    
//    var body: some View {
//        HStack(spacing: 0) {
//            // Вкладка Звуки
//            TabBarButton(
//                icon: "speaker.wave.3.fill",
//                title: "Звуки",
//                isSelected: selectedTab == 0
//            ) {
//                selectedTab = 0
//            }
//            
//            Spacer()
//            
//            // Вкладка Сон
//            TabBarButton(
//                icon: "moon.zzz.fill",
//                title: "Сон",
//                isSelected: selectedTab == 1
//            ) {
//                selectedTab = 1
//            }
//        }
//        .padding(.horizontal, 40)
//        .padding(.vertical, 15)
//        .background(
//            Capsule()
//                .fill(.ultraThinMaterial)
//                .overlay(
//                    Capsule()
//                        .stroke(.white.opacity(0.1), lineWidth: 1)
//                )
//                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
//        )
//        .padding(.horizontal, 20)
//        .padding(.bottom, 10)
//    }
//}

//struct TabBarButton: View {
//    let icon: String
//    let title: String
//    let isSelected: Bool
//    let action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            VStack(spacing: 4) {
//                Image(systemName: icon)
//                    .font(.system(size: 22))
//                    .foregroundColor(isSelected ? .purple : .gray)
//                    .symbolEffect(.bounce, value: isSelected)
//                
//                Text(title)
//                    .font(.system(size: 11, weight: .medium))
//                    .foregroundColor(isSelected ? .purple : .gray)
//            }
//            .frame(width: 70)
//        }
//        .scaleEffect(isSelected ? 1.05 : 1.0)
//        .animation(.spring(response: 0.3), value: isSelected)
//    }
//}

// MARK: - ScaleButtonStyle
//struct ScaleButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
//            .animation(.spring(response: 0.3, dampingFraction: 0.7),
//                      value: configuration.isPressed)
//    }
//}

// MARK: - Preview
struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
    }
}
