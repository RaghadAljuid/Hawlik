//
//  Place.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 20/08/1447 AH.
//
import Foundation
import CoreLocation

struct Place: Identifiable {
    let id = UUID()
    let name: String
    let interest: Interest
    let coordinate: CLLocationCoordinate2D
}
