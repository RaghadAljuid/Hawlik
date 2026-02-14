//
//  saved.swift
//  Hawlik
//
//  Created by saba alrasheed on 24/08/1447 AH.
//

import SwiftUI

struct Saved: View {
    
    @ObservedObject var vm: PlacesViewModel
    
    var body: some View {
        ZStack {
            
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            if vm.savedPlaces.isEmpty {
                
                Text("No saved places")
                    .foregroundColor(.white.opacity(0.85))
                    .font(.title3)
                
            } else {
                
                List {
                    ForEach(vm.savedPlaces) { place in
                        
                        HStack(spacing: 16) {
                            
                            Text(place.name)
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            Spacer()
                            
                            Image(place.interest.rawValue)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 65)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.vertical, 10)
                        .listRowBackground(Color.black.opacity(0.35))
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                vm.toggleSave(place: place)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
        }
    }
}
