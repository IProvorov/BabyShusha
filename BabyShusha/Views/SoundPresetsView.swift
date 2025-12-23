import SwiftUI

struct SoundPresetsView: View {
    @EnvironmentObject var presetService: SoundPresetService
    @EnvironmentObject var childService: ChildProfileService
    @State private var presets: [SoundPreset] = []
    @State private var sections: [PresetSection] = []
    @State private var showingCreateSheet = false
    @State private var showingDeleteAlert = false
    @State private var presetToDelete: SoundPreset?
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Загрузка пресетов...")
                } else if presets.isEmpty {
                    EmptyPresetsView(showingCreateSheet: $showingCreateSheet)
                } else {
                    PresetsListView(
                        sections: sections,
                        onPlayPreset: playPreset,
                        onToggleFavorite: toggleFavorite,
                        onDeletePreset: confirmDelete
                    )
                }
            }
            .navigationTitle("Пресеты звуков")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreatePresetView()
            }
            .alert("Удалить пресет?", isPresented: $showingDeleteAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Удалить", role: .destructive) {
                    if let preset = presetToDelete {
                        deletePreset(preset)
                    }
                }
            } message: {
                if let preset = presetToDelete {
                    Text("Вы уверены, что хотите удалить \"\(preset.name)\"?")
                }
            }
            .onAppear {
                loadPresets()
            }
            .refreshable {
                loadPresets()
            }
        }
    }
    
    // MARK: - Data Loading
    
    private func loadPresets() {
        isLoading = true
        
        childService.getActiveChild { child in
            let allPresets = presetService.getAllPresets()
            let favorites = allPresets.filter { $0.isFavorite }
            let recommended = presetService.recommendPresets(for: child)
            let others = allPresets.filter { !$0.isFavorite && !recommended.contains($0) }
            
            var newSections: [PresetSection] = []
            
            if !favorites.isEmpty {
                newSections.append(PresetSection(title: "Избранное", presets: favorites))
            }
            
            if !recommended.isEmpty {
                newSections.append(PresetSection(title: "Рекомендованные", presets: recommended))
            }
            
            if !others.isEmpty {
                newSections.append(PresetSection(title: "Все пресеты", presets: others))
            }
            
            DispatchQueue.main.async {
                self.presets = allPresets
                self.sections = newSections
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Actions
    
    private func playPreset(_ preset: SoundPreset) {
        presetService.playPreset(preset) { success in
            DispatchQueue.main.async {
                if success {
                    showSuccessMessage("Пресет \"\(preset.name)\" запущен")
                } else {
                    showErrorMessage("Не удалось запустить пресет")
                }
            }
        }
    }
    
    private func toggleFavorite(_ preset: SoundPreset) {
        presetService.toggleFavorite(preset)
        loadPresets() // Обновляем список
    }
    
    private func confirmDelete(_ preset: SoundPreset) {
        presetToDelete = preset
        showingDeleteAlert = true
    }
    
    private func deletePreset(_ preset: SoundPreset) {
        presetService.deletePreset(preset)
        loadPresets()
        showSuccessMessage("Пресет удален")
    }
    
    // MARK: - Helpers
    
    private func showSuccessMessage(_ message: String) {
        // Можно использовать Toast или временный alert
        print("Success: \(message)")
    }
    
    private func showErrorMessage(_ message: String) {
        print("Error: \(message)")
    }
}

// MARK: - Supporting Views

struct PresetSection {
    let title: String
    let presets: [SoundPreset]
}

struct EmptyPresetsView: View {
    @Binding var showingCreateSheet: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("Нет пресетов")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Создайте первую комбинацию звуков")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button {
                showingCreateSheet = true
            } label: {
                Label("Создать пресет", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

struct PresetsListView: View {
    let sections: [PresetSection]
    let onPlayPreset: (SoundPreset) -> Void
    let onToggleFavorite: (SoundPreset) -> Void
    let onDeletePreset: (SoundPreset) -> Void
    
    var body: some View {
        List {
            ForEach(sections, id: \.title) { section in
                Section(header: Text(section.title)) {
                    ForEach(section.presets) { preset in
                        PresetRowView(
                            preset: preset,
                            onPlay: { onPlayPreset(preset) },
                            onToggleFavorite: { onToggleFavorite(preset) },
                            onDelete: { onDeletePreset(preset) }
                        )
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct PresetRowView: View {
    let preset: SoundPreset
    let onPlay: () -> Void
    let onToggleFavorite: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Иконка пресета
            Image(systemName: preset.isFavorite ? "star.fill" : "music.note")
                .font(.title2)
                .foregroundColor(preset.isFavorite ? .yellow : .blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                // Название
                Text(preset.name)
                    .font(.headline)
                
                // Описание звуков
                if !preset.sounds.isEmpty {
                    let enabledSounds = preset.sounds.filter { $0.isEnabled }
                    if enabledSounds.isEmpty {
                        Text("Нет активных звуков")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        let soundNames = enabledSounds.map { $0.type.displayName }
                        Text(soundNames.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                // Дата последнего использования
                if let lastUsed = preset.lastUsed {
                    Text("Использован \(lastUsed.formatted(.relative(presentation: .named)))")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Кнопка воспроизведения
            Button(action: onPlay) {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            // Кнопка избранного
            Button {
                onToggleFavorite()
            } label: {
                Label(preset.isFavorite ? "Убрать" : "В избранное",
                      systemImage: preset.isFavorite ? "star.slash" : "star")
            }
            .tint(.yellow)
            
            // Кнопка удаления
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
    }
}

// MARK: - Create Preset View

struct CreatePresetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var presetService: SoundPresetService
    @State private var presetName = ""
    @State private var selectedSounds: [SoundType: Bool] = [:]
    @State private var volume: Float = 0.7
    @State private var isCreating = false
    
    var body: some View {
        NavigationView {
            Form {
                // Название пресета
                Section("Название пресета") {
                    TextField("Например: Для глубокого сна", text: $presetName)
                }
                
                // Выбор звуков
                Section("Выберите звуки") {
                    ForEach(SoundType.allCases, id: \.self) { soundType in
                        SoundToggleRow(
                            soundType: soundType,
                            isEnabled: Binding(
                                get: { selectedSounds[soundType] ?? false },
                                set: { selectedSounds[soundType] = $0 }
                            )
                        )
                    }
                }
                
                // Громкость
                Section("Громкость") {
                    VStack {
                        Slider(value: $volume, in: 0...1) {
                            Text("Громкость")
                        }
                        
                        HStack {
                            Image(systemName: "speaker.fill")
                            Spacer()
                            Text("\(Int(volume * 100))%")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "speaker.wave.3.fill")
                        }
                        .foregroundColor(.secondary)
                    }
                }
                
                // Предпрослушивание
                Section {
                    Button {
                        // Предварительное прослушивание
                        previewPreset()
                    } label: {
                        Label("Предпрослушать", systemImage: "play.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(selectedSounds.values.allSatisfy { !$0 })
                }
            }
            .navigationTitle("Новый пресет")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        createPreset()
                    }
                    .disabled(presetName.isEmpty || selectedSounds.values.allSatisfy { !$0 })
                }
            }
            .overlay {
                if isCreating {
                    ProgressView()
                        .scaleEffect(1.5)
                        .background(Material.ultraThin)
                }
            }
        }
        .onAppear {
            // Инициализируем все звуки как отключенные
            for soundType in SoundType.allCases {
                selectedSounds[soundType] = false
            }
        }
    }
    
    private func previewPreset() {
        let enabledSounds = selectedSounds
            .filter { $0.value }
            .map { $0.key }
        
        // Временное воспроизведение для предпрослушивания
        for sound in enabledSounds {
            AudioService.shared.playSound(
                named: sound.fileName,
                volume: volume,
                loop: false
            ) { _ in }
        }
        
        // Остановить через 3 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            AudioService.shared.stopAll()
        }
    }
    
    private func createPreset() {
        isCreating = true
        
        let enabledSounds = selectedSounds
            .filter { $0.value }
            .map { $0.key }
        
        let preset = presetService.createPreset(
            name: presetName,
            sounds: enabledSounds,
            volume: volume
        )
        
        // Помечаем как избранный если это первый пресет
        if presetService.getAllPresets().count == 1 {
            var favoritePreset = preset
            favoritePreset.isFavorite = true
            presetService.savePreset(favoritePreset)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isCreating = false
            dismiss()
        }
    }
}

struct SoundToggleRow: View {
    let soundType: SoundType
    @Binding var isEnabled: Bool
    
    var body: some View {
        Toggle(isOn: $isEnabled) {
            HStack {
                Image(systemName: soundType.iconName)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(soundType.displayName)
                        .font(.body)
                    
                    if let ageRange = soundType.recommendedForAge {
                        Text("Рекомендуется: \(ageRange.lowerBound)-\(ageRange.upperBound) мес.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: .blue))
    }
}

// MARK: - Preview
struct SoundPresetsView_Previews: PreviewProvider {
    static var previews: some View {
        SoundPresetsView()
            .environmentObject(SoundPresetService.shared)
            .environmentObject(ChildProfileService.shared)
    }
}
