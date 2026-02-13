//
//  MainView.swift
//  Hawlik
//
//  Created by saba alrasheed on 24/08/1447 AH.
//
import SwiftUI

struct MainView: View {
    
    @StateObject var vm = PlacesViewModel()
    @State private var selectedTab: AppTab = .map
    
    var body: some View {
        
        VStack {
            
            // الصفحات حسب التاب
            switch selectedTab {
            case .map:
                Text("Map View")
                
            case .document:
                Text("Document View")
                
            case .bookmark:
                Saved(vm: vm)
            }
            
            Spacer()
            
            AppTabBar(selectedTab: $selectedTab)
        }
    }
}
