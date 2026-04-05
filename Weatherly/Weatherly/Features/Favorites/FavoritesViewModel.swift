//
//  FavoritesViewModel.swift
//  Weatherly
//
//  Created by Pekomon on 4.4.2026.
//

import Foundation
import Observation

@Observable
final class FavoritesViewModel {
    var state: FavoritesState = .idle

    private let favoritesRepository: FavoritesRepository

    init(favoritesRepository: FavoritesRepository = UserDefaultsFavoritesRepository()) {
        self.favoritesRepository = favoritesRepository
    }

    func loadFavorites(showLoading: Bool = true) {
        if showLoading {
            state = .loading
        }

        applyFavorites(favoritesRepository.fetchFavoriteLocations())
    }

    func removeFavorite(_ location: Location) {
        favoritesRepository.removeFavorite(location)
        applyFavorites(favoritesRepository.fetchFavoriteLocations())
    }

    private func applyFavorites(_ favorites: [Location]) {
        state = favorites.isEmpty ? .empty : .loaded(favorites)
    }
}
