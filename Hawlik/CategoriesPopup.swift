//
//  CategoriesPopup.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 23/08/1447 AH.
//
import SwiftUI

struct CategoriesPopup: View {
    @Binding var selectedInterests: Set<Interest>
    var onDone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // ✅ List (Scrollable) عشان ما يكبر البوكس
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(Interest.allCases) { item in
                        Button {
                            if selectedInterests.contains(item) {
                                selectedInterests.remove(item)
                            } else {
                                selectedInterests.insert(item)
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Text(item.title)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.black.opacity(0.85))
                                    .lineLimit(1)

                                Spacer(minLength: 8)

                                if selectedInterests.contains(item) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(Color(hex: "#6A6DFF"))
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.25))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 2)
            }
            .frame(maxHeight: 210) // ✅ صغّر القائمة (جرّب 160 / 180 / 210)

            // ✅ Done ثابت تحت
            Button {
                onDone()
            } label: {
                Text("Done")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(hex: "#6A6DFF").opacity(0.60))
                    )
                    .foregroundColor(.white)
            }
            .disabled(selectedInterests.isEmpty)
            .opacity(selectedInterests.isEmpty ? 0.35 : 1)
        }
        .padding(12)
        .frame(width: 190)          // ✅ نفس طلبك
        .frame(maxHeight: 280)      // ✅ يمنع البوكس يكبر فوق حد معين
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#CCADD9").opacity(0.45), // أفتح
                            Color(hex: "#CCADD9").opacity(0.30)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 6)

    }
}
