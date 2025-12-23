import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var showChildProfileCreation = false
    @State private var childName = ""
    @State private var childBirthDate = Date()
    @State private var childGender: ChildGender = .notSpecified
    @State private var isLoading = false
    
    let pages = [
        OnboardingPage(
            title: "Добро пожаловать в BabyShusha",
            subtitle: "Помогаем мамам организовать сон малыша быстро и удобно",
            imageName: "onboarding_welcome",
            color: Color(red: 0.2, green: 0.4, blue: 0.8)
        ),
        OnboardingPage(
            title: "Быстрые действия",
            subtitle: "Запускайте колыбельные и белый шум в один клик, даже не разблокируя телефон",
            imageName: "onboarding_quickstart",
            color: Color(red: 0.6, green: 0.3, blue: 0.8)
        ),
        OnboardingPage(
            title: "Ночные кормления",
            subtitle: "Ночной режим с тусклым светом и быстрым доступом ко всем функциям",
            imageName: "onboarding_night",
            color: Color(red: 0.3, green: 0.2, blue: 0.5)
        ),
        OnboardingPage(
            title: "Умные рекомендации",
            subtitle: "Персонализированные советы по режиму сна в зависимости от возраста малыша",
            imageName: "onboarding_recommendations",
            color: Color(red: 0.1, green: 0.5, blue: 0.6)
        ),
        OnboardingPage(
            title: "Любимые комбинации",
            subtitle: "Сохраняйте пресеты звуков и запускайте их одним нажатием",
            imageName: "onboarding_presets",
            color: Color(red: 0.8, green: 0.4, blue: 0.2)
        )
    ]
    
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
                if currentPage > 0 {
                    HStack {
                        Spacer()
                        Button("Пропустить") {
                            skipOnboarding()
                        }
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.trailing, 20)
                        .padding(.top, 10)
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
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .padding(.trailing, 8)
                                }
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
                    .padding(.bottom, 30)
                    .disabled(isLoading)
                }
                .padding(.top, 20)
            }
        }
        .overlay(
            Group {
                if showChildProfileCreation {
                    ChildProfileCreationView(
                        childName: $childName,
                        childBirthDate: $childBirthDate,
                        childGender: $childGender,
                        onSave: saveChildProfile,
                        onCancel: { showChildProfileCreation = false }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        )
        .animation(.spring(), value: showChildProfileCreation)
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
        // Создаем дефолтный профиль при пропуске
        createDefaultChildProfile()
        completeOnboarding()
    }
    
    private func saveChildProfile() {
        guard !childName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            // Показать ошибку
            return
        }
        
        isLoading = true
        
        // Создаем профиль ребенка
        let child = ChildProfile(
            id: UUID(),
            name: childName.trimmingCharacters(in: .whitespacesAndNewlines),
            birthDate: childBirthDate,
            gender: childGender
        )
        
        // Сохраняем в сервисе
        ChildProfileService.shared.saveChild(child)
        ChildProfileService.shared.setActiveChild(child.id)
        
        // Создаем дефолтные пресеты для этого возраста
        createDefaultPresets(for: child)
        
        // Завершаем onboarding с небольшой задержкой
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            completeOnboarding()
        }
    }
    
    private func createDefaultChildProfile() {
        let child = ChildProfile(
            id: UUID(),
            name: "Малыш",
            birthDate: Date().addingTimeInterval(-3 * 30 * 24 * 60 * 60), // 3 месяца назад
            gender: .notSpecified
        )
        
        ChildProfileService.shared.saveChild(child)
        ChildProfileService.shared.setActiveChild(child.id)
        createDefaultPresets(for: child)
    }
    
    private func createDefaultPresets(for child: ChildProfile) {
        let presetService = SoundPresetService.shared
        
        // Пресет для новорожденных
        if child.ageInMonths <= 3 {
            let newbornPreset = SoundPreset(
                id: UUID(),
                name: "Для новорожденного",
                sounds: [
                    SoundPreset.SoundConfiguration(type: .heartbeat, isEnabled: true, individualVolume: 0.7),
                    SoundPreset.SoundConfiguration(type: .whiteNoise, isEnabled: true, individualVolume: 0.5)
                ],
                volume: 0.6,
                isFavorite: true,
                createdAt: Date()
            )
            presetService.savePreset(newbornPreset)
        }
        
        // Универсальный пресет
        let universalPreset = SoundPreset(
            id: UUID(),
            name: "Глубокий сон",
            sounds: [
                SoundPreset.SoundConfiguration(type: .rain, isEnabled: true, individualVolume: 0.8),
                SoundPreset.SoundConfiguration(type: .lullaby, isEnabled: false, individualVolume: 0.0)
            ],
            volume: 0.5,
            isFavorite: true,
            createdAt: Date()
        )
        presetService.savePreset(universalPreset)
    }
    
    private func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.5)) {
            hasCompletedOnboarding = true
        }
        
        // Сохраняем флаг, что onboarding завершен
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Показываем краткое приветствие
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showWelcomeMessage()
        }
    }
    
    private func showWelcomeMessage() {
        // Можно реализовать через Alert или кастомное уведомление
        print("Добро пожаловать в BabyShusha!")
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
            if page.imageName.hasPrefix("onboarding_") {
                Image(page.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 250)
                    .padding(.horizontal, 20)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            } else {
                // Fallback системная иконка
                Image(systemName: getSystemImageForPage())
                    .font(.system(size: 100))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(height: 200)
            }
            
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
    
    private func getSystemImageForPage() -> String {
        switch page.imageName {
        case "onboarding_welcome": return "moon.zzz.fill"
        case "onboarding_quickstart": return "bolt.fill"
        case "onboarding_night": return "moon.stars.fill"
        case "onboarding_recommendations": return "lightbulb.fill"
        case "onboarding_presets": return "music.note.list"
        default: return "heart.fill"
        }
    }
}

