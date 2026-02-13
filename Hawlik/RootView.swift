//
//  SwiftUIView.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 20/08/1447 AH.
//
import SwiftUI

struct RootView: View {
    
    @StateObject var vm = PlacesViewModel()
    @State private var refreshID = UUID()
    @AppStorage("hasSelectedInterests") private var hasSelectedInterests = false
    @State private var selected: Set<Interest> = []
    
    @State private var selectedTab: AppTab = .map
    
    var body: some View {
        
        ZStack {
            
            // الصفحات
            if selectedTab == .map {
                MapHomeView(vm: vm, selectedTab: $selectedTab)
                    .id(refreshID)
            } else if selectedTab == .bookmark {
                Saved(vm: vm)
            } else if selectedTab == .document {
                Color.clear
            }
            
            // 👇 التاب بار يكون فوق الكل
            VStack {
                Spacer()
                
                AppTabBar(selectedTab: $selectedTab)
                    .padding(.bottom, 30)
            }
            
            // Popup الاهتمامات
            if !hasSelectedInterests && selectedTab == .map {
                InterestPopup(selectedInterests: $selected) {
                    saveSelectedInterests(selected)
                    hasSelectedInterests = true
                    refreshID = UUID()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: hasSelectedInterests)
    }
    
    private func saveSelectedInterests(_ interests: Set<Interest>) {
        let raw = interests.map { $0.rawValue }
        UserDefaults.standard.set(raw, forKey: Preferences.selectedInterestsKey)
    }
}
