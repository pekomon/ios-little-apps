//
//  SearchLocationWeatherViewModel.swift
//  Weatherly
//
//  Created by Pekomon on 3.4.2026.
//

import Foundation
import Observation

@Observable
final class SearchLocationWeatherViewModel {
    let location: Location
    var state: SearchLocationWeatherState = .idle
    var isFavorite = false

    private let weatherRepository: WeatherRepository
    private let favoritesRepository: FavoritesRepository

    init(
        location: Location,
        weatherRepository: WeatherRepository = WeatherKitWeatherRepository(),
        favoritesRepository: FavoritesRepository = UserDefaultsFavoritesRepository()
    ) {
        self.location = location
        self.weatherRepository = weatherRepository
        self.favoritesRepository = favoritesRepository
        isFavorite = favoritesRepository.isFavorite(location)
    }

    func loadWeather() async {
        state = .loading

        do {
            let weather = try await weatherRepository.fetchWeather(for: location)
            state = .loaded(weather)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func saveToFavorites() {
        guard !isFavorite else {
            return
        }

        favoritesRepository.saveFavorite(location)
        isFavorite = true
    }
}
