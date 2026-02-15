//
//  GlassFieldStyle.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 27/08/1447 AH.
//
import SwiftUI

struct GlassFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .tint(.white.opacity(0.6))
    }
}
