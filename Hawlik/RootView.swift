import SwiftUI

struct RootView: View {
    @State private var selectedTab: AppTab = .map

    @State private var refreshID = UUID()
    @AppStorage("hasSelectedInterests") private var hasSelectedInterests = false
    @State private var selected: Set<Interest> = []

    var body: some View {
        ZStack {
            MapHomeView()
                .id(refreshID)
            if !hasSelectedInterests {
                InterestPopup(selectedInterests: $selected) {
                    saveSelectedInterests(selected)
                    hasSelectedInterests = true
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: hasSelectedInterests)
    }

    private func saveSelectedInterests(_ interests: Set<Interest>) {
        let raw = interests.map { $0.rawValue }
        UserDefaults.standard.set(raw, forKey: Preferences.selectedInterestsKey)
    }
}

#Preview {
    RootView()
}
