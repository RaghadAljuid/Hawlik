//
//  SelectPlacesView.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 27/08/1447 AH.
//
import SwiftUI

struct SelectPlacesView: View {

    @ObservedObject var viewModel: TripViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {

        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {

                // 🔹 Top Bar
                HStack {
                    Button { dismiss() } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.title3)
                        .foregroundColor(.white)
                    }

                    Spacer()

                    if !viewModel.selectedPlaces.isEmpty {
                        NavigationLink {
                            TripPlacesView(viewModel: viewModel)
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Spacer(minLength: 18)

                Text("Select Your Places")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Spacer(minLength: 18)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 18) {
                        ForEach(viewModel.filteredPlaces) { place in
                            TripPlaceCard(
                                place: place,
                                isSelected: viewModel.selectedPlaces.contains(place),
                                iconName: iconName(for: place.interest)
                            )
                            .onTapGesture {
                                viewModel.togglePlace(place)
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 6)
                    .padding(.bottom, 24)
                }

                Spacer(minLength: 0)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    // ✅ اربطي interest (String) باسم صورة من الـ Assets
    private func iconName(for interest: String) -> String {
        let map: [String: String] = [
            "History": "historical",
            "Coffee": "coffeeShop",
            "Entertainment": "activities",
            "Food": "restaurant",
            "Sports": "sports",
            "Trend": "trending",
            "Shopping": "shopping",
            "Nature": "nature"
        ]
        return map[interest] ?? "activities"  // default
    }
}

struct TripPlaceCard: View {
    let place: TripPlace
    let isSelected: Bool
    let iconName: String

    var body: some View {
        HStack(spacing: 16) {

            VStack(alignment: .leading, spacing: 6) {
                Text(place.name)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                Text(place.interest)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.55))
            }

            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.10))

                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
            }
            .frame(width: 92, height: 56)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.black.opacity(0.45))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(isSelected ? Color.green.opacity(0.6) : Color.clear, lineWidth: 2)
        )
    }
}
