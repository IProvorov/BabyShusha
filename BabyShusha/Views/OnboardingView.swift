// OnboardingView.swift
import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject var childProfileVM: ChildProfileViewModel
    
    @State private var currentPage = 0
    @State private var showChildProfileCreation = false
    @State private var childName = ""
    @State private var childBirthDate = Date().addingTimeInterval(-90 * 24 * 60 * 60) // 3 месяца назад
    @State private var childGender: ChildGender = .notSpecified
    @State private var avatarEmoji = "👶"
    
    let pages = [
        OnboardingPage(
            title: "Добро пожаловать в BabyShusha",
            subtitle: "Помогаем мамам организовать сон малыша быстро и удобно",
            imageName: "moon.zzz.fill",
            color: .blue
        ),
        OnboardingPage(
            title: "Быстрые действия",
            subtitle: "Запускайте колыбельные и белый шум в один клик",
            imageName: "bolt.fill",
            color: .purple
        ),
        OnboardingPage(
            title: "Ночные кормления",
            subtitle: "Ночной режим с тусклым светом и быстрым доступом",
            imageName: "moon.stars.fill",
            color: .indigo
        ),
        OnboardingPage(
            title: "Умные рекомендации",
            subtitle: "Персонализированные советы по режиму сна в зависимости от возраста малыша",
            imageName: "lightbulb.fill",
            color: .orange
        ),
        OnboardingPage(
            title: "Любимые комбинации",
            subtitle: "Сохраняйте пресеты звуков и запускайте их одним нажатием",
            imageName: "music.note.list",
            color: .green
        )
    ]
    
    let avatarEmojis = ["👶", "👧", "👦", "🧒", "👼", "🐣", "🐻", "🐰", "🐶", "🐱", "🐯", "🦁"]
    
    var body: some View {
        ZStack {
            // Градиентный фон
            LinearGradient(
                gradient: Gradient(colors: [
                    pages[currentPage].color,
                    pages[currentPage].color.opacity(0.8),
                    pages[currentPage].color.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentPage)
            
            VStack(spacing: 0) {
                // Пропустить кнопка (только не на первой странице)
                if currentPage > 0 && currentPage < pages.count - 1 {
                    HStack {
                        Spacer()
                        Button("Пропустить") {
                            skipOnboarding()
                        }
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.trailing, 20)
                        .padding(.top, 50)
                    }
                }
                
                // Основной контент
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)
                
                // Нижняя панель с индикаторами и кнопкой
                VStack(spacing: 20) {
                    // Индикаторы страниц
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                                .frame(width: currentPage == index ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                        }
                    }
                    
                    // Кнопка действия
                    Button {
                        handleButtonAction()
                    } label: {
                        HStack {
                            if currentPage == pages.count - 1 {
                                Text("Создать профиль")
                                    .fontWeight(.semibold)
                            } else {
                                Text("Далее")
                                    .fontWeight(.semibold)
                            }
                        }
                        .foregroundColor(pages[currentPage].color)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
                .padding(.top, 20)
            }
        }
        .sheet(isPresented: $showChildProfileCreation) {
            ChildProfileCreationView(
                childName: $childName,
                childBirthDate: $childBirthDate,
                childGender: $childGender,
                avatarEmoji: $avatarEmoji,
                avatarEmojis: avatarEmojis,
                onSave: saveChildProfile,
                onCancel: { showChildProfileCreation = false }
            )
        }
    }
    
    // MARK: - Actions
    
    private func handleButtonAction() {
        if currentPage < pages.count - 1 {
            // Переход к следующей странице
            withAnimation(.spring()) {
                currentPage += 1
            }
        } else {
            // Последняя страница - создание профиля
            showChildProfileCreation = true
        }
    }
    
    private func skipOnboarding() {
        createDefaultChild()
        completeOnboarding()
    }
    
    private func saveChildProfile() {
        guard !childName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        childProfileVM.addChild(
            name: childName.trimmingCharacters(in: .whitespacesAndNewlines),
            birthDate: childBirthDate,
            avatarEmoji: avatarEmoji
        )
        
        completeOnboarding()
    }
    
    private func createDefaultChild() {
        let birthDate = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
        childProfileVM.addChild(
            name: "Малыш",
            birthDate: birthDate,
            avatarEmoji: "👶"
        )
    }
    
    private func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.5)) {
            hasCompletedOnboarding = true
        }
        
        // Сохраняем флаг, что onboarding завершен
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}

