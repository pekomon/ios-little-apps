//
//  HourlyForecast.swift
//  Weatherly
//
//  Created by Pekomon on 15.3.2026.
//
	

import Foundation

struct HourlyForecast: Identifiable, Equatable {
    let id: Date
    let date: Date
    let temperature: Double
    let precipitationChance: Double?
    let condition: AppWeatherCondition
    let symbolName: String
}
