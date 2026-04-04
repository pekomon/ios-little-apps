//
//  UserDefaultsFavoritesRepository.swift
//  Weatherly
//
//  Created by Pekomon on 3.4.2026.
//

import Foundation

final class UserDefaultsFavoritesRepository: FavoritesRepository {
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let storageKey = "favorites.locations"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func fetchFavoriteLocations() -> [Location] {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return []
        }

        do {
            let storedFavorites = try decoder.decode([StoredFavoriteLocation].self, from: data)
            return storedFavorites.map(\.location)
        } catch {
            userDefaults.removeObject(forKey: storageKey)
            return []
        }
    }

    func saveFavorite(_ location: Location) {
        var favorites = fetchFavoriteLocations()

        if let existingIndex = favorites.firstIndex(where: { $0.id == location.id }) {
            favorites[existingIndex] = location
        } else {
            favorites.append(location)
        }

        persist(favorites)
    }

    func removeFavorite(_ location: Location) {
        let favorites = fetchFavoriteLocations().filter { $0.id != location.id }
        persist(favorites)
    }

    func isFavorite(_ location: Location) -> Bool {
        fetchFavoriteLocations().contains { $0.id == location.id }
    }

    private func persist(_ locations: [Location]) {
        let storedFavorites = locations.map { StoredFavoriteLocation(location: $0) }

        do {
            let data = try encoder.encode(storedFavorites)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            return
        }
    }
}

private struct StoredFavoriteLocation: Codable {
    let id: String
    let name: String
    let country: String?
    let latitude: Double
    let longitude: Double

    nonisolated init(location: Location) {
        id = location.id
        name = location.name
        country = location.country
        latitude = location.latitude
        longitude = location.longitude
    }

    nonisolated var location: Location {
        Location(
            id: id,
            name: name,
            country: country,
            latitude: latitude,
            longitude: longitude
        )
    }
}
