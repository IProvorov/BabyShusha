// Views/OnboardingView.swift
import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(
            title: "Добро пожаловать в BabyShusha!",
            description: "Помогаем мамам отслеживать сон малышей и создавать уютную атмосферу",
            image: "heart.fill",
            color: .pink
        ),
        OnboardingPage(
            title: "Отслеживание сна",
            description: "Простой таймер для записи дневного и ночного сна вашего малыша",
            image: "moon.zzz.fill",
            color: .blue
        ),
        OnboardingPage(
            title: "Успокаивающие звуки",
            description: "Белый шум, сердцебиение, дождь и другие звуки для крепкого сна",
            image: "speaker.wave.3.fill",
            color: .purple
        ),
        OnboardingPage(
            title: "История и рекомендации",
            description: "Анализируйте режим сна и получайте полезные советы",
            image: "chart.bar.fill",
            color: .green
        ),
        OnboardingPage(
            title: "Начните сейчас!",
            description: "Добавьте первого ребенка и начните отслеживать сон",
            image: "person.fill.badge.plus",
            color: .orange
        )
    ]
    
    var body: some View {
        ZStack {
            // Фон с градиентом
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color(.systemGray6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Индикатор страниц
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                    }
                }
                .padding(.top, 50)
                .padding(.bottom, 30)
                
                // Контент страницы
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 400)
                
                // Кнопки навигации
                HStack {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation(.spring()) {
                                currentPage -= 1
                            }
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Назад")
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding()
                        }
                    }
                    
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button(action: {
                            withAnimation(.spring()) {
                                currentPage += 1
                            }
                        }) {
                            HStack {
                                Text("Далее")
                                Image(systemName: "chevron.right")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 15)
                            .background(Color.blue.cornerRadius(15))
                        }
                    } else {
                        Button(action: {
                            hasCompletedOnboarding = true
                        }) {
                            Text("Начать использовать")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 15)
                                .background(Color.blue.cornerRadius(15))
                                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
                
                // Пропустить
                if currentPage < pages.count - 1 {
                    Button(action: {
                        hasCompletedOnboarding = true
                    }) {
                        Text("Пропустить")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                    }
                }
            }
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            // Иконка
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: page.image)
                    .font(.system(size: 50))
                    .foregroundColor(page.color)
            }
            
            // Текст
            VStack(spacing: 15) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .foregroundColor(.primary)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 30)
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let image: String
    let color: Color
}
