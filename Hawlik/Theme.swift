//
//  Theme.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 20/08/1447 AH.
//

import SwiftUI

extension Color {
    static let popupBackground = Color(hex: "#CCADD9").opacity(0.6)
    static let popupBorder = Color(hex: "#6A6DFF")
    static let continueButton = Color(hex: "#6A6DFF")
}

// Helper لتحويل HEX إلى Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
