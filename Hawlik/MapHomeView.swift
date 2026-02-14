import SwiftUI
import MapKit
import CoreLocation

struct MapHomeView: View {
    @AppStorage("didSelectInterests") private var didSelectInterests = false

    @Binding var selectedTab: AppTab
    @ObservedObject var vm: PlacesViewModel

    @State private var selectedPlace: Place? = nil
    @State private var selectedBudget: Int? = nil

    // ✅ تحميل الاهتمامات من UserDefaults (حل سريع)
    @State private var selectedInterests: Set<Interest> = []

    @State private var showBudgetPopup = false
    @State private var showInterestPopup = false          // من TopBar (تعديل لاحق)
    @State private var showFirstInterestPopup = false     // ✅ أول مرة دخول

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
        span: MKCoordinateSpan(latitudeDelta: 0.16, longitudeDelta: 0.16)
    )

    @State private var followUser = false
    @State private var places: [Place] = []
    @State private var isExpanded = false

    var body: some View {
        ZStack {
            MapViewRepresentable(
                places: places,
                region: $region,
                followUser: $followUser,
                onRequestSearchHere: { Task { await reloadPlaces() } },
                onSelectPlace: { selectedPlace = $0 }
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                TopBar(
                    showBudgetPopup: $showBudgetPopup,
                    showInterestPopup: $showInterestPopup,
                    selectedBudget: selectedBudget,
                    hasActiveInterests: !selectedInterests.isEmpty,
                    selectedInterests: $selectedInterests,
                    onDoneCategories: {
                        withAnimation(.easeInOut) { showInterestPopup = false }

                        // ✅ حفظ سريع
                        saveInterests(selectedInterests)

                        // ✅ تحديث الخريطة
                        Task { await reloadPlaces() }
                    }
                )

                if showBudgetPopup {
                    BudgetPopup(selectedBudget: $selectedBudget) {
                        withAnimation(.easeInOut) { showBudgetPopup = false }
                        Task { await reloadPlaces() }
                    }
                }

                Spacer()
            }

            VStack {
                Spacer()
                PlacesNearYouSheet(
                    title: "Places near you",
                    isExpanded: $isExpanded,
                    places: places,
                    onSearchHere: { Task { await reloadPlaces() } }
                )
            }

            // ✅ Interest Popup لأول مرة فقط
            if showFirstInterestPopup {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()

                InterestPopup(selectedInterests: $selectedInterests) {
                    // Continue
                    saveInterests(selectedInterests)
                    didSelectInterests = true

                    withAnimation(.easeInOut) {
                        showFirstInterestPopup = false
                    }

                    Task { await reloadPlaces() }
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(10)
            }
        }
        .onAppear {
            // ✅ حمّل الاهتمامات أول ما يفتح الماب
            selectedInterests = loadInterests()

            if !didSelectInterests {
                // أول مرة: طلع البوب-أب بعد شوي
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.easeInOut) {
                        showFirstInterestPopup = true
                    }
                }
            } else {
                // مو أول مرة: حدّث مباشرة
                Task { await reloadPlaces() }
            }
        }
        .sheet(item: $selectedPlace) { place in
            PlaceDetailsSheet(place: place, vm: vm)
                .presentationDetents([.fraction(0.45), .large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Quick Save/Load (Temporary)

    private func saveInterests(_ set: Set<Interest>) {
        // حل سريع يعتمد على title
        let titles = set.map { $0.title }
        UserDefaults.standard.set(titles, forKey: "selectedInterests")
    }

    private func loadInterests() -> Set<Interest> {
        let titles = UserDefaults.standard.stringArray(forKey: "selectedInterests") ?? []
        let matches = Interest.allCases.filter { titles.contains($0.title) }
        return Set(matches)
    }

    // MARK: - Reload Places

    private func reloadPlaces() async {
        guard let first = selectedInterests.first else { return }
        followUser = false
        places = await LocalSearchService.search(
            interest: first,
            region: region,
            budget: selectedBudget
        )
    }
}

