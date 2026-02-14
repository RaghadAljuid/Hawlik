import SwiftUI

struct RootView: View {
    @State private var selectedTab: AppTab = .map

    @State private var refreshID = UUID()
    @AppStorage("hasSelectedInterests") private var hasSelectedInterests = false
    @State private var selected: Set<Interest> = []
    @StateObject private var placesVM = PlacesViewModel()

    var body: some View {
        ZStack {
            MapHomeView(selectedTab: $selectedTab, vm: placesVM)
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

