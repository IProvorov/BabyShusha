import SwiftUI

struct ChildProfileListView: View {
    @StateObject private var viewModel = ChildProfileViewModel()
    @State private var showingAddChildSheet = false
    @State private var showingEditChildSheet: ChildProfile?
    @State private var showingDeleteAlert: ChildProfile?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фон
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.1, blue: 0.15),
                        Color(red: 0.1, green: 0.05, blue: 0.2)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.children.isEmpty {
                    emptyStateView
                } else {
                    contentView
                }
            }
            .navigationTitle("Профили детей")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddChildSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
            .sheet(isPresented: $showingAddChildSheet) {
                AddChildView(onSave: { name, birthDate, emoji in
                    viewModel.addChild(name: name, birthDate: birthDate, avatarEmoji: emoji)
                })
            }
            .sheet(item: $showingEditChildSheet) { child in
                EditChildView(
                    child: child,
                    onSave: { updatedChild in
                        viewModel.updateChild(updatedChild)
                    }
                )
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.purple)
            
            Text("Загружаем профили...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding(.top, 20)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 80))
                .foregroundColor(.purple.opacity(0.5))
            
            Text("Нет профилей детей")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Добавьте профиль вашего ребенка для отслеживания сна")
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                showingAddChildSheet = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Добавить ребенка")
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(15)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Активный ребенок
                if let activeChild = viewModel.activeChild {
                    ActiveChildCard(child: activeChild)
                        .padding(.horizontal)
                }
                
                // Все дети
                VStack(spacing: 12) {
                    ForEach(viewModel.children) { child in
                        ChildProfileCard(
                            child: child,
                            isActive: child.id == viewModel.activeChild?.id,
                            onSelect: {
                                viewModel.setActiveChild(child)
                            },
                            onEdit: {
                                showingEditChildSheet = child
                            },
                            onDelete: {
                                showingDeleteAlert = child
                            }
                        )
                        .padding(.horizontal)
                    }
                }
                
                // Кнопка добавления
                Button {
                    showingAddChildSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Добавить ещё ребенка")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .foregroundColor(.purple)
                    .cornerRadius(15)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer(minLength: 50)
            }
            .padding(.vertical)
        }
        .alert("Удалить профиль?", isPresented: Binding(
            get: { showingDeleteAlert != nil },
            set: { if !$0 { showingDeleteAlert = nil } }
        )) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                if let child = showingDeleteAlert {
                    viewModel.deleteChild(child)
                }
            }
        } message: {
            if let child = showingDeleteAlert {
                Text("Вы уверены, что хотите удалить профиль \(child.name)? Все данные о сне будут сохранены.")
            }
        }
    }
}

