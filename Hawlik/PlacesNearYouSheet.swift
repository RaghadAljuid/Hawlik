//
//  PlacesNearYouSheet.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 20/08/1447 AH.
//
import SwiftUI

struct PlacesNearYouSheet: View {
    let title: String
    @Binding var isExpanded: Bool
    let places: [Place]
    @Binding var selectedTab: AppTab          // ✅ جديد
    var onSearchHere: () -> Void              // (موجود عندك)

    var body: some View {
        VStack(spacing: 12) {

            // handle
            Capsule()
                .fill(Color.black.opacity(0.12))     // ✅ أخف
                .frame(width: 52, height: 5)
                .padding(.top, 10)

            // title
            HStack {
                Text(title)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.black.opacity(0.9))
                Spacer()
            }
            .padding(.horizontal, 18)

            // list
            if isExpanded {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(places.prefix(8)) { p in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(p.name)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.black.opacity(0.85))

                                    Text(p.interest.title)
                                        .font(.system(size: 12))
                                        .foregroundColor(.black.opacity(0.45))
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.18)) // ✅ أخف عشان الغلاس يبان
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(.horizontal, 18)
                }
                .frame(height: 140)
            }

            // ✅ AppTabBar داخل نفس الشيت (مو منفصل)
            AppTabBar(selectedTab: $selectedTab)
                .background(Color.clear)             // ✅ مهم عشان ما يصير له بوكس لحاله
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)

                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(hex: "#DDCDE3").opacity(0.08)) // ✨ خفيف جدًا
            }
        )

        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
        .onTapGesture {
            withAnimation(.easeInOut) { isExpanded.toggle() }
        }
    }
}
