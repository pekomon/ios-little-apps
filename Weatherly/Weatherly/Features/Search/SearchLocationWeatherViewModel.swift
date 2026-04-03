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

    private let weatherRepository: WeatherRepository

    init(
        location: Location,
        weatherRepository: WeatherRepository = WeatherKitWeatherRepository()
    ) {
        self.location = location
        self.weatherRepository = weatherRepository
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
}
