//
//  PlaceDetailsSheet.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 23/08/1447 AH.
//
import SwiftUI
import CoreLocation

struct PlaceDetailsSheet: View {
    let place: Place
    @ObservedObject var vm: PlacesViewModel   // ✅ أضفناها

    @State private var addressText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            Capsule()
                .fill(Color.black.opacity(0.12))
                .frame(width: 46, height: 5)
                .frame(maxWidth: .infinity)
                .padding(.top, 6)

            HStack(alignment: .top, spacing: 14) {

                Button {
                    
                    print("Image tapped for \(place.name)")
                } label: {
                    Image(heroImageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 92, height: 92)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 6) {
                    Text(place.name)
                        .font(.system(size: 28, weight: .bold))

                    Text(place.interest.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.55))

                    if !addressText.isEmpty {
                        Text(addressText)
                            .font(.system(size: 13))
                            .foregroundStyle(.black.opacity(0.55))
                            .lineLimit(2)
                    }
                }

                Spacer()

                // ✅ زر الحفظ الحقيقي
                Button {
                    withAnimation {
                        vm.toggleSave(place: place)
                    }
                } label: {
                    Image(systemName:
                            vm.savedPlaces.contains(where: { $0.id == place.id })
                            ? "bookmark.fill"
                            : "bookmark"
                    )
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.8))
                    .padding(10)
                    .background(Color.white.opacity(0.30))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)

            Text(autoDescription)
                .font(.system(size: 14))
                .foregroundStyle(.black.opacity(0.70))
                .padding(.horizontal, 16)
                .padding(.top, 6)

            Spacer(minLength: 0)
        }
        .padding(.bottom, 18)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        )
        .task { await loadAddress() }
    }

    private var autoDescription: String {
        let category = place.interest.title
        let locationText = addressText.isEmpty ? "your area" : addressText
        return "Discover \(category) places around \(locationText). Tap the bookmark to save this spot and come back anytime."
    }

    private var heroImageName: String {
        place.interest.iconName
    }

    private func loadAddress() async {
        let geocoder = CLGeocoder()
        let location = CLLocation(
            latitude: place.coordinate.latitude,
            longitude: place.coordinate.longitude
        )

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let p = placemarks.first {
                let parts = [p.name, p.locality, p.administrativeArea].compactMap { $0 }
                addressText = parts.joined(separator: " • ")
            }
        } catch {
            addressText = ""
        }
    }
}
