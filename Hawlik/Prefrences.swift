//
//  Prefrences.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 20/08/1447 AH.
//
import Foundation

enum Preferences {
    static let selectedInterestsKey = "selectedInterests"

    static func loadSelectedInterests() -> Set<Interest> {
        let raw = UserDefaults.standard.stringArray(forKey: selectedInterestsKey) ?? []
        return Set(raw.compactMap { Interest(rawValue: $0) })
    }
}
