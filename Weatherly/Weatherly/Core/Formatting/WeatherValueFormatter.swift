//
//  WeatherValueFormatter.swift
//  Weatherly
//
//  Created by Pekomon on 8.4.2026.
//

import Foundation

struct WeatherValueFormatter {
    let temperatureUnit: TemperatureUnit
    let windSpeedUnit: WindSpeedUnit

    func temperature(_ value: Double) -> String {
        let convertedValue = switch temperatureUnit {
        case .celsius:
            value
        case .fahrenheit:
            (value * 9 / 5) + 32
        }

        return "\(Int(convertedValue.rounded()))°"
    }

    func windSpeed(_ value: Double) -> String {
        let convertedValue: Double
        let suffix: String

        switch windSpeedUnit {
        case .metersPerSecond:
            convertedValue = value
            suffix = "m/s"
        case .kilometersPerHour:
            convertedValue = value * 3.6
            suffix = "km/h"
        }

        let formattedValue = convertedValue.formatted(.number.precision(.fractionLength(1)))
        return "\(formattedValue) \(suffix)"
    }
}
