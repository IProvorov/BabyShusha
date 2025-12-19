import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    let profile: ChildProfile?
    let onUpdate: (String?, Date?) -> Void
    
    @State private var name: String
    @State private var birthDate: Date
    
    init(profile: ChildProfile?, onUpdate: @escaping (String?, Date?) -> Void) {
        self.profile = profile
        self.onUpdate = onUpdate
        
        _name = State(initialValue: profile?.name ?? "")
        _birthDate = State(initialValue: profile?.birthDate ?? Date())
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Информация о ребёнке") {
                    TextField("Имя", text: $name)
                    
                    DatePicker(
                        "Дата рождения",
                        selection: $birthDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                }
                
                Section("Статистика") {
                    if let profile = profile {
                        InfoRow(title: "Возраст", value: profile.ageString)
                        InfoRow(title: "Рекомендуемый сон", value: profile.ageCategory.sleepRecommendation)
                    }
                }
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        onUpdate(name, birthDate)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
    }
}
