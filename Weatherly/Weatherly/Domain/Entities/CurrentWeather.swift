//
//  CurrentWeather.swift
//  Weatherly
//
//  Created by Pekomon on 15.3.2026.
//
	

import Foundation

struct CurrentWeather: Equatable {
    let temperature: Double
    let feelsLike: Double
    let humidity: Double
    let windSpeed: Double
    let pressure: Double
    let visibility: Double?
    let condition: WeatherCondition
    let symbolName: String
}
