//
//  MapHomeView.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 20/08/1447 AH.
//
import SwiftUI
import MapKit
import CoreLocation

struct MapHomeView: View {
    @State private var selectedPlace: Place? = nil

    @State private var selectedBudget: Int? = nil
    @State private var selectedInterests: Set<Interest> = Preferences.loadSelectedInterests()

    @State private var showBudgetPopup = false
    @State private var showInterestPopup = false

    @State private var selectedTab: AppTab = .map

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
        span: MKCoordinateSpan(latitudeDelta: 0.16, longitudeDelta: 0.16)
    )

    @State private var followUser = false
    @State private var places: [Place] = []
    @State private var isExpanded = false

    var body: some View {
        ZStack {
            // ✅ نفس الخريطة لكن أضفنا onSelectPlace
            MapViewRepresentable(
                places: places,
                region: $region,
                followUser: $followUser,
                onRequestSearchHere: {
                    Task { await reloadPlaces() }
                },
                onSelectPlace: { place in
                    selectedPlace = place
                }
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
                    selectedTab: $selectedTab,
                    onSearchHere: { Task { await reloadPlaces() } }
                )
            }
        }
        .onAppear { Task { await reloadPlaces() } }

        // ✅ sheet للتفاصيل
        .sheet(item: $selectedPlace) { place in
            PlaceDetailsSheet(place: place)
                .presentationDetents([.fraction(0.45), .large])
                .presentationDragIndicator(.visible)
        }
    }

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
