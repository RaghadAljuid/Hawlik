//
//  AppSehll.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 26/08/1447 AH.
//
import SwiftUI

struct AppShell: View {
    @State private var selectedTab: AppTab = .map
    @StateObject private var tripStore = TripStore()

    var body: some View {
        ZStack {
            Group {
                switch selectedTab {
                case .map:
                    MapHomeView()

                case .document:
                    TripsView()
                        .environmentObject(tripStore)

                case .bookmark:
                    ZStack {
                        AppBackground()
                        Text("Bookmarks")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
            }

            // ✅ Tab bar واحد ثابت لكل الصفحات
            VStack {
                Spacer()
                AppTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}
