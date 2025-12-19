import SwiftUI

struct AddNoteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var quality = 8
    @State private var notes = ""
    @State private var selectedMood: String?
    
    let onSave: (Int?, String?, String?) -> Void
    
    let moods = ["😊", "😴", "😢", "👍", "❓"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Оценка качества
                VStack(spacing: 12) {
                    Text("Качество сна")
                        .font(.headline)
                    
                    HStack(spacing: 5) {
                        ForEach(1...10, id: \.self) { number in
                            Button {
                                quality = number
                            } label: {
                                Text("\(number)")
                                    .font(.system(size: 16, weight: .medium))
                                    .frame(width: 30, height: 30)
                                    .background(
                                        Circle()
                                            .fill(quality >= number ? Color.purple : Color.gray.opacity(0.3))
                                    )
                                    .foregroundColor(quality >= number ? .white : .primary)
                            }
                        }
                    }
                }
                .padding(.vertical)
                
                // Настроение
                VStack(spacing: 12) {
                    Text("Настроение малыша")
                        .font(.headline)
                    
                    HStack(spacing: 16) {
                        ForEach(moods, id: \.self) { mood in
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
                
                // Заметки
                VStack(alignment: .leading, spacing: 8) {
                    Text("Заметки")
                        .font(.headline)
                    
                    TextEditor(text: $notes)
                        .frame(height: 100)
                        .padding(4)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Завершение сеанса")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        onSave(quality, notes.isEmpty ? nil : notes, selectedMood)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
