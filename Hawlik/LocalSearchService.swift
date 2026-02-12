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

    // كلمات قوية خاصة بـ Fine Dining
    private static let fineDiningStrong: [String] = [
        // English
        "fine dining", "michelin", "tasting menu", "gourmet", "chef table",
        "omakase", "caviar", "wagyu", "truffle", "sushi bar", "chophouse",
        "prime steak", "prime cut", "degustation",
        // Arabic / transliterations
        "فاين دايننق", "فاين داينينغ", "دايننق", "داينينغ",
        "راقي", "راقية", "فخم", "فخمة", "فاخرة", "قورميه", "تذوق"
    ]

    // كلمات أوسع ذات طابع فاخر/راقٍ
    private static let fineDiningBroad: [String] = [
        // English
        "lounge", "brasserie", "grill", "bistro", "prime", "signature",
        "house", "club", "rooftop", "steak", "seafood", "oyster",
        "ristorante", "trattoria", "chic", "boutique", "exclusive",
        "luxury", "upscale", "premium",
        // Arabic
        "لاونج", "ستيك", "سوشي", "سي فود", "مأكولات بحرية", "روف توب", "تراس", "ذا", "فاخر", "فخامة"
    ]

    // كلمات اقتصادية (اختياري)
    private static let lowPriceKeywords: [String] = [
        "cheap", "budget", "street", "fast food", "casual",
        "اقتصادي", "رخيص", "رخيصة", "شعبي", "سريع"
    ]

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
            let items = response.mapItems

            let results: [MKMapItem]

            if let budget, budget == 4, interest == .restaurant {
                // منطق خاص بالمطاعم: Fine Dining
                results = filterFineDining(items)
            } else if let budget, budget == 1 {
                // اقتصادي (تقريبي)
                results = items.filter { item in
                    let haystack = searchableText(for: item)
                    return lowPriceKeywords.contains(where: { haystack.contains($0) })
                }
            } else {
                // فئات وسطية أو بدون ميزانية: بدون فلترة إضافية
                results = items
            }

            return results.compactMap { item in
                guard let name = item.name else { return nil }
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

    // MARK: - Fine Dining Filtering with Fallback
    private static func filterFineDining(_ items: [MKMapItem]) -> [MKMapItem] {
        // 1) فلترة بكلمات قوية
        let strongMatches = items.filter { item in
            let haystack = searchableText(for: item)
            return fineDiningStrong.contains(where: { haystack.contains($0) })
        }
        if strongMatches.count >= 5 {
            return prioritize(strong: strongMatches, broad: [], all: items)
        }

        // 2) إن كانت قليلة، نضيف كلمات أوسع
        let broadMatches = items.filter { item in
            let haystack = searchableText(for: item)
            return fineDiningBroad.contains(where: { haystack.contains($0) })
        }

        let combined = Array(Set(strongMatches + broadMatches))
        if combined.count >= 5 {
            return prioritize(strong: strongMatches, broad: broadMatches, all: items)
        }

        // 3) fallback: رجّع الكل لكن قدّم المطابق أولاً
        return prioritize(strong: strongMatches, broad: broadMatches, all: items)
    }

    // ترتيب: القوي أولاً، ثم الأوسع، ثم الباقي
    private static func prioritize(strong: [MKMapItem], broad: [MKMapItem], all: [MKMapItem]) -> [MKMapItem] {
        let strongSet = Set(strong.map { $0 })
        let broadSet = Set(broad.map { $0 })
        let rest = all.filter { !strongSet.contains($0) && !broadSet.contains($0) }
        return strong + broad.filter { !strongSet.contains($0) } + rest
    }

    // يبني نص قابل للبحث من اسم المكان + الفئة + رابط (إن وجدت)
    private static func searchableText(for item: MKMapItem) -> String {
        let name = item.name?.lowercased() ?? ""
        let category = item.pointOfInterestCategory?.rawValue.lowercased() ?? ""
        let url = item.url?.absoluteString.lowercased() ?? ""
        return [name, category, url].joined(separator: " ")
    }
}
