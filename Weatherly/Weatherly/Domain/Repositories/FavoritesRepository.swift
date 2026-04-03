//
//  FavoritesRepository.swift
//  Weatherly
//
//  Created by Pekomon on 3.4.2026.
//

import Foundation

protocol FavoritesRepository {
    func fetchFavoriteLocations() -> [Location]
    func saveFavorite(_ location: Location)
    func removeFavorite(_ location: Location)
    func isFavorite(_ location: Location) -> Bool
}
