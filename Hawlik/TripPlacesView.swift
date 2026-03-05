import SwiftUI

struct TripPlacesView: View {

    @ObservedObject var viewModel: TripViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // Top Bar
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
                        withAnimation(.easeInOut) { isEditing.toggle() }
                    } label: {
                        Image(systemName: isEditing ? "checkmark" : "square.and.pencil")
                            .foregroundColor(.white.opacity(0.95))
                            .font(.system(size: 20, weight: .semibold))
                            .padding(10)
                            .background(Circle().fill(Color.white.opacity(0.12)))
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)

                VStack(spacing: 6) {
                    Text("Your Trip Places")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))

                    Text("These are the places you’ve selected for your trip")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.55))
                }
                .padding(.top, 14)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        if viewModel.savedPlaces.isEmpty {
                            Text("No saved places yet.")
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.top, 30)
                        } else {
                            ForEach(viewModel.savedPlaces) { place in
                                TripSavedPlaceCard(
                                    placeName: place.name,
                                    imageName: imageName(for: place.name),
                                    showDelete: isEditing
                                ) {
                                    viewModel.removeSavedPlace(place)
                                }
                            }
                        }
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 40)
                }

                Spacer(minLength: 10)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    // اربطي اسم المكان بالصورة (عدلي الأسماء حسب Assets عندك)
    private func imageName(for placeName: String) -> String? {
        let map: [String: String] = [
            "Diriyah": "diriyahPhoto",
            "six flags": "sixflagsPhoto",
            "Six Flags": "sixflagsPhoto"
        ]
        return map[placeName]
    }
}

private struct TripSavedPlaceCard: View {

    let placeName: String
    let imageName: String?
    let showDelete: Bool
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 16) {

            Text(placeName)
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.92))
                .lineLimit(1)

            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.10))
                    .frame(width: 92, height: 56)

                if let imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 92, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }

            if showDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.red.opacity(0.75)))
                }
                .transition(.scale)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.black.opacity(0.20))
        )
    }
}
