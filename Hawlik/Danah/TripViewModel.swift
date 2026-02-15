//
//  TripViewModel.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 27/08/1447 AH.
//
import SwiftUI
import Combine

class TripViewModel: ObservableObject {

    @Published var preference = TripPreference()
    @Published var filteredPlaces: [TripPlace] = []
    @Published var selectedPlaces: [TripPlace] = []
    @Published var isEditing: Bool = false

    let budgetImages = ["budget1", "budget2", "budget3","budget4"]
    let interestOptions = ["Trend", "Sports", "Shopping", "History", "Coffee", "Entertainment", "Nature", "Food"]

    private let allPlaces: [TripPlace] = [
        TripPlace(name: "Diriyah", budget: "budget3", interest: "History"),
        TripPlace(name: "Blvd World", budget: "budget2", interest: "Entertainment"),
        TripPlace(name: "Six Flags", budget: "budget4", interest: "Sports"),
        TripPlace(name: "Jadeel Coffee", budget: "budget1", interest: "Coffee"),
        TripPlace(name: "Boulevard", budget: "budget2", interest: "Entertainment")
    ]

    func continuePlanning() {
        filteredPlaces = allPlaces.filter {
            $0.budget == preference.budget &&
            $0.interest == preference.interest
        }
    }

    func togglePlace(_ place: TripPlace) {
        if let index = selectedPlaces.firstIndex(of: place) {
            selectedPlaces.remove(at: index)
        } else {
            selectedPlaces.append(place)
        }
    }
}
