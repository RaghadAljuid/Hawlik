//
//  LocalSearchService.swift
//  Hawlik
//
//  Created by Raghad Aljuid on 20/08/1447 AH.
//

import MapKit

enum LocalSearchService {

    // MARK: - Interest Queries (Fallbacks)
    static func queries(for interest: Interest) -> [String] {
        switch interest {
        case .restaurant: return ["Restaurant", "Restaurants", "Food", "Diner"]
        case .coffeeShop: return ["Coffee Shop", "Cafe", "Coffee", "Café"]
        case .shopping: return ["Mall", "Shopping Center", "Store", "Market"]
        case .sports: return ["Gym", "Fitness", "Sports Center"]
        case .activities: return ["Entertainment", "Activities", "Fun", "Arcade"]
        case .historical: return ["Museum", "Historical Site", "Heritage", "Gallery"]
        case .nature: return ["Park", "Garden", "Nature", "Trail"]
        case .trending: return ["Attraction", "Things to do", "Popular place", "Landmark"]
        }
    }

    // MARK: - Keywords
    private static let fineDiningStrong: [String] = [
        "fine dining", "michelin", "tasting menu", "gourmet", "chef table",
        "omakase", "caviar", "wagyu", "truffle", "sushi bar", "chophouse",
        "prime steak", "prime cut", "degustation",
        "فاين دايننق", "فاين داينينغ", "دايننق", "داينينغ",
        "راقي", "راقية", "فخم", "فخمة", "فاخرة", "قورميه", "تذوق"
    ].map { $0.lowercased() }

    private static let fineDiningBroad: [String] = [
        "lounge", "brasserie", "grill", "bistro", "prime", "signature",
        "house", "club", "rooftop", "steak", "seafood", "oyster",
        "ristorante", "trattoria", "chic", "boutique", "exclusive",
        "luxury", "upscale", "premium",
        "لاونج", "ستيك", "سوشي", "سي فود", "مأكولات بحرية", "روف توب", "تراس", "ذا", "فاخر", "فخامة"
    ].map { $0.lowercased() }

    private static let lowPriceKeywords: [String] = [
        "cheap", "budget", "street", "fast food", "casual",
        "اقتصادي", "رخيص", "رخيصة", "شعبي", "سريع"
    ].map { $0.lowercased() }

    // MARK: - 1) Existing Search: By Interest + Budget
    static func search(
        interest: Interest,
        region: MKCoordinateRegion,
        budget: Int?
    ) async -> [Place] {

        let qs = queries(for: interest)

        // نجرب أكثر من query (fallback) لين نحصل نتائج
        for (idx, q) in qs.enumerated() {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = q
            request.region = region

            do {
                let response = try await MKLocalSearch(request: request).start()
                let items = response.mapItems

                // إذا أول محاولة جابت 0، نكمل للثانية
                if items.isEmpty && idx < qs.count - 1 { continue }

                let results: [MKMapItem]
                if let budget, budget == 4, interest == .restaurant {
                    results = filterFineDining(items)
                } else if let budget, budget == 1 {
                    results = items.filter { item in
                        let haystack = searchableText(for: item)
                        return lowPriceKeywords.contains(where: { haystack.contains($0) })
                    }
                } else {
                    results = items
                }

                let places = results.compactMap { item -> Place? in
                    guard let name = item.name else { return nil }
                    return Place(
                        name: name,
                        interest: interest,
                        coordinate: item.placemark.coordinate
                    )
                }

                // إذا رجع شيء خلاص
                if !places.isEmpty { return places }

                // إذا صفر ونقدر نجرب query ثاني
                if idx < qs.count - 1 { continue }
                return []
            } catch {
                // إذا فشل query، نجرب اللي بعده
                if idx < qs.count - 1 { continue }
                return []
            }
        }

        return []
    }

    // MARK: - 2) NEW: Text Search (for Search Bar)
    /// تبحث بالكلمة اللي يكتبها المستخدم وتطلع أماكن مباشرة.
    /// - Parameters:
    ///   - query: النص من السيرش بار
    ///   - region: منطقة البحث (عادة region حق الماب)
    ///   - fallbackInterest: لو تبين تعطي Interest ثابت للنتائج (اختياري). إذا nil نعطي .trending.
    ///   - budget: نفس فلترة الميزانية اللي عندك
    static func searchText(
        query: String,
        region: MKCoordinateRegion,
        fallbackInterest: Interest? = nil,
        budget: Int? = nil
    ) async -> [Place] {

        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return [] }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = q
        request.region = region

        do {
            let response = try await MKLocalSearch(request: request).start()
            let items = response.mapItems

            let results: [MKMapItem]
            if let budget, budget == 4 {
                results = filterFineDining(items)
            } else if let budget, budget == 1 {
                results = items.filter { item in
                    let haystack = searchableText(for: item)
                    return lowPriceKeywords.contains(where: { haystack.contains($0) })
                }
            } else {
                results = items
            }

            let interest = fallbackInterest ?? .trending

            return results.compactMap { item -> Place? in
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
        let strongMatches = items.filter { item in
            let haystack = searchableText(for: item)
            return fineDiningStrong.contains(where: { haystack.contains($0) })
        }
        if strongMatches.count >= 5 {
            return prioritize(strong: strongMatches, broad: [], all: items)
        }

        let broadMatches = items.filter { item in
            let haystack = searchableText(for: item)
            return fineDiningBroad.contains(where: { haystack.contains($0) })
        }

        let combined = Array(Set(strongMatches + broadMatches))
        if combined.count >= 5 {
            return prioritize(strong: strongMatches, broad: broadMatches, all: items)
        }

        return prioritize(strong: strongMatches, broad: broadMatches, all: items)
    }

    private static func prioritize(strong: [MKMapItem], broad: [MKMapItem], all: [MKMapItem]) -> [MKMapItem] {
        let strongSet = Set(strong)
        let broadSet = Set(broad)
        let rest = all.filter { !strongSet.contains($0) && !broadSet.contains($0) }
        return strong + broad.filter { !strongSet.contains($0) } + rest
    }

    private static func searchableText(for item: MKMapItem) -> String {
        let name = item.name?.lowercased() ?? ""
        let category = item.pointOfInterestCategory?.rawValue.lowercased() ?? ""
        let url = item.url?.absoluteString.lowercased() ?? ""
        return [name, category, url].joined(separator: " ")
    }
}
