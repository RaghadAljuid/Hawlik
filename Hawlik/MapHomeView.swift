import SwiftUI
import MapKit
import CoreLocation

struct MapHomeView: View {
    @AppStorage("didSelectInterests") private var didSelectInterests = false

    @Binding var selectedTab: AppTab
    @ObservedObject var vm: PlacesViewModel

    @StateObject private var locationManager = LocationManager()

    @State private var selectedPlace: Place? = nil
    @State private var selectedBudget: Int? = nil
    @State private var selectedInterests: Set<Interest> = []

    @State private var showBudgetPopup = false
    @State private var showInterestPopup = false
    @State private var showFirstInterestPopup = false

    // ✅ Search (submit-only)
    @State private var searchText: String = ""
    @State private var lastSubmittedQuery: String = ""
    @State private var searchedPlaces: [Place] = []
    @State private var searchTask: Task<Void, Never>? = nil
    @State private var isSearching: Bool = false

    // Default Riyadh
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
        span: MKCoordinateSpan(latitudeDelta: 0.16, longitudeDelta: 0.16)
    )

    @State private var followUser = false
    @State private var places: [Place] = []
    @State private var isExpanded = false

    @State private var didCenterOnUserOnce = false
    @State private var showRiyadhOnlyBanner = false

    private let riyadhCenter = CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753)
    private let riyadhRadiusMeters: CLLocationDistance = 70000

    private var displayedPlaces: [Place] {
        lastSubmittedQuery.isEmpty ? places : searchedPlaces
    }

    // ✅ No Results: بعد submit فقط + بعد ما يخلص البحث + ولا فيه نتائج
    private var showNoResults: Bool {
        !lastSubmittedQuery.isEmpty && !isSearching && searchedPlaces.isEmpty
    }

    var body: some View {
        ZStack {
            MapViewRepresentable(
                places: displayedPlaces,
                region: $region,
                followUser: $followUser,
                onRequestSearchHere: { Task { await reloadPlaces() } },
                onSelectPlace: { selectedPlace = $0 }
            )
            .ignoresSafeArea()

            // ✅ Banner: خارج الرياض أو ما فيه موقع
            if showRiyadhOnlyBanner {
                VStack {
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 16, weight: .semibold))

                        Text("Service available in Riyadh only")
                            .font(.system(size: 13, weight: .semibold))

                        Spacer()

                        Button { focusOnRiyadhAndSearch() } label: {
                            Text("Show Riyadh")
                                .font(.system(size: 13, weight: .bold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 14)
                    .padding(.top, 10)

                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(50)
            }

            VStack(spacing: 0) {
                TopBar(
                    showBudgetPopup: $showBudgetPopup,
                    showInterestPopup: $showInterestPopup,
                    selectedBudget: selectedBudget,
                    hasActiveInterests: !selectedInterests.isEmpty,
                    selectedInterests: $selectedInterests,
                    onDoneCategories: {
                        withAnimation(.easeInOut) { showInterestPopup = false }
                        saveInterests(selectedInterests)
                        Task { await reloadPlaces() }
                    },
                    searchText: $searchText,
                    onSearchSubmit: { text in
                        let q = text.trimmingCharacters(in: .whitespacesAndNewlines)

                        if q.isEmpty {
                            lastSubmittedQuery = ""
                            searchedPlaces = []
                            isSearching = false
                            searchTask?.cancel()
                            return
                        }

                        lastSubmittedQuery = q
                        runSearch(q)
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
            .zIndex(40)

            VStack {
                Spacer()
                PlacesNearYouSheet(
                    title: "Places near you",
                    isExpanded: $isExpanded,
                    places: displayedPlaces,
                    onSearchHere: { Task { await reloadPlaces() } }
                )
            }
            .zIndex(30)

            if showFirstInterestPopup {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()

                InterestPopup(selectedInterests: $selectedInterests) {
                    saveInterests(selectedInterests)
                    didSelectInterests = true
                    withAnimation(.easeInOut) { showFirstInterestPopup = false }
                    Task { await reloadPlaces() }
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(80)
            }
        }
        // ✅ هذا هو الفرق الحقيقي: overlay فوق كل شيء بالغصب
        .overlay {
            if showNoResults {
                VStack(spacing: 12) {
                    Image(systemName: "mappin.slash.circle.fill")
                        .font(.system(size: 58))
                        .foregroundStyle(.gray.opacity(0.6))

                    Text("No Results")
                        .font(.system(size: 18, weight: .semibold))

                    Text("Try another keyword")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 34)
                .padding(.horizontal, 28)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(radius: 10)
                .allowsHitTesting(false)
                .transition(.opacity)
            }
        }
        // ✅ إذا مسحتي النص بالكامل: رجعي للوضع الطبيعي
        .onChange(of: searchText) { _, newValue in
            let t = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if t.isEmpty {
                lastSubmittedQuery = ""
                searchedPlaces = []
                isSearching = false
                searchTask?.cancel()
            }
        }
        .onAppear {
            selectedInterests = loadInterests()
            locationManager.requestWhenInUse()

            if !didSelectInterests {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.easeInOut) { showFirstInterestPopup = true }
                }
            } else {
                Task { await reloadPlaces() }
            }
        }
        .onDisappear {
            locationManager.stopUpdates()
            searchTask?.cancel()
        }
        .onChange(of: locationManager.lastLocation) { newLoc in
            guard let newLoc else { return }

            updateRiyadhBannerIfNeeded(userLocation: newLoc)

            if !didCenterOnUserOnce {
                didCenterOnUserOnce = true
                followUser = false
                region.center = newLoc.coordinate
                Task { await reloadPlaces() }
            }
        }
        .onChange(of: locationManager.authorizationStatus) { status in
            if status == .denied || status == .restricted {
                withAnimation(.easeInOut) { showRiyadhOnlyBanner = true }
            }
        }
        .sheet(item: $selectedPlace) { place in
            PlaceDetailsSheet(place: place, vm: vm)
                .presentationDetents([.fraction(0.45), .large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Search (submit-only) + strict filter + MainActor updates
    private func runSearch(_ query: String) {
        searchTask?.cancel()

        // reset for each submit
        searchedPlaces = []
        isSearching = true

        let needle = query.lowercased()

        searchTask = Task {
            var r = region
            if showRiyadhOnlyBanner {
                r.center = riyadhCenter
            }

            let results = await LocalSearchService.searchText(
                query: query,
                region: r,
                fallbackInterest: .trending,
                budget: selectedBudget
            )

            if Task.isCancelled {
                await MainActor.run { self.isSearching = false }
                return
            }

            // ✅ فلترة صارمة عشان الكلمات الغلط تعطي No Results
            let strict = results.filter { $0.name.lowercased().contains(needle) }

            await MainActor.run {
                self.searchedPlaces = strict
                self.isSearching = false
            }
        }
    }

    // MARK: - Save/Load Interests
    private func saveInterests(_ set: Set<Interest>) {
        let titles = set.map { $0.title }
        UserDefaults.standard.set(titles, forKey: "selectedInterests")
    }

    private func loadInterests() -> Set<Interest> {
        let titles = UserDefaults.standard.stringArray(forKey: "selectedInterests") ?? []
        let matches = Interest.allCases.filter { titles.contains($0.title) }
        return Set(matches)
    }

    // MARK: - Riyadh-only
    private func updateRiyadhBannerIfNeeded(userLocation: CLLocation) {
        let riyadhLoc = CLLocation(latitude: riyadhCenter.latitude, longitude: riyadhCenter.longitude)
        let distance = userLocation.distance(from: riyadhLoc)
        let outside = distance > riyadhRadiusMeters
        withAnimation(.easeInOut) { showRiyadhOnlyBanner = outside }
    }

    private func focusOnRiyadhAndSearch() {
        followUser = false
        region.center = riyadhCenter
        region.span = MKCoordinateSpan(latitudeDelta: 0.16, longitudeDelta: 0.16)
        Task { await reloadPlaces() }
    }

    // MARK: - Reload Places
    private func reloadPlaces() async {
        // لا تخلط بحث النص مع بحث الاهتمامات
        if !lastSubmittedQuery.isEmpty { return }

        let interestToUse: Interest = selectedInterests.first ?? .coffeeShop

        if showRiyadhOnlyBanner {
            region.center = riyadhCenter
        }

        followUser = false
        places = await LocalSearchService.search(
            interest: interestToUse,
            region: region,
            budget: selectedBudget
        )
    }
}
