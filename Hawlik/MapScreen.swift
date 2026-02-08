//
//  ContentView.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 16/08/1447 AH.
//
import SwiftUI
import MapKit

struct MapScreen: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
        span: MKCoordinateSpan(latitudeDelta: 0.18, longitudeDelta: 0.18)
    )

    @State private var selectedInterests: Set<Interest> = []
    @State private var visiblePlaces: [Place] = []

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: visiblePlaces) { place in
            MapAnnotation(coordinate: place.coordinate) {
                VStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title2)

                    Text(place.name)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
            }
        }
        .mapStyle(.standard)
        .ignoresSafeArea()
        .onAppear {
            refreshPlaces()
        }
    }

    private func refreshPlaces() {
        selectedInterests = Preferences.loadSelectedInterests()
        visiblePlaces = MockPlaces.all.filter { selectedInterests.contains($0.interest) }
    }
}


#Preview {
    ContentView()
}
