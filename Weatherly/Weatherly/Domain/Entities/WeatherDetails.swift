//
//  WeatherDetails.swift
//  Weatherly
//
//  Created by Pekomon on 15.3.2026.
//
	

import Foundation

struct WeatherDetails: Equatable {
    let location: Location
    let current: CurrentWeather
    let hourlyForecast: [HourlyForecast]
    let dailyForecast: [DailyForecast]
    let sunrise: Date?
    let sunset: Date?
    let updatedAt: Date
}
