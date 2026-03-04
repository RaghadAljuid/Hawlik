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
extension Interest {
    var assetName: String {
        switch self {
        case .restaurant: return "restaurant"
        case .shopping: return "shopping"
        case .sports: return "sports"
        case .trending: return "trending"
        case .nature: return "nature"
        case .historical: return "historical"
        case .coffeeShop: return "coffeeShop"
        case .activities: return "activities"
        }
    }

    var fallbackSF: String {
        switch self {
        case .restaurant: return "fork.knife"
        case .shopping: return "bag"
        case .sports: return "sportscourt"
        case .trending: return "sparkles"
        case .nature: return "leaf"
        case .historical: return "building.columns"
        case .coffeeShop: return "cup.and.saucer"
        case .activities: return "figure.walk"
        }
    }
}
