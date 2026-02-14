import SwiftUI

@main
struct HawlikApp: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                AppShell()   // ✅ بدل TripDiaryShell

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

