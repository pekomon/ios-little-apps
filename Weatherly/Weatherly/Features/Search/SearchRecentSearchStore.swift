//
//  SearchRecentSearchStore.swift
//  Weatherly
//
//  Created by Pekomon on 3.4.2026.
//

import Foundation

protocol SearchRecentSearchStore {
    func loadRecentSearches() -> [Location]
    func saveRecentSearch(_ location: Location)
    func clearRecentSearches()
}

final class UserDefaultsSearchRecentSearchStore: SearchRecentSearchStore {
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let storageKey = "search.recentLocations"
    private let maxRecentSearches = 5

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadRecentSearches() -> [Location] {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return []
        }

        do {
            let storedLocations = try decoder.decode([StoredRecentSearch].self, from: data)
            return storedLocations.map(\.location)
        } catch {
            userDefaults.removeObject(forKey: storageKey)
            return []
        }
    }

    func saveRecentSearch(_ location: Location) {
        var locations = loadRecentSearches()
        locations.removeAll { $0.id == location.id }
        locations.insert(location, at: 0)
        persist(Array(locations.prefix(maxRecentSearches)))
    }

    func clearRecentSearches() {
        userDefaults.removeObject(forKey: storageKey)
    }

    private func persist(_ locations: [Location]) {
        let storedLocations = locations.map(StoredRecentSearch.init(location:))

        do {
            let data = try encoder.encode(storedLocations)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            return
        }
    }
}

private struct StoredRecentSearch: Codable {
    let id: String
    let name: String
    let country: String?
    let latitude: Double
    let longitude: Double

    init(location: Location) {
        id = location.id
        name = location.name
        country = location.country
        latitude = location.latitude
        longitude = location.longitude
    }

    var location: Location {
        Location(
            id: id,
            name: name,
            country: country,
            latitude: latitude,
            longitude: longitude
        )
    }
}
