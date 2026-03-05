import SwiftUI

struct TripPlacesView: View {

    @ObservedObject var viewModel: TripViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 0) {

                HStack {
                    Button { dismiss() } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.white.opacity(0.95))
                    }

                    Spacer()

                    Button {
                        withAnimation(.easeInOut) {
                            viewModel.isEditing.toggle()
                        }
                    } label: {
                        Image(systemName: viewModel.isEditing ? "checkmark" : "square.and.pencil")
                            .foregroundColor(.white.opacity(0.95))
                            .font(.system(size: 18, weight: .semibold))
                            .padding(12)
                            .background(Circle().fill(Color.white.opacity(0.10)))
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)

                Spacer().frame(height: 18)

                VStack(spacing: 8) {
                    Text("Your Trip Places")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))

                    Text("These are the places you've selected for your trip")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.55))
                }
                .padding(.top, 6)

                Spacer().frame(height: 18)

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 18) {
                        ForEach(viewModel.savedPlaces, id: \.self) { place in
                            savedCard(place)
                        }

                        if viewModel.savedPlaces.isEmpty {
                            Text("No saved places yet.")
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.top, 40)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }

                Spacer(minLength: 0)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func savedCard(_ place: TripPlace) -> some View {
        HStack(spacing: 16) {
            Text(place.name)
                .font(.system(size: 26, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.92))
                .lineLimit(1)

            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.10))

                // يمين: صورة حسب التصنيف
                if let asset = categoryAssetName(for: place.interest) {
                    Image(asset)
                        .resizable()
                        .scaledToFit()
                        .padding(16)
                        .opacity(0.95)
                }
            }
            .frame(width: 110, height: 72)

            if viewModel.isEditing {
                Button {
                    viewModel.removeSavedPlace(place)
                } label: {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.white.opacity(0.9))
                        .padding(12)
                        .background(Circle().fill(Color.red.opacity(0.85)))
                }
                .padding(.leading, 6)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
        )
    }

    private func categoryAssetName(for interest: String) -> String? {
        let key = interest.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        switch key {
        case "coffee": return "coffeeShop"
        case "history", "historic": return "historical"
        case "nature": return "nature"
        case "food", "restaurant": return "restaurant"
        case "shopping", "mall": return "shopping"
        case "sports", "gym": return "sports"
        case "entertainment": return "trending"
        case "trend", "trending": return "trending"
        default: return nil
        }
    }
}
