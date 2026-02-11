//
//  LocalSearchService.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 20/08/1447 AH.
//
import MapKit

enum LocalSearchService {

    // نحول الاهتمام إلى كلمات بحث (سريعة وفعالة)
    static func query(for interest: Interest) -> String {
        switch interest {
        case .restaurant: return "Restaurant"
        case .coffeeShop: return "Coffee"
        case .shopping: return "Mall"
        case .sports: return "Gym"
        case .activities: return "Entertainment"
        case .historical: return "Museum"
        case .nature: return "Park"
        case .trending: return "Attraction"
        }
    }

    // نحول الميزانية إلى كلمات تساعد البحث (تقريبية)
    static func budgetQuery(for budget: Int?) -> String {
        guard let budget else { return "" }

        switch budget {
        case 1:
            return "cheap budget"
        case 2:
            return "casual"
        case 3:
            return "luxury upscale"
        default:
            return ""
        }
    }

    // ✅ البحث مع Budget parameter
    static func search(
        interest: Interest,
        region: MKCoordinateRegion,
        budget: Int?
    ) async -> [Place] {

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query(for: interest)
        request.region = region

        do {
            let response = try await MKLocalSearch(request: request).start()

            return response.mapItems.compactMap { item in
                guard let name = item.name else { return nil }

                // 🔸 فلترة بسيطة حسب الميزانية (تقريبية)
                if let budget {
                    let _ = item.pointOfInterestCategory
                    // هنا لاحقًا تقدرين تربطينها بتقييم/سعر حقيقي
                    if budget == 1 && name.count > 20 { return nil }
                }

                return Place(
                    name: name,
                    interest: interest,
                    coordinate: item.placemark.coordinate
                )
            }

        } catch {
            return []
        }
    }
}
