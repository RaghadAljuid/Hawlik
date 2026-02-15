//
//  TripPlace.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 27/08/1447 AH.
//
import Foundation

struct TripPreference {
    var budget: String = ""
    var interest: String = ""
}

struct TripPlace: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let budget: String
    let interest: String
}