// MARK: - ChildProfileCreationView
struct ChildProfileCreationView: View {
    @Binding var childName: String
    @Binding var childBirthDate: Date
    @Binding var childGender: ChildGender
    var onSave: () -> Void
    var onCancel: () -> Void
    
    @State private var showDatePicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок
            HStack {
                Button("Отмена") {
                    onCancel()
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("Профиль малыша")
                    .font(.headline)
                
                Spacer()
                
                Button("Готово") {
                    onSave()
                }
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                .disabled(childName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .background(Color(.systemBackground))
            
            Divider()
            
            Form {
                Section {
                    // Имя ребенка
                    TextField("Имя малыша", text: $childName)
                        .font(.body)
                        .submitLabel(.done)
                        .onSubmit {
                            if !childName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                onSave()
                            }
                        }
                } header: {
                    Text("Основная информация")
                } footer: {
                    Text("Используется для персонализации рекомендаций")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    // Дата рождения
                    Button {
                        showDatePicker = true
                    } label: {
                        HStack {
                            Text("Дата рождения")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(childBirthDate, style: .date)
                                .foregroundColor(.secondary)
                            
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                        }
                    }
                    .sheet(isPresented: $showDatePicker) {
                        DatePickerSheet(
                            selectedDate: $childBirthDate,
                            maximumDate: Date()
                        )
                    }
                    
                    // Пол
                    Picker("Пол", selection: $childGender) {
                        ForEach(ChildGender.allCases, id: \.self) { gender in
                            Text(gender.displayName).tag(gender)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Дополнительно")
                } footer: {
                    Text("Эти данные можно изменить позже в настройках профиля")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
        }
        .frame(maxHeight: 500)
        .background(Color(.systemBackground))
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
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

// MARK: - DatePickerSheet
struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    let maximumDate: Date
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    in: ...maximumDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding()
                
                Spacer()
            }
            .navigationTitle("Дата рождения")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - ChildProfile Model
enum ChildGender: String, CaseIterable {
    case male = "male"
    case female = "female"
    case notSpecified = "not_specified"
    
    var displayName: String {
        switch self {
        case .male: return "Мальчик"
        case .female: return "Девочка"
        case .notSpecified: return "Не указано"
        }
    }
}



// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(hasCompletedOnboarding: .constant(false))
    }
}
