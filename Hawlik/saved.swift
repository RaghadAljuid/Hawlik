//
//  saved.swift
//  Hawlik
//
//  Created by saba alrasheed on 24/08/1447 AH.
//
import SwiftUI

struct Saved: View {
    @ObservedObject var vm: PlacesViewModel

    var body: some View {
        ZStack {
            AppBackground() // ✅ نفس اللي يستخدمه TripDiaryShell (خليه يطلع من assets background)

            VStack(spacing: 18) {

                // ✅ عنوان ثابت بمسافة واضحة (بدون لعب safeAreaInset)
                Text("Saved Places")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.95))
                    .padding(.top, 64)              // ✅ يبعده عن النوتش (مناسب للايفون 17)
                    .padding(.horizontal, 18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(vm.savedPlaces.isEmpty ? 0 : 1)

                if vm.savedPlaces.isEmpty {
                    Spacer()
                    Text("No Saved Places")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white.opacity(0.75))
                    Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 18) {
                            ForEach(vm.savedPlaces) { place in
                                SavedPlaceCard(place: place) {
                                    vm.toggleSave(place: place)
                                }
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 8)
                        .padding(.bottom, 24) // ✅ بسيط فقط، مو tabbar
                    }
                }
            }
        }
    }
}

struct SavedPlaceCard: View {
    let place: Place
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 16) {

            // ✅ أيقونة السيف – بالضغط عليها ينشال الحفظ
            Button {
                onDelete()
            } label: {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.purple.opacity(0.85))
                    .frame(width: 34)
            }
            .buttonStyle(.plain)

            Text(place.name)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))

            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.12))

                Image(place.interest.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
            }
            .frame(width: 92, height: 56)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.black.opacity(0.25))
        )
    }
}
