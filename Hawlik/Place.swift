//
//  Place.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 20/08/1447 AH.
//
import Foundation
import CoreLocation

struct Place: Identifiable {
    let name: String
    let interest: Interest
    let coordinate: CLLocationCoordinate2D

    var id: String {
        "\(name.lowercased())_\(coordinate.latitude)_\(coordinate.longitude)"
    }
}
