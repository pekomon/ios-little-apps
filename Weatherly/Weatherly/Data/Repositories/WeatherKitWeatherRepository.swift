//
//  WeatherKitWeatherRepository.swift
//  Weatherly
//
//  Created by Pekomon on 17.3.2026.
//

import Foundation
import CoreLocation

final class WeatherKitWeatherRepository: WeatherRepository {
    private let service: WeatherKitWeatherServicing
    private let mapper: WeatherKitWeatherMapper

    init(
        service: WeatherKitWeatherServicing = WeatherKitWeatherService(),
        mapper: WeatherKitWeatherMapper = WeatherKitWeatherMapper()
    ) {
        self.service = service
        self.mapper = mapper
    }

    func fetchWeather(for location: Location) async throws -> WeatherDetails {
        let clLocation = CLLocation(
            latitude: location.latitude,
            longitude: location.longitude
        )

        let weather = try await service.fetchWeather(for: clLocation)
        return mapper.map(weather: weather, location: location)
    }
}
