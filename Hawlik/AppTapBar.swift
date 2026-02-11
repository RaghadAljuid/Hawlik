//
//  AppTapBar.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 21/08/1447 AH.
//

import SwiftUI

enum AppTab: String {
    case map
    case document
    case bookmark
}

struct AppTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack {
            tabButton(tab: .map, systemName: "map")
            Spacer()
            tabButton(tab: .document, systemName: "doc")
            Spacer()
            tabButton(tab: .bookmark, systemName: "bookmark")
        }
        .padding(.horizontal, 36)
        .padding(.vertical, 18)
        .background(Color(hex: "#EDE4F0").opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 26))
    }

    @ViewBuilder
    private func tabButton(tab: AppTab, systemName: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 24, weight: .regular))
                .foregroundColor(selectedTab == tab
                                 ? Color(hex: "#2A1B3D")   // ✅ أغمق (active)
                                 : Color.black.opacity(0.25)) // ✅ فاتح (inactive)
        }
        .buttonStyle(.plain)
    }
}
