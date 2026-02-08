//
//  SwiftUIView.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 20/08/1447 AH.
//
import SwiftUI

struct RootView: View {
    @AppStorage("hasSelectedInterests") private var hasSelectedInterests = false
    @State private var selected: Set<Interest> = []

    var body: some View {
        ZStack {
            MapScreen() // خريطتك الحالية

            if !hasSelectedInterests {
                InterestPopup(selected: $selected) {
                    // حفظ الاختيار
                    saveSelectedInterests(selected)
                    hasSelectedInterests = true
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: hasSelectedInterests)
    }

    private func saveSelectedInterests(_ interests: Set<Interest>) {
        let raw = interests.map { $0.rawValue }
        UserDefaults.standard.set(raw, forKey: "selectedInterests")
    }
}
