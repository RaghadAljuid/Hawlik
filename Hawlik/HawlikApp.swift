import SwiftUI

@main
struct HawlikApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                AppShell()   // ✅ هذا الروت الجديد

                if showSplash {
                    Image("SplashImage")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.easeInOut(duration: 0.35)) {
                                    showSplash = false
                                }
                            }
                        }
                }
            }
        }
    }
}
