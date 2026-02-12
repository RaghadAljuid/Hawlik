//
//  MockPlaces.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 20/08/1447 AH.
//
import Foundation
import CoreLocation

enum MockPlaces {
    static let all: [Place] = [
        // Coffee Shop
        Place(name: "Cafe Bateel (Riyadh)", interest: .coffeeShop,
              coordinate: .init(latitude: 24.7118, longitude: 46.6740)),

        // Restaurant
        Place(name: "Najd Village", interest: .restaurant,
              coordinate: .init(latitude: 24.6895, longitude: 46.6846)),

        // Shopping
        Place(name: "Riyadh Park Mall", interest: .shopping,
              coordinate: .init(latitude: 24.7690, longitude: 46.6343)),

        // Nature
        Place(name: "Wadi Hanifa", interest: .nature,
              coordinate: .init(latitude: 24.6513, longitude: 46.5778)),

        // Sports
        Place(name: "King Fahd Stadium", interest: .sports,
              coordinate: .init(latitude: 24.7539, longitude: 46.8382)),

        // Activities
        Place(name: "Boulevard Riyadh City", interest: .activities,
              coordinate: .init(latitude: 24.7647, longitude: 46.6035)),

        // Historical
        Place(name: "Masmak Fortress", interest: .historical,
              coordinate: .init(latitude: 24.6319, longitude: 46.7132)),

        // Trending
        Place(name: "The Zone", interest: .trending,
              coordinate: .init(latitude: 24.7482, longitude: 46.6586)),
    ]
}
