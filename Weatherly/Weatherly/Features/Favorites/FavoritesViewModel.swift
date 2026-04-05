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

    func loadFavorites() {
        state = .loading

        let favorites = favoritesRepository.fetchFavoriteLocations()
        state = favorites.isEmpty ? .empty : .loaded(favorites)
    }
}
