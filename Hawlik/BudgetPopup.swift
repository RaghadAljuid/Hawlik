//
//  BudgetPopup.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 23/08/1447 AH.
//

import SwiftUI

struct BudgetPopup: View {
    @Binding var selectedBudget: Int?      // 1...4
    var onSelect: () -> Void               // يقفل + يحدث الخريطة

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                ForEach(1...4, id: \.self) { level in
                    Button {
                        selectedBudget = level
                        onSelect()
                    } label: {
                        Image("budget\(level)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 34, height: 34)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.white.opacity(selectedBudget == level ? 0.35 : 0.18))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.black.opacity(selectedBudget == level ? 0.18 : 0.0), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(hex: "#CCADD9").opacity(0.80))   // ✅ 80% مثل كلامك
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.leading, 18) // خليها تطلع تحت زر البجت (عدّليها حسب مكانك)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
