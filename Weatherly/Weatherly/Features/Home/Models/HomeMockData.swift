//
//  HomeMockData.swift
//  Weatherly
//
//  Created by Pekomon on 16.3.2026.
//
	

import Foundation

enum HomeMockData {
    static let helsinki = Location(
        id: "helsinki",
        name: "Helsinki",
        country: "Finland",
        latitude: 60.1699,
        longitude: 24.9384
    )

    static let weatherDetails = WeatherDetails(
        location: helsinki,
        current: CurrentWeather(
            temperature: 18.0,
            feelsLike: 17.0,
            humidity: 72,
            windSpeed: 5.4,
            pressure: 1012,
            visibility: 10_000,
            condition: .partlyCloudy,
            symbolName: "cloud.sun.fill"
        ),
        hourlyForecast: [
            HourlyForecast(
                id: Date(),
                date: Date(),
                temperature: 18.0,
                precipitationChance: 0.1,
                condition: .partlyCloudy,
                symbolName: "cloud.sun.fill"
            ),
            HourlyForecast(
                id: Date().addingTimeInterval(3600),
                date: Date().addingTimeInterval(3600),
                temperature: 17.0,
                precipitationChance: 0.2,
                condition: .cloudy,
                symbolName: "cloud.fill"
            )
        ],
        dailyForecast: [
            DailyForecast(
                id: Date(),
                date: Date(),
                minTemperature: 12.0,
                maxTemperature: 19.0,
                precipitationChance: 0.2,
                condition: .partlyCloudy,
                symbolName: "cloud.sun.fill"
            ),
            DailyForecast(
                id: Date().addingTimeInterval(86400),
                date: Date().addingTimeInterval(86400),
                minTemperature: 10.0,
                maxTemperature: 17.0,
                precipitationChance: 0.5,
                condition: .rain,
                symbolName: "cloud.rain.fill"
            )
        ],
        sunrise: Date().addingTimeInterval(-3600 * 6),
        sunset: Date().addingTimeInterval(3600 * 4),
        updatedAt: Date()
    )
}
