//
//  SwiftUIView.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 20/08/1447 AH.
//
import SwiftUI

struct RootView: View {
    @State private var refreshID = UUID()
    @AppStorage("hasSelectedInterests") private var hasSelectedInterests = false
    @State private var selected: Set<Interest> = []
    @State private var selectedTab: AppTab = .map

    var body: some View {
        ZStack {
            MapHomeView(selectedTab: $selectedTab)
                .id(refreshID)

            if !hasSelectedInterests {
                InterestPopup(selectedInterests: $selected) {
                    // حفظ الاختيار
                    saveSelectedInterests(selected)
                    hasSelectedInterests = true
                    // Trigger MapScreen to re-appear and reload preferences
                    refreshID = UUID()
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            // Optionally prefill current selection if already chosen before
            if hasSelectedInterests {
                selected = Preferences.loadSelectedInterests()
            }
        }
        .animation(.easeInOut, value: hasSelectedInterests)
    }

    private func saveSelectedInterests(_ interests: Set<Interest>) {
        let raw = interests.map { $0.rawValue }
        UserDefaults.standard.set(raw, forKey: Preferences.selectedInterestsKey)
    }
}

