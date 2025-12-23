import Foundation

struct OnboardingPage {
    let title: String
    let subtitle: String
    let imageName: String
    let buttonTitle: String?
}

final class OnboardingViewModel {
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Добро пожаловать в BabyShusha",
            subtitle: "Помогаем мамам организовать сон малыша",
            imageName: "onboarding_welcome",
            buttonTitle: "Далее"
        ),
        OnboardingPage(
            title: "Быстрый старт сна",
            subtitle: "Запускайте колыбельные и белый шум в один клик",
            imageName: "onboarding_quickstart",
            buttonTitle: "Далее"
        ),
        OnboardingPage(
            title: "Ночные кормления",
            subtitle: "Ночной режим с тусклым светом и быстрым доступом",
            imageName: "onboarding_night",
            buttonTitle: "Далее"
        ),
        OnboardingPage(
            title: "Создайте профиль малыша",
            subtitle: "Для персонализированных рекомендаций",
            imageName: "onboarding_profile",
            buttonTitle: "Начать"
        )
    ]
    
    var currentPageIndex = 0
    var numberOfPages: Int { pages.count }
    
    func getPage(at index: Int) -> OnboardingPage? {
        guard index >= 0 && index < pages.count else { return nil }
        return pages[index]
    }
}
