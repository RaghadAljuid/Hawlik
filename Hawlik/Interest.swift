//
//  Interest.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 20/08/1447 AH.
//
import Foundation

enum Interest: String, CaseIterable, Identifiable {
    case historical, coffeeShop, activities, restaurant, sports, trending, shopping, nature

    var id: String { rawValue }

    var title: String {
        switch self {
        case .historical: return "historical"
        case .coffeeShop: return "coffeeShop"
        case .activities: return "activities"
        case .restaurant: return "restaurant"
        case .sports: return "sports"
        case .trending: return "trending"
        case .shopping: return "shopping"
        case .nature: return "nature"
        }
    }

    /// اسم صورة الأيقونة في Assets (نفس الاسم)
    var iconName: String { rawValue }
}
