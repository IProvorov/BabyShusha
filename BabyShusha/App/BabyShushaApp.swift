import SwiftUI

@main
struct BabyShushaApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    // ViewModels
    @StateObject private var sleepTrackerVM = SleepTrackerViewModel()
    @StateObject private var childProfileVM = ChildProfileViewModel()
    @StateObject private var soundPlayerVM = SoundPlayerViewModel()
    
    // Services
    @StateObject private var nightModeService = NightModeService()
    @StateObject private var dataStorageService = DataStorageService()
    
    // QuickActionsService с dependency injection
    @StateObject private var quickActionsService: QuickActionsService
    
    // AudioService как environment value
    private let audioService = AudioService.shared
    
    init() {
        // Инициализируем QuickActionsService с зависимостью
        let quickActions = QuickActionsService(audioService: audioService)
        _quickActionsService = StateObject(wrappedValue: quickActions)
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if hasCompletedOnboarding {
                    ContentView()
                        .environmentObject(sleepTrackerVM)
                        .environmentObject(childProfileVM)
                        .environmentObject(soundPlayerVM)
                        .environmentObject(nightModeService)
                        .environmentObject(dataStorageService)
                        .environmentObject(quickActionsService)
                        .environment(\.audioService, audioService)
                        .preferredColorScheme(nightModeService.isNightModeEnabled ? .dark : .light)
                } else {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                        .environmentObject(childProfileVM)
                        .environment(\.audioService, audioService)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: hasCompletedOnboarding)
        }
    }
}

// Environment Key для AudioService
struct AudioServiceKey: EnvironmentKey {
    static let defaultValue = AudioService.shared
}

extension EnvironmentValues {
    var audioService: AudioService {
        get { self[AudioServiceKey.self] }
        set { self[AudioServiceKey.self] = newValue }
    }
}
