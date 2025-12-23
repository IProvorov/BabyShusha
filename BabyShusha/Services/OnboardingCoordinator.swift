import UIKit

final class OnboardingCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var delegate: OnboardingCoordinatorDelegate?
    
    private let userDefaults: UserDefaultsManager
    
    init(navigationController: UINavigationController, userDefaults: UserDefaultsManager = .shared) {
        self.navigationController = navigationController
        self.userDefaults = userDefaults
    }
    
    func start() {
        if userDefaults.isOnboardingCompleted {
            delegate?.onboardingDidFinish()
        } else {
            showOnboarding()
        }
    }
    
    private func showOnboarding() {
        let viewModel = OnboardingViewModel()
        let viewController = OnboardingViewController(viewModel: viewModel)
        viewController.delegate = self
        navigationController.setViewControllers([viewController], animated: true)
    }
}

protocol OnboardingCoordinatorDelegate: AnyObject {
    func onboardingDidFinish()
}

extension OnboardingCoordinator: OnboardingViewControllerDelegate {
    func onboardingDidComplete() {
        userDefaults.isOnboardingCompleted = true
        delegate?.onboardingDidFinish()
    }
}
