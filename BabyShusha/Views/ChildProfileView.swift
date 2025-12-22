// Views/ChildProfileView.swift
import SwiftUI

struct ChildProfileView: View {
    @EnvironmentObject var viewModel: ChildProfileViewModel
    @EnvironmentObject var sleepTrackerVM: SleepTrackerViewModel
    @State private var showingAddChild = false
    @State private var newChildName = ""
    @State private var newChildBirthDate = Date()
    @State private var newChildAvatar = "👶"
    
    let avatars = ["👶", "👧", "👦", "🧒", "👼", "🐣", "🐻", "🐰"]
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.children.isEmpty {
                    emptyStateView
                } else {
                    childrenListView
                    
                    Section {
                        Button(action: {
                            showingAddChild = true
                        }) {
                            Label("Добавить ребенка", systemImage: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Профили детей")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.children.isEmpty {
                        Button {
                            showingAddChild = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddChild) {
                addChildSheet
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .padding(.top, 50)
            
            Text("Нет добавленных детей")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text("Добавьте ребенка, чтобы начать отслеживание сна")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                showingAddChild = true
            }) {
                Label("Добавить первого ребенка", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowBackground(Color.clear)
    }
    
    private var childrenListView: some View {
        Section(header: Text("Ваши дети")) {
            ForEach(viewModel.children) { child in
                ChildProfileRow(
                    child: child,
                    isActive: child.id == viewModel.activeChild?.id,
                    onSelect: {
                        viewModel.setActiveChild(child)
                        sleepTrackerVM.selectedChildId = child.id
                    },
                    onDelete: {
                        deleteChild(child)
                    }
                )
            }
        }
    }
    
    private var addChildSheet: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Имя ребенка", text: $newChildName)
                    
                    DatePicker(
                        "Дата рождения",
                        selection: $newChildBirthDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                }
                
                Section("Аватар") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(avatars, id: \.self) { avatar in
                                Button(action: {
                                    newChildAvatar = avatar
                                }) {
                                    Text(avatar)
                                        .font(.system(size: 40))
                                        .padding(10)
                                        .background(
                                            Circle()
                                                .fill(newChildAvatar == avatar ?
                                                    Color.blue.opacity(0.2) :
                                                    Color.gray.opacity(0.1))
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(newChildAvatar == avatar ?
                                                    Color.blue : Color.clear,
                                                    lineWidth: 2)
                                        )
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                Section("Возраст") {
                    let age = calculateAge(for: newChildBirthDate)
                    HStack {
                        Text("Возраст")
                        Spacer()
                        if age.years == 0 {
                            Text("\(age.months) месяцев")
                                .foregroundColor(.secondary)
                        } else {
                            Text("\(age.years) лет \(age.months) месяцев")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Новый ребенок")
            .navigationBarItems(
                leading: Button("Отмена") {
                    showingAddChild = false
                    resetForm()
                },
                trailing: Button("Сохранить") {
                    saveChild()
                }
                .disabled(newChildName.isEmpty)
            )
        }
    }
    
    private func saveChild() {
        viewModel.addChild(
            name: newChildName.trimmingCharacters(in: .whitespacesAndNewlines),
            birthDate: newChildBirthDate,
            avatarEmoji: newChildAvatar
        )
        showingAddChild = false
        resetForm()
    }
    
    private func deleteChild(_ child: ChildProfile) {
        // Простое подтверждение
        let alert = UIAlertController(
            title: "Удалить ребенка?",
            message: "Вы уверены, что хотите удалить \(child.name)? Все данные сна этого ребенка будут удалены.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { _ in
            viewModel.deleteChild(child)
        })
        
        // Показываем алерт
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
    
    private func resetForm() {
        newChildName = ""
        newChildBirthDate = Date()
        newChildAvatar = "👶"
    }
    
    private func calculateAge(for birthDate: Date) -> (years: Int, months: Int) {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: birthDate, to: now)
        return (years: components.year ?? 0, months: components.month ?? 0)
    }
}

// Компонент строки профиля ребенка
struct ChildProfileRow: View {
    let child: ChildProfile
    let isActive: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // Аватар
            Text(child.avatarEmoji)
                .font(.system(size: 40))
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                .blue.opacity(0.2),
                                .purple.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                )
            
            // Информация
            VStack(alignment: .leading, spacing: 4) {
                Text(child.name)
                    .font(.headline)
                
                Text(child.ageDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Добавлен: \(child.createdAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Статус и управление
            VStack(spacing: 10) {
                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.7))
                        .padding(6)
                        .background(Circle().fill(Color.red.opacity(0.1)))
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Удалить", systemImage: "trash")
            }
            
            if !isActive {
                Button {
                    onSelect()
                } label: {
                    Label("Выбрать", systemImage: "checkmark")
                }
                .tint(.blue)
            }
        }
    }
}
