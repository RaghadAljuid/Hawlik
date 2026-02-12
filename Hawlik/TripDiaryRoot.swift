import SwiftUI

struct TripDiaryRoot: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "map")
                    .imageScale(.large)
                    .font(.system(size: 48))
                Text("Trip Diary")
                    .font(.title.bold())
                Text("Welcome! Replace this placeholder with your real root view.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Hawlik")
        }
    }
}

#Preview {
    TripDiaryRoot()
}
