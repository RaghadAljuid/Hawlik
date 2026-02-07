//
//  ContentView.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 16/08/1447 AH.
//
import SwiftUI
import MapKit

struct ContentView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
        span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
    )

    var body: some View {
        Map(coordinateRegion: $region)
            .mapStyle(.standard)   // مهم
            .ignoresSafeArea()
    }
}
