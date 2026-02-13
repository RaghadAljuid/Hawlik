import SwiftUI
import MapKit
import CoreLocation

struct MapHomeView: View {

    // ✅ هذا فقط عشان التفاعل مع التاب بار من الشيت لاحقًا
    @Binding var selectedTab: AppTab

    @State private var selectedPlace: Place? = nil

    @State private var selectedBudget: Int? = nil
    @State private var selectedInterests: Set<Interest> = Preferences.loadSelectedInterests()

    @State private var showBudgetPopup = false
    @State private var showInterestPopup = false

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
        span: MKCoordinateSpan(latitudeDelta: 0.16, longitudeDelta: 0.16)
    )

    @State private var followUser = false
    @State private var places: [Place] = []
    @State private var isExpanded = false

    // يمنع سبام البحث
    @State private var searchTask: Task<Void, Never>?

    // مساحة تحت للشيت عشان التاب بار يظل قابل للضغط
    private let tabBarClearance: CGFloat = 120

    var body: some View {
        ZStack {

            // MARK: - Map
            MapViewRepresentable(
                places: places,
                region: $region,
                followUser: $followUser,
                onRequestSearchHere: {
                    requestReloadPlaces()
                },
                onSelectPlace: { place in
                    selectedPlace = place
                }
            )
            .ignoresSafeArea()

            // MARK: - Top UI
            VStack(spacing: 0) {
                TopBar(
                    showBudgetPopup: $showBudgetPopup,
                    showInterestPopup: $showInterestPopup,
                    selectedBudget: selectedBudget,
                    hasActiveInterests: !selectedInterests.isEmpty,
                    selectedInterests: $selectedInterests,
                    onDoneCategories: {
                        withAnimation(.easeInOut) { showInterestPopup = false }
                        requestReloadPlaces()
                    }
                )

                if showBudgetPopup {
                    BudgetPopup(selectedBudget: $selectedBudget) {
                        withAnimation(.easeInOut) { showBudgetPopup = false }
                        requestReloadPlaces()
                    }
                }

                Spacer()
            }

            // MARK: - Bottom Sheet
            VStack {
                Spacer()

                PlacesNearYouSheet(
                    title: "Places near you",
                    isExpanded: $isExpanded,
                    places: places,
                    onSearchHere: {
                        requestReloadPlaces()
                    }
                )
                .padding(.bottom, tabBarClearance) // 👈 مهم جدًا
            }
        }
        .onAppear {
            requestReloadPlaces()
        }
        .sheet(item: $selectedPlace) { place in
            PlaceDetailsSheet(place: place)
                .presentationDetents([.fraction(0.45), .large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Search Logic

    private func requestReloadPlaces() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 250_000_000)
            if Task.isCancelled { return }
            await reloadPlaces()
        }
    }

    @MainActor
    private func reloadPlaces() async {
        guard let first = selectedInterests.first else {
            places = []
            return
        }

        followUser = false
        places = await LocalSearchService.search(
            interest: first,
            region: region,
            budget: selectedBudget
        )
    }
}

#Preview {
    MapHomeView(selectedTab: .constant(.map))
}
