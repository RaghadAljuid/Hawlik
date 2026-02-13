import SwiftUI
import Combine

// MARK: - Model
struct Trip: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var imageData: Data?
}

// MARK: - Store
@MainActor
final class TripStore: ObservableObject {
    @Published var trips: [Trip] = []

    func addTrip(name: String, imageData: Data?) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = trimmed.isEmpty ? "Riyadh Trip" : trimmed
        trips.insert(Trip(name: finalName, imageData: imageData), at: 0)
    }

    func delete(_ trip: Trip) {
        trips.removeAll { $0.id == trip.id }
    }

    func rename(_ trip: Trip, to newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let idx = trips.firstIndex(where: { $0.id == trip.id }) else { return }
        trips[idx].name = trimmed
    }
}

// MARK: - Root Shell (تاب بار فقط)
struct TripDiaryShell: View {
    @StateObject private var store = TripStore()
    @State private var selectedTab: AppTab = .map

    var body: some View {
        ZStack {
            switch selectedTab {

            case .map:
                MapHomeView(selectedTab: $selectedTab)

            case .document:
                TripsView()
                    .environmentObject(store)

            case .bookmark:
                ZStack {
                    AppBackground()
                    Text("Bookmarks")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            AppTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                .background(Color.clear)
        }
    }
}

// MARK: - Preview
#Preview {
    TripDiaryShell()
}
