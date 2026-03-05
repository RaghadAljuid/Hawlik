import SwiftUI

struct SelectPlacesView: View {

    @ObservedObject var viewModel: TripViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // Top bar (Back فقط)
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.white.opacity(0.95))
                    }
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)

                Spacer().frame(height: 18)

                // Card container
                VStack(alignment: .leading, spacing: 14) {

                    Text("Select Your Places")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))

                    if viewModel.isLoadingNearby {
                        HStack(spacing: 10) {
                            ProgressView()
                            Text("Loading nearby places...")
                                .foregroundColor(.white.opacity(0.65))
                        }
                        .padding(.top, 4)
                    }

                    if let msg = viewModel.nearbyErrorMessage {
                        Text(msg)
                            .foregroundColor(.white.opacity(0.7))
                            .font(.system(size: 14))
                    }

                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 14) {
                            ForEach(viewModel.nearbyPlaces, id: \.self) { place in
                                placeRow(place)
                            }
                        }
                        .padding(.bottom, 10)
                    }
                    .frame(maxHeight: 320)

                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.white.opacity(0.10), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 18)

                Spacer()

                Button {
                    viewModel.saveSelectedPlacesToSaved()
                } label: {
                    Text("Save")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white.opacity(viewModel.selectedPlaces.isEmpty ? 0.25 : 0.9))
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.white.opacity(viewModel.selectedPlaces.isEmpty ? 0.10 : 0.18))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .padding(.horizontal, 22)
                        .padding(.bottom, 18)
                }
                .disabled(viewModel.selectedPlaces.isEmpty)
            }
        }
        .onAppear {
            viewModel.startNearby()
        }
        // يمنع تكرار Back
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Row UI

    private func placeRow(_ place: TripPlace) -> some View {
        let isSelected = viewModel.selectedPlaces.contains(place)

        return HStack(spacing: 14) {

            // Category icon (Asset)
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.08))
                if let asset = categoryAssetName(for: place.interest) {
                    Image(asset)
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                } else {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 6) {
                Text(place.name)
                    .foregroundColor(.white.opacity(0.92))
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .lineLimit(1)

                Text(place.interest.isEmpty ? " " : place.interest)
                    .foregroundColor(.white.opacity(0.55))
                    .font(.system(size: 16, weight: .medium))
                    .lineLimit(1)
            }

            Spacer()

            Button {
                viewModel.togglePlace(place)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(0.10))
                    Image(systemName: isSelected ? "checkmark" : "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))
                }
                .frame(width: 66, height: 56)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(isSelected ? Color.white.opacity(0.18) : Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    // MARK: - Interest -> Asset mapping (حسب أسماء الـAssets عندك)

    private func categoryAssetName(for interest: String) -> String? {
        let key = interest.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        switch key {
        case "coffee": return "coffeeShop"
        case "history", "historic": return "historical"
        case "nature": return "nature"
        case "food", "restaurant": return "restaurant"
        case "shopping", "mall": return "shopping"
        case "sports", "gym": return "sports"
        case "entertainment": return "trending"   // ما عندك entertainment asset فربطته على trending
        case "trend", "trending": return "trending"
        default: return nil
        }
    }
}
