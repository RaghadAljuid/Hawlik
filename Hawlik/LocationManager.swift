//
//  LocationManager.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 02/09/1447 AH.
//
import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var lastLocation: CLLocation?

    private let manager = CLLocationManager()

    override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 50   // يقلل التحديثات الزائدة
    }

    // اطلب إذن
    func requestWhenInUse() {
        if authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            // إذا مسموح، نبدأ تحديثات
            if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
                startUpdates()
            }
        }
    }

    // ✅ يبدأ يراقب الموقع (عشان السيميوليتر إذا غيرتيه يتحرك)
    func startUpdates() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        manager.startUpdatingLocation()
    }

    func stopUpdates() {
        manager.stopUpdatingLocation()
    }

    // MARK: - Delegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            startUpdates()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error:", error.localizedDescription)
    }
}
