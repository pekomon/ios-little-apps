//
//  WeatherKitWeatherService.swift
//  Weatherly
//
//  Created by Pekomon on 17.3.2026.
//

import Foundation
import WeatherKit
import CoreLocation

protocol WeatherKitWeatherServicing {
    func fetchWeather(for location: CLLocation) async throws -> Weather
}

final class WeatherKitWeatherService: WeatherKitWeatherServicing {
    private let service = WeatherService()

    func fetchWeather(for location: CLLocation) async throws -> Weather {
        try await service.weather(for: location)
    }
}
