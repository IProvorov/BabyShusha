import SwiftUI

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var noteText = ""
    @State private var selectedMood: String?
    
    let onSave: (String, String?) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Выбор настроения
                moodSelectionView
                
                // Текстовое поле
                TextEditor(text: $noteText)
                    .frame(height: 150)
                    .padding(4)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                Spacer()
            }
            .padding()
            .navigationTitle("Заметка о сне")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        onSave(noteText, selectedMood)
                        dismiss()
                    }
                    .disabled(noteText.isEmpty && selectedMood == nil)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private var moodSelectionView: some View {
        VStack(spacing: 12) {
            Text("Настроение малыша")
                .font(.headline)
            
            HStack(spacing: 16) {
                ForEach(["😊", "😴", "😢", "👍", "❓"], id: \.self) { mood in
                    Button {
                        selectedMood = mood
                    } label: {
                        Text(mood)
                            .font(.system(size: 30))
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(selectedMood == mood ? Color.purple.opacity(0.3) : Color.clear)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedMood == mood ? Color.purple : Color.gray.opacity(0.3), lineWidth: 2)
                                    )
                            )
                    }
                }
            }
        }
    }
}
