//
//  AppSettings.swift
//  Weatherly
//
//  Created by Pekomon on 6.4.2026.
//

import Foundation

struct AppSettings: Equatable {
    var temperatureUnit: TemperatureUnit
    var windSpeedUnit: WindSpeedUnit
    var appearancePreference: AppAppearancePreference

    static let `default` = AppSettings(
        temperatureUnit: .celsius,
        windSpeedUnit: .metersPerSecond,
        appearancePreference: .system
    )
}

enum TemperatureUnit: String, CaseIterable {
    case celsius
    case fahrenheit
}

enum WindSpeedUnit: String, CaseIterable {
    case metersPerSecond
    case kilometersPerHour
}

enum AppAppearancePreference: String, CaseIterable {
    case system
    case light
    case dark
}
