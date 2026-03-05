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

                // Top Bar
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
                .padding(.top, 14)

                Spacer(minLength: 30)

                // Glass Card
                VStack(alignment: .leading, spacing: 14) {

                    Text("Select Your Places")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))

                    if viewModel.isLoadingNearby {
                        HStack(spacing: 10) {
                            ProgressView()
                                .tint(.white.opacity(0.8))
                            Text("Loading nearby places...")
                                .foregroundColor(.white.opacity(0.65))
                                .font(.system(size: 16, weight: .medium))
                        }
                        .padding(.top, 4)
                    }

                    if let msg = viewModel.nearbyErrorMessage {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(msg)
                                .foregroundColor(.white.opacity(0.65))
                                .font(.system(size: 16, weight: .medium))

                            Button {
                                viewModel.loadNearbyPlaces()
                            } label: {
                                Text("Try Again")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 10)
                                    .background(Color.white.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                        .padding(.top, 4)
                    }

                    // List
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            ForEach(viewModel.nearbyPlaces) { place in
                                SelectPlaceRow(
                                    title: place.name,
                                    subtitle: place.interest,
                                    isSelected: viewModel.selectedPlaces.contains(place)
                                ) {
                                    viewModel.togglePlace(place)
                                }
                            }
                        }
                        .padding(.top, 6)
                    }
                    .frame(maxHeight: 260)

                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.black.opacity(0.18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 22)

                Spacer()

                // Save Button
                Button {
                    viewModel.saveSelectedPlacesToSaved()
                    dismiss()
                } label: {
                    Text("Save")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .frame(maxWidth: .infinity, minHeight: 54)
                        .background(Color.white.opacity(viewModel.selectedPlaces.isEmpty ? 0.10 : 0.22))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                }
                .disabled(viewModel.selectedPlaces.isEmpty)
                .padding(.horizontal, 22)
                .padding(.bottom, 24)
            }
        }
        .onAppear { viewModel.startNearby() }

        // يمنع تكرار الـ Back
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct SelectPlaceRow: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.92))
                    .lineLimit(1)

                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.55))
            }

            Spacer()

            Button(action: onTap) {
                Image(systemName: isSelected ? "checkmark" : "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 54, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.12))
                    )
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.black.opacity(0.18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(isSelected ? Color.green.opacity(0.45) : Color.white.opacity(0.10), lineWidth: 1)
                )
        )
    }
}
