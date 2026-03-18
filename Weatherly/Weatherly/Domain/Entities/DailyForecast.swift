//
//  DailyForecast.swift
//  Weatherly
//
//  Created by Pekomon on 15.3.2026.
//
	

import Foundation

struct DailyForecast: Identifiable, Equatable {
    let id: Date
    let date: Date
    let minTemperature: Double
    let maxTemperature: Double
    let precipitationChance: Double?
    let condition: AppWeatherCondition
    let symbolName: String
}
