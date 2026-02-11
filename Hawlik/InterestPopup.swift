//
//  InterestPopup.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 20/08/1447 AH.
//
import SwiftUI

struct InterestPopup: View {
    @Binding var selectedInterests: Set<Interest>
    var onContinue: () -> Void

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 14) {
            Text("SELECT YOUR INTEREST")
                .font(.headline)
                .foregroundStyle(.black.opacity(0.85))

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(Interest.allCases) { item in
                    InterestCard(
                        title: item.title,
                        iconName: item.iconName,
                        isSelected: selectedInterests.contains(item)
                    )
                    .onTapGesture {
                        if selectedInterests.contains(item) { selectedInterests.remove(item) }
                        else { selectedInterests.insert(item) }
                    }
                }
            }

            Button {
                onContinue()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "#6A6DFF").opacity(0.6))
                    )
                    .foregroundColor(.white)
            }
            .disabled(selectedInterests.isEmpty)
            .opacity(selectedInterests.isEmpty ? 0.4 : 1)
        }
        .padding(18)
        .frame(width: 300)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)

                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#CCADD9").opacity(0.45),
                                Color.white.opacity(0.18)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .compositingGroup()
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
    }
}

struct InterestCard: View {
    let title: String
    let iconName: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.white.opacity(0.55))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(isSelected ? Color(hex: "#6A6DFF") : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)

                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 79, height: 64)
            }
            .frame(width: 99, height: 89)

            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.black.opacity(0.85))
        }
        .scaleEffect(isSelected ? 0.97 : 1)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
