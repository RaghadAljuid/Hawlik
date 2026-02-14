import SwiftUI

@main
struct HawlikApp: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                TripDiaryShell()   // Use the existing root shell

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
