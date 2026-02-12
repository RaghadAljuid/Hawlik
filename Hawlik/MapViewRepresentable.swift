//
//  MapViewRepresentable.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 20/08/1447 AH.
//
import SwiftUI
import MapKit
import CoreLocation

struct MapViewRepresentable: UIViewRepresentable {
    var places: [Place]
    @Binding var region: MKCoordinateRegion
    @Binding var followUser: Bool
    var onRequestSearchHere: (() -> Void)?

    // ✅ جديد: يرجّع المكان اللي انضغط
    var onSelectPlace: ((Place) -> Void)?

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.delegate = context.coordinator
        map.showsUserLocation = true
        map.userTrackingMode = .none
        map.setRegion(region, animated: false)
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        if followUser {
            map.setUserTrackingMode(.follow, animated: true)
        } else {
            map.setRegion(region, animated: true)
        }

        let existing = map.annotations.filter { !($0 is MKUserLocation) }
        map.removeAnnotations(existing)

        // ✅ Annotation مخصص يحمل Place
        let annotations = places.map { place -> PlaceAnnotation in
            let a = PlaceAnnotation(place: place)
            a.title = place.name
            a.coordinate = place.coordinate
            return a
        }
        map.addAnnotations(annotations)
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        init(_ parent: MapViewRepresentable) { self.parent = parent }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }

            let id = "pin"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView
            ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)

            view.annotation = annotation
            view.canShowCallout = false
            view.markerTintColor = UIColor(Color(hex: "#6A6DFF"))
            view.glyphTintColor = .white
            view.glyphImage = UIImage(systemName: "sparkles")
            return view
        }

        // ✅ التقاط الضغط على البن
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let ann = view.annotation as? PlaceAnnotation else { return }
            parent.onSelectPlace?(ann.place)
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.region = mapView.region
        }
    }
}

// ✅ Annotation يحمل Place
final class PlaceAnnotation: MKPointAnnotation {
    let place: Place
    init(place: Place) {
        self.place = place
        super.init()
    }
}
