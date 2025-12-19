import SwiftUI

struct SleepHistoryView: View {
    let sessions: [SleepSession]
    let onDelete: (SleepSession) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            if sessions.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(sessions) { session in
                        HistoryDetailRow(session: session)
                            .swipeActions {
                                Button(role: .destructive) {
                                    onDelete(session)
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("История сна")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Готово") {
                    dismiss()
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "moon.zzz")
                .font(.system(size: 60))
                .foregroundColor(.purple.opacity(0.5))
            
            Text("История сна пуста")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Начните отслеживать сон, чтобы увидеть историю")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

struct HistoryDetailRow: View {
    let session: SleepSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(session.dateString)
                    .font(.headline)
                
                Spacer()
                
                if let quality = session.quality {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        
                        Text("\(quality)/10")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
            
            Text(session.timeRangeString)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text(session.durationString)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                
                Spacer()
                
                if let mood = session.mood {
                    Text(mood)
                        .font(.title2)
                }
            }
            
            if let notes = session.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
    }
}
