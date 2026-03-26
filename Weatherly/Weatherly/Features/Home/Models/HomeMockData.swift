//
//  HomeMockData.swift
//  Weatherly
//
//  Created by Pekomon on 16.3.2026.
//
	

import Foundation

enum HomeMockData {
    private static let calendar = Calendar.current
    private static let referenceDate = calendar.date(
        from: DateComponents(year: 2026, month: 3, day: 22, hour: 9)
    ) ?? Date()

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
        hourlyForecast: hourlyForecast,
        dailyForecast: dailyForecast,
        sunrise: calendar.date(byAdding: .hour, value: -3, to: referenceDate),
        sunset: calendar.date(byAdding: .hour, value: 11, to: referenceDate),
        updatedAt: referenceDate
    )

    static let hourlyForecast: [HourlyForecast] = [
        makeHourlyForecast(hourOffset: 0, temperature: 18.0, precipitationChance: 0.10, condition: .partlyCloudy, symbolName: "cloud.sun.fill"),
        makeHourlyForecast(hourOffset: 1, temperature: 18.0, precipitationChance: 0.10, condition: .partlyCloudy, symbolName: "cloud.sun.fill"),
        makeHourlyForecast(hourOffset: 2, temperature: 19.0, precipitationChance: 0.00, condition: .clear, symbolName: "sun.max.fill"),
        makeHourlyForecast(hourOffset: 3, temperature: 20.0, precipitationChance: 0.00, condition: .clear, symbolName: "sun.max.fill"),
        makeHourlyForecast(hourOffset: 4, temperature: 21.0, precipitationChance: 0.05, condition: .partlyCloudy, symbolName: "cloud.sun.fill"),
        makeHourlyForecast(hourOffset: 5, temperature: 20.0, precipitationChance: 0.15, condition: .cloudy, symbolName: "cloud.fill"),
        makeHourlyForecast(hourOffset: 6, temperature: 18.0, precipitationChance: 0.35, condition: .rain, symbolName: "cloud.rain.fill"),
        makeHourlyForecast(hourOffset: 7, temperature: 17.0, precipitationChance: 0.45, condition: .rain, symbolName: "cloud.rain.fill"),
        makeHourlyForecast(hourOffset: 8, temperature: 16.0, precipitationChance: 0.25, condition: .cloudy, symbolName: "cloud.fill"),
        makeHourlyForecast(hourOffset: 9, temperature: 15.0, precipitationChance: 0.10, condition: .cloudy, symbolName: "cloud.fill"),
        makeHourlyForecast(hourOffset: 10, temperature: 14.0, precipitationChance: 0.05, condition: .partlyCloudy, symbolName: "cloud.moon.fill"),
        makeHourlyForecast(hourOffset: 11, temperature: 13.0, precipitationChance: 0.05, condition: .partlyCloudy, symbolName: "cloud.moon.fill")
    ]

    static let dailyForecast: [DailyForecast] = [
        makeDailyForecast(dayOffset: 0, minTemperature: 12.0, maxTemperature: 19.0, precipitationChance: 0.20, condition: .partlyCloudy, symbolName: "cloud.sun.fill"),
        makeDailyForecast(dayOffset: 1, minTemperature: 11.0, maxTemperature: 17.0, precipitationChance: 0.55, condition: .rain, symbolName: "cloud.rain.fill"),
        makeDailyForecast(dayOffset: 2, minTemperature: 9.0, maxTemperature: 15.0, precipitationChance: 0.35, condition: .cloudy, symbolName: "cloud.fill"),
        makeDailyForecast(dayOffset: 3, minTemperature: 8.0, maxTemperature: 14.0, precipitationChance: 0.10, condition: .partlyCloudy, symbolName: "cloud.sun.fill"),
        makeDailyForecast(dayOffset: 4, minTemperature: 10.0, maxTemperature: 18.0, precipitationChance: 0.00, condition: .clear, symbolName: "sun.max.fill"),
        makeDailyForecast(dayOffset: 5, minTemperature: 11.0, maxTemperature: 16.0, precipitationChance: 0.40, condition: .wind, symbolName: "wind"),
        makeDailyForecast(dayOffset: 6, minTemperature: 7.0, maxTemperature: 13.0, precipitationChance: 0.30, condition: .rain, symbolName: "cloud.rain.fill")
    ]

    private static func makeHourlyForecast(
        hourOffset: Int,
        temperature: Double,
        precipitationChance: Double?,
        condition: AppWeatherCondition,
        symbolName: String
    ) -> HourlyForecast {
        let date = calendar.date(byAdding: .hour, value: hourOffset, to: referenceDate) ?? referenceDate

        return HourlyForecast(
            id: date,
            date: date,
            temperature: temperature,
            precipitationChance: precipitationChance,
            condition: condition,
            symbolName: symbolName
        )
    }

    private static func makeDailyForecast(
        dayOffset: Int,
        minTemperature: Double,
        maxTemperature: Double,
        precipitationChance: Double?,
        condition: AppWeatherCondition,
        symbolName: String
    ) -> DailyForecast {
        let date = calendar.date(byAdding: .day, value: dayOffset, to: referenceDate) ?? referenceDate

        return DailyForecast(
            id: date,
            date: date,
            minTemperature: minTemperature,
            maxTemperature: maxTemperature,
            precipitationChance: precipitationChance,
            condition: condition,
            symbolName: symbolName
        )
    }
}
