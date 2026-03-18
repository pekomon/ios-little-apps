//
//  HomeViewModel.swift
//  Weatherly
//
//  Created by Pekomon on 16.3.2026.
//

import Foundation
import Observation

@Observable
final class HomeViewModel {
    var state: HomeState = .idle

    private let weatherRepository: WeatherRepository

    init(weatherRepository: WeatherRepository = WeatherKitWeatherRepository()) {
        self.weatherRepository = weatherRepository
    }

    func loadWeather() async {
        state = .loading

        let helsinki = Location(
            id: "helsinki-001",
            name: "Helsinki",
            country: "Finland",
            latitude: 60.1699,
            longitude: 24.9384
        )

        do {
            let weather = try await weatherRepository.fetchWeather(for: helsinki)
            state = .loaded(weather)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    /*
    func loadMockWeather() {
        state = .loading
        state = .loaded(HomeMockData.weatherDetails)
    }
    */
}
