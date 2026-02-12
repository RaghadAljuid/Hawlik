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

    @State private var addressText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Handle
            Capsule()
                .fill(Color.black.opacity(0.12))
                .frame(width: 46, height: 5)
                .frame(maxWidth: .infinity)
                .padding(.top, 6)

            HStack(alignment: .top, spacing: 14) {

                // ✅ صورة (تلقائية حسب الاهتمام) + كلكبل
                Button {
                    // لاحقًا: تفتح صفحة صور/تفاصيل أكبر
                    print("Image tapped for \(place.name)")
                } label: {
                    Image(heroImageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 92, height: 92)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 6) {
                    Text(place.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.black.opacity(0.9))
                        .lineLimit(1)

                    Text(place.interest.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.55))

                    if !addressText.isEmpty {
                        Text(addressText)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.black.opacity(0.55))
                            .lineLimit(2)
                    }
                }

                Spacer()

                // ✅ Save icon (كلكبل الآن)
                Button {
                    print("Save tapped for: \(place.name)")
                } label: {
                    Image(systemName: "bookmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.8))
                        .padding(10)
                        .background(Color.white.opacity(0.30))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)

            // ✅ وصف عام تلقائي (بدون تعبئة يدوي)
            Text(autoDescription)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.black.opacity(0.70))
                .padding(.horizontal, 16)
                .padding(.top, 6)

            Spacer(minLength: 0)
        }
        .padding(.bottom, 18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)

                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#CCADD9").opacity(0.20),
                                Color.white.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .ignoresSafeArea()
        )
        .task { await loadAddress() }
    }

    // MARK: - Auto Description
    private var autoDescription: String {
        let category = place.interest.title
        let locationText = addressText.isEmpty ? "your area" : addressText
        return "Discover \(category) places around \(locationText). Tap the bookmark to save this spot and come back anytime."
    }

    // MARK: - Hero Image
    /// ضع صور في Assets بهذه الأسماء.
    /// إذا ما عندك صور الآن: خلّ كل الحالات ترجع "hero_placeholder"
    private var heroImageName: String {
        place.interest.iconName   // بيرجع "activities" / "coffeeShop" / ...
    }

    // MARK: - Reverse Geocode (Address)
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
