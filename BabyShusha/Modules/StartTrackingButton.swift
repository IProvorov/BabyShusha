import SwiftUI

struct StartTrackingButton: View {
    let onStart: () -> Void
    
    var body: some View {
        Button {
            onStart()
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "moon.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .symbolEffect(.bounce)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Начать отслеживание сна")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Нажмите когда малыш засыпает")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
            )
            .shadow(color: .purple.opacity(0.3), radius: 15, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.horizontal)
    }
}
