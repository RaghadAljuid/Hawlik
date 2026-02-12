//
//  CategoryRow.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 20/08/1447 AH.
//

import SwiftUI

struct CategoryRow: View {
    let selectedInterests: [Interest]
    @Binding var active: Interest?
    var onSelect: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(selectedInterests, id: \.id) { item in
                    Button {
                        active = item
                        onSelect()
                    } label: {
                        Text(item.title)
                            .font(.subheadline)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                active == item
                                ? Color(hex: "#6A6DFF").opacity(0.30)
                                : Color.clear
                            )
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
