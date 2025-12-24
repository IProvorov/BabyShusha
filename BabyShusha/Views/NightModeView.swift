import SwiftUI

struct NightModeView: View {
    @EnvironmentObject var nightModeService: NightModeService
    @EnvironmentObject var quickActionsService: QuickActionsService
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Ночной режим")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    nightModeService.toggleNightMode()
                } label: {
                    VStack {
                        Image(systemName: nightModeService.isNightModeEnabled ?
                              "moon.stars.fill" : "moon.fill")
                            .font(.system(size: 60))
                        
                        Text(nightModeService.isNightModeEnabled ?
                             "Выключить ночной режим" : "Включить ночной режим")
                            .font(.headline)
                            .padding(.top, 20)
                    }
                    .foregroundColor(.white)
                    .frame(width: 250, height: 250)
                    .background(nightModeService.isNightModeEnabled ?
                               Color.black : Color.blue)
                    .cornerRadius(125)
                }
                
                Spacer()
                
                if nightModeService.isNightModeEnabled {
                    Text("Яркость уменьшена")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
}
