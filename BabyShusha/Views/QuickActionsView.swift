struct QuickActionsView: View {
    @EnvironmentObject var quickActionsService: QuickActionsService
    @EnvironmentObject var childService: ChildProfileService
    @State private var actions: [QuickActionType] = []
    @State private var child: ChildProfile?
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Заголовок
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Быстрые действия")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Запустите одним касанием")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Информация о ребенке
                    if let child = child {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text(child.name)
                                    .font(.headline)
                                Text("\(child.ageInMonths) месяцев")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Сетка быстрых действий
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(actions, id: \.self) { action in
                            QuickActionButton(action: action)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationBarHidden(true)
            .onAppear {
                loadData()
            }
            .refreshable {
                loadData()
            }
        }
    }
    
    private func loadData() {
        childService.getActiveChild { child in
            self.child = child
            self.actions = quickActionsService.getQuickActions(for: child)
        }
    }
}

struct QuickActionButton: View {
    let action: QuickActionType
    @EnvironmentObject var quickActionsService: QuickActionsService
    @State private var isPerforming = false
    
    var body: some View {
        Button {
            performAction()
        } label: {
            VStack(spacing: 12) {
                Image(systemName: action.iconName)
                    .font(.title)
                    .foregroundColor(.white)
                
                Text(action.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .overlay(
                Group {
                    if isPerforming {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                }
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isPerforming)
    }
    
    private func performAction() {
        isPerforming = true
        quickActionsService.performQuickAction(action) { success in
            DispatchQueue.main.async {
                isPerforming = false
                
                // Тактильная обратная связь
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                
                // Показываем уведомление
                if success {
                    showSuccessAlert()
                } else {
                    showErrorAlert()
                }
            }
        }
    }
    
    private func showSuccessAlert() {
        // Можно использовать .alert или toast notification
        print("\(action.title) успешно запущен")
    }
    
    private func showErrorAlert() {
        print("Ошибка при запуске \(action.title)")
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
