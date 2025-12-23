import SwiftUI
import Combine

@main
struct BabyShushaApp: App {
    // MARK: - App Storage
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    @AppStorage("selectedTab") private var selectedTab = 0
    
    // MARK: - State Objects (Сервисы)
    @StateObject private var nightModeService = NightModeService.shared
    @StateObject private var quickActionsService = QuickActionsService.shared
    @StateObject private var soundPresetService = SoundPresetService.shared
    @StateObject private var recommendationService = SleepRecommendationService.shared
    @StateObject private var childProfileService = ChildProfileService.shared
    @StateObject private var sleepTrackingService = SleepTrackingService.shared
    @StateObject private var audioService = AudioService.shared
    @StateObject private var notificationService = NotificationService.shared
    
    // MARK: - State
    @State private var showSplash = true
    @State private var activeChild: ChildProfile?
    @State private var showQuickActionToast = false
    @State private var quickActionMessage = ""
    @State private var isPlayingAudio = false
    
    // MARK: - Scene
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Splash screen
                if showSplash {
                    SplashScreen()
                        .transition(.opacity)
                } else {
                    // Main content
                    Group {
                        if hasCompletedOnboarding {
                            MainTabView(selectedTab: $selectedTab)
                                .environmentObject(nightModeService)
                                .environmentObject(quickActionsService)
                                .environmentObject(soundPresetService)
                                .environmentObject(recommendationService)
                                .environmentObject(childProfileService)
                                .environmentObject(sleepTrackingService)
                                .environmentObject(audioService)
                                .environmentObject(notificationService)
                                .preferredColorScheme(nightModeService.isNightModeEnabled ? .dark : .light)
                                .onAppear {
                                    setupAppLifecycleObservers()
                                    checkFirstLaunch()
                                }
                        } else {
                            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                                .environmentObject(childProfileService)
                                .environmentObject(soundPresetService)
                        }
                    }
                    .transition(.opacity)
                }
                
                // Quick Action Toast
                if showQuickActionToast {
                    QuickActionToast(message: quickActionMessage)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showSplash)
            .animation(.easeInOut, value: hasCompletedOnboarding)
            .onAppear {
                // Hide splash after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        showSplash = false
                    }
                }
                
                // Setup initial services
                setupServices()
            }
            .onOpenURL { url in
                handleDeepLink(url)
            }
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupServices() {
        // Setup audio session
        audioService.setupAudioSession()
        
        // Request notification permissions
        notificationService.requestAuthorization()
        
        // Load active child
        childProfileService.loadActiveChild { child in
            self.activeChild = child
        }
        
        // Setup night mode auto check
        if nightModeService.autoNightMode {
            nightModeService.checkAutoNightMode()
        }
        
        // Setup quick actions
        quickActionsService.setupQuickActions()
    }
    
    private func setupAppLifecycleObservers() {
        // Handle app lifecycle
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            handleAppWillResignActive()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            handleAppDidBecomeActive()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            handleAppDidEnterBackground()
        }
    }
    
    private func checkFirstLaunch() {
        if isFirstLaunch {
            // Create default sound presets
            createDefaultPresets()
            isFirstLaunch = false
        }
    }
    
    private func createDefaultPresets() {
        let defaultPresets = [
            SoundPreset(
                id: UUID(),
                name: "Для новорожденного",
                sounds: [
                    SoundPreset.SoundConfiguration(type: .heartbeat, isEnabled: true, individualVolume: 0.7),
                    SoundPreset.SoundConfiguration(type: .whiteNoise, isEnabled: true, individualVolume: 0.5)
                ],
                volume: 0.6,
                isFavorite: true,
                createdAt: Date()
            ),
            SoundPreset(
                id: UUID(),
                name: "Глубокий сон",
                sounds: [
                    SoundPreset.SoundConfiguration(type: .rain, isEnabled: true, individualVolume: 0.8),
                    SoundPreset.SoundConfiguration(type: .whiteNoise, isEnabled: false, individualVolume: 0.0)
                ],
                volume: 0.5,
                isFavorite: true,
                createdAt: Date()
            ),
            SoundPreset(
                id: UUID(),
                name: "Поездка на машине",
                sounds: [
                    SoundPreset.SoundConfiguration(type: .carRide, isEnabled: true, individualVolume: 0.9)
                ],
                volume: 0.7,
                isFavorite: false,
                createdAt: Date()
            )
        ]
        
        for preset in defaultPresets {
            soundPresetService.savePreset(preset)
        }
    }
    
    // MARK: - App Lifecycle Handlers
    
    private func handleAppWillResignActive() {
        // Save current state
        nightModeService.saveSettings()
        
        // If night mode is on, reduce volume
        if nightModeService.isNightModeEnabled {
            audioService.setVolume(0.3)
        }
    }
    
    private func handleAppDidBecomeActive() {
        // Check auto night mode
        if nightModeService.autoNightMode {
            nightModeService.checkAutoNightMode()
        }
        
        // Refresh active child
        childProfileService.loadActiveChild { child in
            self.activeChild = child
        }
        
        // Update widget data if needed
        updateWidgetData()
    }
    
    private func handleAppDidEnterBackground() {
        // Schedule night mode notification if active
        if nightModeService.isNightModeEnabled {
            notificationService.scheduleNightModeNotification()
        }
        
        // Save sleep sessions if tracking
        if sleepTrackingService.isTracking {
            sleepTrackingService.saveCurrentSession()
        }
    }
    
    // MARK: - Deep Link Handling
    
    private func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }
        
        switch components.host {
        case "quickaction":
            handleQuickActionDeepLink(components.path)
        case "preset":
            handlePresetDeepLink(components.path)
        case "nightmode":
            handleNightModeDeepLink()
        case "child":
            handleChildDeepLink(components.path)
        default:
            break
        }
    }
    
    private func handleQuickActionDeepLink(_ path: String) {
        let action: QuickActionType
        
        switch path {
        case "/whitenoise":
            action = .whiteNoise
        case "/heartbeat":
            action = .heartbeat
        case "/rain":
            action = .rain
        case "/lullaby":
            action = .lullaby
        case "/timer30":
            action = .timer30
        case "/timer60":
            action = .timer60
        default:
            return
        }
        
        quickActionsService.performQuickAction(action) { success in
            if success {
                showQuickActionToast("\(action.title) запущен")
            }
        }
        
        // Switch to quick actions tab
        selectedTab = 0
    }
    
    private func handlePresetDeepLink(_ path: String) {
        let presetId = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let uuid = UUID(uuidString: presetId),
              let preset = soundPresetService.getPreset(by: uuid) else {
            return
        }
        
        soundPresetService.playPreset(preset) { success in
            if success {
                showQuickActionToast("Пресет \"\(preset.name)\" запущен")
            }
        }
        
        // Switch to presets tab
        selectedTab = 1
    }
    
    private func handleNightModeDeepLink() {
        nightModeService.toggleNightMode()
        showQuickActionToast(
            nightModeService.isNightModeEnabled ?
            "Ночной режим включен" : "Ночной режим выключен"
        )
        
        // Switch to night mode tab
        selectedTab = 2
    }
    
    private func handleChildDeepLink(_ path: String) {
        // Handle child profile deep link
        // Можно реализовать открытие профиля ребенка
        selectedTab = 4 // Profile tab
    }
    
    // MARK: - Helper Methods
    
    private func showQuickActionToast(_ message: String) {
        quickActionMessage = message
        showQuickActionToast = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showQuickActionToast = false
            }
        }
    }
    
    private func updateWidgetData() {
        // Update shared data for widgets
        if let child = activeChild,
           let encoded = try? JSONEncoder().encode(child) {
            UserDefaults(suiteName: "group.com.babyshusha")?.set(encoded, forKey: "active_child")
        }
        
        // Update favorite preset
        let favoritePresets = soundPresetService.getFavoritePresets()
        if let favorite = favoritePresets.first,
           let encoded = try? JSONEncoder().encode(favorite) {
            UserDefaults(suiteName: "group.com.babyshusha")?.set(encoded, forKey: "favorite_preset")
        }
    }
}

