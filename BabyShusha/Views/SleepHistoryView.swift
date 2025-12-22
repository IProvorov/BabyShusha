import SwiftUI

struct SleepHistoryView: View {
    @EnvironmentObject var viewModel: SleepTrackerViewModel
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.sleepHistory.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "moon.zzz")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Нет записей сна")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 100)
                } else {
                    ForEach(viewModel.sleepHistory) { session in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(session.dateString)
                                .font(.headline)
                            
                            HStack {
                                Text(session.timeRangeString)
                                Spacer()
                                Text(session.durationString)
                                    .foregroundColor(.blue)
                            }
                            .font(.subheadline)
                            
                            if let quality = session.quality {
                                Text("Качество: \(quality)/10")
                                    .font(.caption)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("История сна")
            .refreshable {
                viewModel.loadSleepHistory()
            }
        }
    }
}
