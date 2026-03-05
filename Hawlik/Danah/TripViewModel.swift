import SwiftUI
import Combine
import MapKit
import CoreLocation

final class TripViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    // MARK: - Preference (موجود عندك، ما نستخدمه هنا)
    @Published var preference = TripPreference()

    // MARK: - Nearby places
    @Published var nearbyPlaces: [TripPlace] = []
    @Published var isLoadingNearby: Bool = false
    @Published var nearbyErrorMessage: String? = nil

    // MARK: - Selection داخل SelectPlacesView
    @Published var selectedPlaces: Set<TripPlace> = []

    // MARK: - Saved (Your Trip Places)
    @Published var savedPlaces: [TripPlace] = []
    @Published var isEditing: Bool = false

    // MARK: - Private
    private let locationManager = CLLocationManager()
    private var didStartOnce = false

    private let fallbackCenter = CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753) // Riyadh
    private let searchRadiusMeters: CLLocationDistance = 3500

    private let savedPlacesKey = "hawlik.savedPlaces.v1"

    // MARK: - Init
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters

        // تحميل المحفوظات من الجهاز (عشان تبقى بعد ما تقفلين التطبيق)
        savedPlaces = Self.loadPlaces(key: savedPlacesKey)
    }

    // MARK: - Public

    /// نادِها onAppear مرة وحدة
    func startNearby() {
        guard !didStartOnce else { return }
        didStartOnce = true
        loadNearbyPlaces()
    }

    func loadNearbyPlaces() {
        nearbyErrorMessage = nil
        isLoadingNearby = true
        nearbyPlaces = []

        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .restricted, .denied:
            searchAround(center: fallbackCenter)

        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()

        @unknown default:
            searchAround(center: fallbackCenter)
        }
    }

    func togglePlace(_ place: TripPlace) {
        if selectedPlaces.contains(place) {
            selectedPlaces.remove(place)
        } else {
            selectedPlaces.insert(place)
        }
    }

    /// زر Save في SelectPlacesView
    func saveSelectedPlacesToSaved() {
        guard !selectedPlaces.isEmpty else { return }

        var merged = savedPlaces
        for p in selectedPlaces {
            if !merged.contains(where: { $0.name.lowercased() == p.name.lowercased() }) {
                merged.append(p)
            }
        }

        savedPlaces = merged.sorted { $0.name < $1.name }
        Self.savePlaces(savedPlaces, key: savedPlacesKey)

        selectedPlaces.removeAll()
    }

    func removeSavedPlace(_ place: TripPlace) {
        savedPlaces.removeAll { $0.name.lowercased() == place.name.lowercased() }
        Self.savePlaces(savedPlaces, key: savedPlacesKey)
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus

        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        } else if status == .denied || status == .restricted {
            searchAround(center: fallbackCenter)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else {
            searchAround(center: fallbackCenter)
            return
        }
        searchAround(center: loc.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        searchAround(center: fallbackCenter)
    }

    // MARK: - MKLocalSearch

    private func searchAround(center: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(
            center: center,
            latitudinalMeters: searchRadiusMeters * 2,
            longitudinalMeters: searchRadiusMeters * 2
        )

        // query -> interest
        let queries: [(query: String, interest: String)] = [
            ("Museum", "History"),
            ("Historic", "History"),

            ("Coffee", "Coffee"),
            ("Cafe", "Coffee"),

            ("Restaurant", "Food"),
            ("Food", "Food"),

            ("Park", "Nature"),
            ("Garden", "Nature"),

            ("Mall", "Shopping"),
            ("Shopping", "Shopping"),

            ("Gym", "Sports"),
            ("Sports", "Sports"),

            ("Entertainment", "Entertainment"),
            ("Cinema", "Entertainment")
        ]

        let group = DispatchGroup()
        var results: [TripPlace] = []
        var seenNames = Set<String>()

        for item in queries {
            group.enter()

            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = item.query
            request.region = region

            MKLocalSearch(request: request).start { response, _ in
                defer { group.leave() }

                guard let mapItems = response?.mapItems else { return }

                for m in mapItems {
                    let name = (m.name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !name.isEmpty else { continue }

                    let key = name.lowercased()
                    guard !seenNames.contains(key) else { continue }
                    seenNames.insert(key)

                    // budget ما نحتاجه هنا
                    let place = TripPlace(name: name, budget: "", interest: item.interest)
                    results.append(place)
                }
            }
        }

        group.notify(queue: .main) {
            self.isLoadingNearby = false
            self.nearbyPlaces = results.sorted { $0.name < $1.name }

            if self.nearbyPlaces.isEmpty {
                self.nearbyErrorMessage = "Couldn’t load nearby places. Check Location permission."
            } else {
                self.nearbyErrorMessage = nil
            }
        }
    }

    // MARK: - Persistence (UserDefaults)

    private static func savePlaces(_ places: [TripPlace], key: String) {
        let payload: [[String: String]] = places.map {
            ["name": $0.name, "budget": $0.budget, "interest": $0.interest]
        }
        UserDefaults.standard.set(payload, forKey: key)
    }

    private static func loadPlaces(key: String) -> [TripPlace] {
        guard let payload = UserDefaults.standard.array(forKey: key) as? [[String: String]] else {
            return []
        }
        return payload.compactMap { dict in
            guard let name = dict["name"] else { return nil }
            let budget = dict["budget"] ?? ""
            let interest = dict["interest"] ?? ""
            return TripPlace(name: name, budget: budget, interest: interest)
        }
    }
}