// MARK: - OnboardingPage
struct OnboardingPage {
    let title: String
    let subtitle: String
    let imageName: String
    let color: Color
}

// MARK: - OnboardingPageView
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Изображение
            Image(systemName: page.imageName)
                .font(.system(size: 120))
                .foregroundColor(.white.opacity(0.9))
                .frame(height: 200)
            
            // Текст
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(page.subtitle)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - ChildProfileCreationView
struct ChildProfileCreationView: View {
    @Binding var childName: String
    @Binding var childBirthDate: Date
    @Binding var childGender: ChildGender
    @Binding var avatarEmoji: String
    let avatarEmojis: [String]
    var onSave: () -> Void
    var onCancel: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    // Эмодзи аватар
                    VStack {
                        Text(avatarEmoji)
                            .font(.system(size: 60))
                            .frame(height: 80)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(avatarEmojis, id: \.self) { emoji in
                                    Button {
                                        avatarEmoji = emoji
                                    } label: {
                                        Text(emoji)
                                            .font(.title)
                                            .frame(width: 50, height: 50)
                                            .background(avatarEmoji == emoji ? Color.blue.opacity(0.2) : Color.clear)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                            .padding(.vertical, 10)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                
                Section("Основная информация") {
                    TextField("Имя малыша", text: $childName)
                        .font(.body)
                        .submitLabel(.done)
                    
                    DatePicker("Дата рождения", selection: $childBirthDate, in: ...Date(), displayedComponents: .date)
                    
                    Picker("Пол", selection: $childGender) {
                        ForEach(ChildGender.allCases, id: \.self) { gender in
                            Text(gender.displayName).tag(gender)
                        }
                    }
                }
                
                Section {
                    // Возрастная информация
                    let ageInMonths = calculateAgeInMonths()
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Возраст малыша")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if ageInMonths == 0 {
                            Text("Новорожденный (меньше месяца)")
                                .font(.headline)
                        } else if ageInMonths == 1 {
                            Text("1 месяц")
                                .font(.headline)
                        } else if ageInMonths < 12 {
                            Text("\(ageInMonths) \(getMonthWord(ageInMonths))")
                                .font(.headline)
                        } else {
                            let years = ageInMonths / 12
                            let months = ageInMonths % 12
                            if months == 0 {
                                Text("\(years) \(getYearWord(years))")
                                    .font(.headline)
                            } else {
                                Text("\(years) \(getYearWord(years)) \(months) \(getMonthWord(months))")
                                    .font(.headline)
                            }
                        }
                        
                        Text("На основе возраста будут подбираться рекомендации по сну")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Профиль малыша")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        onCancel()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        onSave()
                        dismiss()
                    }
                    .disabled(childName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func calculateAgeInMonths() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: childBirthDate, to: Date())
        return components.month ?? 0
    }
    
    private func getMonthWord(_ count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            return "месяцев"
        }
        
        switch lastDigit {
        case 1: return "месяц"
        case 2, 3, 4: return "месяца"
        default: return "месяцев"
        }
    }
    
    private func getYearWord(_ count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            return "лет"
        }
        
        switch lastDigit {
        case 1: return "год"
        case 2, 3, 4: return "года"
        default: return "лет"
        }
    }
}

// MARK: - Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(hasCompletedOnboarding: .constant(false))
            .environmentObject(ChildProfileViewModel())
    }
}