// MARK: - Child Profile Card
struct ChildProfileCard: View {
    let child: ChildProfile
    let isActive: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Аватар
            Text(child.avatarEmoji)
                .font(.system(size: 40))
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(isActive ? Color.purple.opacity(0.2) : Color.gray.opacity(0.1))
                        .overlay(
                            Circle()
                                .stroke(isActive ? Color.purple : Color.gray.opacity(0.3), lineWidth: 2)
                        )
                )
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(child.name)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    if isActive {
                        Text("Активный")
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                
                Text(child.ageString)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Сон: \(child.sleepGoalFormatted)")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Кнопки действий
            Menu {
                Button {
                    onSelect()
                } label: {
                    Label("Сделать активным", systemImage: "checkmark.circle")
                }
                
                Button {
                    onEdit()
                } label: {
                    Label("Редактировать", systemImage: "pencil")
                }
                
                Divider()
                
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Удалить", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 22))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isActive ? Color.purple.opacity(0.3) : .clear, lineWidth: 2)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}

// MARK: - Active Child Card
struct ActiveChildCard: View {
    let child: ChildProfile
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(child.avatarEmoji)
                    .font(.system(size: 50))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Сейчас отслеживается")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(child.name)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        Label(child.ageString, systemImage: "calendar")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Label(child.sleepGoalFormatted, systemImage: "clock")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
            }
            
            if !child.notes.isEmpty {
                Text(child.notes)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

// MARK: - Add Child View
struct AddChildView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var birthDate = Date()
    @State private var selectedEmoji = "👶"
    @State private var showingDatePicker = false
    
    let onSave: (String, Date, String) -> Void
    
    let emojis = ["👶", "🐻", "🐰", "🐶", "🐱", "🐯", "🦁", "🐮", "🐷", "🐸", "🐥", "🦊"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Имя ребенка", text: $name)
                        .autocapitalization(.words)
                    
                    Button {
                        showingDatePicker = true
                    } label: {
                        HStack {
                            Text("Дата рождения")
                            Spacer()
                            Text(birthDate, style: .date)
                                .foregroundColor(.secondary)
                            Image(systemName: "calendar")
                                .foregroundColor(.purple)
                        }
                    }
                    
                    if showingDatePicker {
                        DatePicker(
                            "Дата рождения",
                            selection: $birthDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                    }
                }
                
                Section("Аватар") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(emojis, id: \.self) { emoji in
                                Button {
                                    selectedEmoji = emoji
                                } label: {
                                    Text(emoji)
                                        .font(.system(size: 40))
                                        .padding(10)
                                        .background(
                                            Circle()
                                                .fill(selectedEmoji == emoji ? Color.purple.opacity(0.2) : Color.clear)
                                                .overlay(
                                                    Circle()
                                                        .stroke(selectedEmoji == emoji ? Color.purple : Color.gray.opacity(0.3), lineWidth: 2)
                                                )
                                        )
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                Section("Рекомендации") {
                    let age = calculateAge(from: birthDate)
                    let category = getAgeCategory(months: age)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Возрастная категория:")
                            Spacer()
                            Text(category.rawValue)
                                .foregroundColor(.purple)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("Рекомендуемый сон:")
                            Spacer()
                            Text(category.sleepRecommendation)
                                .foregroundColor(.green)
                                .fontWeight(.medium)
                        }
                    }
                    .font(.subheadline)
                }
            }
            .navigationTitle("Новый ребенок")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        onSave(name.trimmingCharacters(in: .whitespaces), birthDate, selectedEmoji)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func calculateAge(from date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: date, to: Date())
        return components.month ?? 0
    }
    
    private func getAgeCategory(months: Int) -> AgeCategory {
        switch months {
        case 0..<3: return .newborn
        case 3..<6: return .infant
        case 6..<12: return .baby
        case 12..<24: return .toddler
        case 24..<36: return .preschooler
        default: return .child
        }
    }
}

// MARK: - Edit Child View
struct EditChildView: View {
    let child: ChildProfile
    @Environment(\.dismiss) private var dismiss
    @State private var editedChild: ChildProfile
    @State private var showingSleepGoalSheet = false
    
    let onSave: (ChildProfile) -> Void
    
    init(child: ChildProfile, onSave: @escaping (ChildProfile) -> Void) {
        self.child = child
        self.onSave = onSave
        _editedChild = State(initialValue: child)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Имя", text: $editedChild.name)
                    
                    DatePicker(
                        "Дата рождения",
                        selection: $editedChild.birthDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    
                    Picker("Аватар", selection: $editedChild.avatarEmoji) {
                        ForEach(["👶", "🐻", "🐰", "🐶", "🐱", "🐯", "🦁", "🐮", "🐷", "🐸"], id: \.self) { emoji in
                            Text(emoji).tag(emoji)
                        }
                    }
                }
                
                Section("Режим сна") {
                    HStack {
                        Text("Цель сна в сутки")
                        Spacer()
                        Text(editedChild.sleepGoalFormatted)
                            .foregroundColor(.purple)
                            .fontWeight(.medium)
                        
                        Button {
                            showingSleepGoalSheet = true
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section("Заметки") {
                    TextEditor(text: $editedChild.notes)
                        .frame(height: 100)
                }
                
                Section("Статистика") {
                    HStack {
                        Text("Возраст")
                        Spacer()
                        Text(editedChild.ageString)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Категория")
                        Spacer()
                        Text(editedChild.ageCategory.rawValue)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Рекомендуемый сон")
                        Spacer()
                        Text(editedChild.ageCategory.sleepRecommendation)
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("Редактировать профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        onSave(editedChild)
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingSleepGoalSheet) {
                SleepGoalSheet(sleepGoalHours: $editedChild.sleepGoalHours)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Sleep Goal Sheet
struct SleepGoalSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var sleepGoalHours: Double
    
    @State private var hours: Int
    @State private var minutes: Int
    
    init(sleepGoalHours: Binding<Double>) {
        self._sleepGoalHours = sleepGoalHours
        let totalMinutes = Int(sleepGoalHours.wrappedValue * 60)
        _hours = State(initialValue: totalMinutes / 60)
        _minutes = State(initialValue: totalMinutes % 60)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Круговой селектор
                VStack(spacing: 20) {
                    Text("Цель сна")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 30) {
                        // Часы
                        VStack {
                            Picker("Часы", selection: $hours) {
                                ForEach(0..<24, id: \.self) { hour in
                                    Text("\(hour) ч").tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 100, height: 150)
                            
                            Text("часов")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Минуты
                        VStack {
                            Picker("Минуты", selection: $minutes) {
                                ForEach(0..<60, id: \.self) { minute in
                                    Text("\(minute) м").tag(minute)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 100, height: 150)
                            
                            Text("минут")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text("Всего: \(hours) ч \(minutes) м")
                        .font(.headline)
                        .foregroundColor(.purple)
                }
                .padding()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Настройка цели сна")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        sleepGoalHours = Double(hours) + Double(minutes) / 60.0
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview
struct ChildProfileListView_Previews: PreviewProvider {
    static var previews: some View {
        ChildProfileListView()
    }
}
