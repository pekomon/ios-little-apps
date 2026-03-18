//
//  WeatherKitWeatherMapper.swift
//  Weatherly
//
//  Created by Pekomon on 17.3.2026.
//

import Foundation
import WeatherKit

struct WeatherKitWeatherMapper {
    func map(weather: WeatherKit.Weather, location: Location) -> WeatherDetails {
        WeatherDetails(
            location: location,
            current: mapCurrentWeather(weather.currentWeather),
            hourlyForecast: weather.hourlyForecast.map(mapHourlyForecast),
            dailyForecast: weather.dailyForecast.map(mapDailyForecast),
            sunrise: weather.dailyForecast.first?.sun.sunrise,
            sunset: weather.dailyForecast.first?.sun.sunset,
            updatedAt: Date()
        )
    }

    private func mapCurrentWeather(_ current: WeatherKit.CurrentWeather) -> CurrentWeather {
        CurrentWeather(
            temperature: current.temperature.value,
            feelsLike: current.apparentTemperature.value,
            humidity: current.humidity * 100,
            windSpeed: current.wind.speed.value,
            pressure: current.pressure.value,
            visibility: current.visibility.value,
            condition: mapCondition(current.condition),
            symbolName: current.symbolName
        )
    }

    private func mapHourlyForecast(_ forecast: HourWeather) -> HourlyForecast {
        HourlyForecast(
            id: forecast.date,
            date: forecast.date,
            temperature: forecast.temperature.value,
            precipitationChance: forecast.precipitationChance,
            condition: mapCondition(forecast.condition),
            symbolName: forecast.symbolName
        )
    }

    private func mapDailyForecast(_ forecast: DayWeather) -> DailyForecast {
        DailyForecast(
            id: forecast.date,
            date: forecast.date,
            minTemperature: forecast.lowTemperature.value,
            maxTemperature: forecast.highTemperature.value,
            precipitationChance: forecast.precipitationChance,
            condition: mapCondition(forecast.condition),
            symbolName: forecast.symbolName
        )
    }

    private func mapCondition(_ condition: WeatherCondition) -> AppWeatherCondition {
        switch condition {
        case .clear:
            return .clear
        case .mostlyClear, .partlyCloudy:
            return .partlyCloudy
        case .mostlyCloudy, .cloudy:
            return .cloudy
        case .rain, .heavyRain, .drizzle:
            return .rain
        case .snow, .heavySnow, .flurries, .sleet:
            return .snow
        case .thunderstorms, .isolatedThunderstorms, .scatteredThunderstorms, .strongStorms:
            return .thunderstorm
        case .foggy, .haze, .smoky:
            return .fog
        case .windy, .breezy, .blowingDust:
            return .wind
        default:
            return .unknown
        }
    }
}
