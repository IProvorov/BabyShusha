import SwiftUI

struct CurrentSessionView: View {
    let elapsedTime: String
    let onStop: () -> Void
    let onAddNote: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.purple)
                    .symbolEffect(.bounce, options: .repeating)
                
                Text("Идёт отслеживание")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Circle()
                    .fill(Color.green)
                    .frame(width: 10, height: 10)
            }
            
            Text(elapsedTime)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
            
            HStack(spacing: 12) {
                Button {
                    onAddNote()
                } label: {
                    Label("Заметка", systemImage: "note.text")
                        .font(.system(size: 14, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
                
                Button {
                    onStop()
                } label: {
                    Text("Завершить")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}
