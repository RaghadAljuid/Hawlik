import SwiftUI

struct TripsView: View {
    var body: some View {
        ZStack {
            AppBackground()
            Text("Trips")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
        }
    }
}

struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color.blue, Color.purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    TripsView()
}
