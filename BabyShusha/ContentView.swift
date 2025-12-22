// Views/ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var sleepTrackerVM = SleepTrackerViewModel()
    @StateObject private var childProfileVM = ChildProfileViewModel()
    @StateObject private var soundPlayerVM = SoundPlayerViewModel()
    
    var body: some View {
        TabView {
            // Вкладка 1: Звуки
            SoundSelectionView()
                .environmentObject(soundPlayerVM)
                .tabItem {
                    Image(systemName: "speaker.wave.3")
                    Text("Звуки")
                }
            
            // Вкладка 2: Отслеживание сна
            SleepTrackerView()
                .environmentObject(sleepTrackerVM)
                .environmentObject(childProfileVM)
                .environmentObject(soundPlayerVM)
                .tabItem {
                    Image(systemName: "moon.zzz")
                    Text("Сон")
                }
            
            // Вкладка 3: История
            SleepHistoryView()
                .environmentObject(sleepTrackerVM)
                .tabItem {
                    Image(systemName: "clock")
                    Text("История")
                }
            
            // Вкладка 4: Профиль
            ChildProfileView()
                .environmentObject(childProfileVM)
                .environmentObject(sleepTrackerVM)
                .tabItem {
                    Image(systemName: "person")
                    Text("Профиль")
                }
        }
        .onAppear {
            setupInitialData()
        }
    }
    
    private func setupInitialData() {
        // Создаем тестового ребенка если нет
        if childProfileVM.children.isEmpty {
            let birthDate = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
            childProfileVM.addChild(name: "Малыш", birthDate: birthDate, avatarEmoji: "👶")
        }
        
        // Устанавливаем активного ребенка
        if let activeChild = childProfileVM.activeChild {
            sleepTrackerVM.selectedChildId = activeChild.id
        }
    }
}
