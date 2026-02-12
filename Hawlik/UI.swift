import SwiftUI

enum AppUI {

    // Layout
    static let sidePadding: CGFloat = 22
    static let gridSpacing: CGFloat = 16
    static let gridColumnsSpacing: CGFloat = 14

    // Thumbnail
    static let thumbW: CGFloat = 160
    static let thumbH: CGFloat = 90
    static let thumbCorner: CGFloat = 20

    // Colors
    static let cardBG = Color(hex: "1E1E2A")
    static let menuItemColor = Color(hex: "2D2D3C")
    static let continueColor = Color(hex: "6A6DFF")
    static let plusPurple = Color(hex: "6B6DF6")

    // Action Menu (small)
    // Action Menu (smaller)
    static let menuW: CGFloat = 210
    static let menuH: CGFloat = 96
    static let menuRowH: CGFloat = 48
    static let menuCorner: CGFloat = 16
    static let menuDividerOpacity: Double = 0.18
    // Position
    static let menuGapBelowCard: CGFloat = 14
    static let clampPadding: CGFloat = 14
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 255, (int >> 8) & 255, int & 255)
        case 8:
            (a, r, g, b) = ((int >> 24) & 255, (int >> 16) & 255, (int >> 8) & 255, int & 255)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
