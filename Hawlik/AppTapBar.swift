import SwiftUI

enum AppTab: String {
    case map
    case document
    case bookmark
}

struct AppTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {

            tabButton(tab: .map, systemName: "map")
                .frame(maxWidth: .infinity)

            tabButton(tab: .document, systemName: "doc")
                .frame(maxWidth: .infinity)

            tabButton(tab: .bookmark, systemName: "bookmark")
                .frame(maxWidth: .infinity)
        }
        .frame(height: 64)
        .padding(.horizontal, 36)
        .padding(.vertical, 18)
        .background(Color(hex: "#EDE4F0").opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .contentShape(Rectangle())
    }

    private func tabButton(tab: AppTab, systemName: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            ZStack {
                Rectangle().fill(Color.clear) // ✅ يكبر hit area

                Image(systemName: systemName)
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(
                        selectedTab == tab
                        ? Color(hex: "#2A1B3D")
                        : Color.black.opacity(0.25)
                    )
            }
            .frame(height: 64)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