// MARK: - Splash Screen
struct SplashScreen: View {
    @State private var scale = 0.5
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                Text("BabyShusha")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(opacity)
                
                Text("Сладких снов вашему малышу")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

// MARK: - Quick Action Toast
struct QuickActionToast: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            Text(message)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
        .padding(.top, 50)
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var nightModeService: NightModeService
    @State private var showAddMenu = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Быстрые действия
            QuickActionsView()
                .tabItem {
                    Label("Быстро", systemImage: "bolt.fill")
                }
                .tag(0)
            
            // Tab 2: Пресеты звуков
            SoundPresetsView()
                .tabItem {
                    Label("Пресеты", systemImage: "music.note.list")
                }
                .tag(1)
            
            // Tab 3: Ночной режим
            NightModeView()
                .tabItem {
                    Label("Ночь", systemImage: "moon.fill")
                }
                .tag(2)
            
            // Tab 4: Рекомендации
            RecommendationsView()
                .tabItem {
                    Label("Советы", systemImage: "lightbulb.fill")
                }
                .tag(3)
            
            // Tab 5: Профиль
            ChildProfileView()
                .tabItem {
                    Label("Профиль", systemImage: "person.fill")
                }
                .tag(4)
        }
        .accentColor(.blue)
        .overlay(
            // Floating Add Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showAddMenu.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            )
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        )
        .sheet(isPresented: $showAddMenu) {
            AddMenuView()
        }
    }
}

// MARK: - Add Menu View
struct AddMenuView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Новый пресет звуков") {
                    NavigationLink {
                        CreatePresetView()
                    } label: {
                        Label("Создать пресет", systemImage: "music.note.list")
                    }
                }
                
                Section("Настройки сна") {
                    NavigationLink {
                        SleepTimerView()
                    } label: {
                        Label("Таймер сна", systemImage: "timer")
                    }
                    
                    NavigationLink {
                        SleepHistoryView()
                    } label: {
                        Label("История сна", systemImage: "chart.bar.fill")
                    }
                }
                
                Section("Профиль") {
                    NavigationLink {
                        AddChildView()
                    } label: {
                        Label("Добавить ребенка", systemImage: "person.badge.plus")
                    }
                }
            }
            .navigationTitle("Добавить")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Placeholder Views (для завершения структуры)
struct RecommendationsView: View {
    var body: some View {
        NavigationView {
            Text("Рекомендации по сну")
                .navigationTitle("Советы")
        }
    }
}

struct ChildProfileView: View {
    var body: some View {
        NavigationView {
            Text("Профиль ребенка")
                .navigationTitle("Профиль")
        }
    }
}

struct CreatePresetView: View {
    var body: some View {
        Text("Создание пресета")
    }
}

struct SleepTimerView: View {
    var body: some View {
        Text("Таймер сна")
    }
}

struct SleepHistoryView: View {
    var body: some View {
        Text("История сна")
    }
}

struct AddChildView: View {
    var body: some View {
        Text("Добавить ребенка")
    }
}

// MARK: - Preview
struct BabyShushaApp_Previews: PreviewProvider {
    static var previews: some View {
        BabyShushaApp()
            .previewDevice("iPhone 14 Pro")
    }
}
