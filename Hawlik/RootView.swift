import SwiftUI

struct RootView: View {

    @AppStorage("hasSelectedInterests") private var hasSelectedInterests = false
    @State private var selected: Set<Interest> = []

    var body: some View {
        ZStack {
            TripDiaryShell()   // ✅ هذا هو الروت الصح (اللي فيه التاب بار)

            // Popup الاهتمامات (فقط أول مرة)
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
