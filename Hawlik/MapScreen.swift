//
//  ContentView.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 16/08/1447 AH.
//
import SwiftUI
import MapKit
import CoreLocation

struct MapScreen: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
        span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    )

    @State private var followUser = false
    @State private var selectedInterests: [Interest] = []
    @State private var activeCategory: Interest? = nil
    @State private var places: [Place] = []

    var body: some View {
        ZStack {
            MapViewRepresentable(
                places: places,
                region: $region,
                followUser: $followUser
            )

            VStack(spacing: 10) {
                // 🔹 شريط الكاتقوري المختارة (زي Shopping / Restaurants)
                if let cat = activeCategory {
                    HStack {
                        Text(cat.title)
                            .font(.headline)
                        Spacer()
                        Button {
                            activeCategory = nil
                            places = []
                        } label: {
                            Image(systemName: "xmark")
                                .padding(10)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }

                // 🔹 زر Search this area
                Button {
                    Task { await searchCurrentCategory() }
                } label: {
                    Text("Search this area")
                        .font(.subheadline)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
                .opacity(activeCategory == nil ? 0 : 1)
                .animation(.easeInOut, value: activeCategory)

                Spacer()

                // 🔹 Chips للكاتقوري حسب اهتمامات المستخدم
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(selectedInterests, id: \.id) { item in
                            Button {
                                activeCategory = item
                                Task { await searchCurrentCategory() }
                            } label: {
                                Text(item.title)
                                    .font(.subheadline)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(Color(hex: "#6A6DFF").opacity(0.18))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }

                // 🔹 أزرار التحكم (موقعي + زوم)
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Button {
                            followUser = true
                        } label: {
                            Image(systemName: "location.fill")
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }

                        Button {
                            zoomIn()
                        } label: {
                            Image(systemName: "plus")
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }

                        Button {
                            zoomOut()
                        } label: {
                            Image(systemName: "minus")
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.trailing, 14)
                    .padding(.bottom, 90)
                }
            }
            .padding(.top, 10)
        }
        .onAppear {
            loadInterests()
        }
    }

    private func loadInterests() {
        let set = Preferences.loadSelectedInterests()
        selectedInterests = Array(set)
        activeCategory = selectedInterests.first
        Task { await searchCurrentCategory() }
    }

    private func searchCurrentCategory() async {
        guard let cat = activeCategory else { return }
        followUser = false
        let results = await LocalSearchService.search(interest: cat, region: region, budget: nil)
        places = results
    }

    private func zoomIn() {
        followUser = false
        region.span.latitudeDelta *= 0.7
        region.span.longitudeDelta *= 0.7
    }

    private func zoomOut() {
        followUser = false
        region.span.latitudeDelta /= 0.7
        region.span.longitudeDelta /= 0.7
    }
}


#Preview {
    MapScreen()
}
