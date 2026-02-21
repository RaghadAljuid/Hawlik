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

            // ✅ Banner: خارج الرياض أو ما فيه موقع
            if showRiyadhOnlyBanner {
                VStack {
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 16, weight: .semibold))

                        Text("Service available in Riyadh only")
                            .font(.system(size: 13, weight: .semibold))

                        Spacer()

                        Button {
                            focusOnRiyadhAndSearch()
                        } label: {
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

            // أول مرة
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
                .zIndex(10)
            }
        }
        .onAppear {
            selectedInterests = loadInterests()

            // ✅ اطلب الإذن وابدأ التحديثات
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
        }
        // ✅ يتحدث كل ما تغير موقع السيميوليتر
        .onChange(of: locationManager.lastLocation) { newLoc in
            guard let newLoc else { return }

            updateRiyadhBannerIfNeeded(userLocation: newLoc)

            // أول مرة فقط: نسنتر على المستخدم
            if !didCenterOnUserOnce {
                didCenterOnUserOnce = true
                followUser = false
                region.center = newLoc.coordinate
                Task { await reloadPlaces() }
            }
        }
        // ✅ لو رفض الإذن
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
        let interestToUse: Interest = selectedInterests.first ?? .coffeeShop

        // إذا خارج الرياض: نخلي البحث على الرياض حتى ما يطلع فاضي
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

