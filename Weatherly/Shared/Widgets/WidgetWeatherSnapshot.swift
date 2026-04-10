//
//  WidgetWeatherSnapshot.swift
//  Weatherly
//
//  Created by Pekomon on 10.4.2026.
//

import Foundation

struct WidgetWeatherSnapshot: Codable, Equatable, Sendable {
    struct DailyForecast: Codable, Equatable, Sendable, Identifiable {
        let date: Date
        let minTemperature: Double
        let maxTemperature: Double
        let symbolName: String

        var id: Date { date }
    }

    let locationName: String
    let temperature: Double
    let conditionText: String
    let symbolName: String
    let updatedAt: Date
    let dailyForecasts: [DailyForecast]
}

extension WidgetWeatherSnapshot {
    static let placeholder = WidgetWeatherSnapshot(
        locationName: "Helsinki",
        temperature: 12,
        conditionText: "Partly Cloudy",
        symbolName: "cloud.sun.fill",
        updatedAt: .now,
        dailyForecasts: [
            DailyForecast(
                date: .now,
                minTemperature: 8,
                maxTemperature: 15,
                symbolName: "cloud.sun.fill"
            ),
            DailyForecast(
                date: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now,
                minTemperature: 7,
                maxTemperature: 13,
                symbolName: "cloud.fill"
            ),
            DailyForecast(
                date: Calendar.current.date(byAdding: .day, value: 2, to: .now) ?? .now,
                minTemperature: 6,
                maxTemperature: 11,
                symbolName: "cloud.rain.fill"
            ),
        ]
    )
}
