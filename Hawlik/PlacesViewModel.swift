//
//  PlacesViewModel.swift
//  Hawlik
//
//  Created by saba alrasheed on 24/08/1447 AH.
//
import SwiftUI
import Combine
class PlacesViewModel: ObservableObject {
    @Published var savedPlaces: [Place] = []

    func toggleSave(place: Place) {
        if let index = savedPlaces.firstIndex(where: { $0.id == place.id }) {
            savedPlaces.remove(at: index)
        } else {
            savedPlaces.append(place)
        }
    }
}

